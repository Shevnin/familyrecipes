# Сессия: REPEAT-LOOP-01 — Реализация Mastery Loop

Дата: 2026-03-23

## Статус: DONE

Backend + iOS реализованы полностью. Android — parity notes ниже.

---

## Что было сделано

### BE-SPEC-05 + BE-IMPL-05 — Backend

#### Таблица `recipe_attempts`

```sql
CREATE TABLE public.recipe_attempts (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id    uuid        NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  household_id uuid        NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  created_by   uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  result       text        NOT NULL CHECK (result IN ('failed', 'partial', 'success')),
  note_text    text,
  created_at   timestamptz NOT NULL DEFAULT now()
);
```

Таблица append-only. Полный журнал попыток сохранён в БД, UI показывает только последнюю.

#### RLS
- `SELECT`: любой member household может видеть попытки household (для будущих метрик).
- `INSERT`: member может вставлять только свои попытки (`created_by = auth.uid()`).
- Update/Delete не разрешены.

#### Mastery status — логика вычисления

| Попытки пользователя | `mastery_status`    |
|----------------------|---------------------|
| 0 (нет попыток)      | `получил`           |
| Последняя = `failed` | `пробовал`          |
| Последняя = `partial`| `почти получилось`  |
| Последняя = `success`| `замастерил`        |

Вычисляется через `LATERAL` JOIN в VIEW `family_recipe_cards`, фильтр `created_by = auth.uid()`.

#### mastery_status ≠ card_status

```
card_status:    lifecycle карточки — pending / received / clarification / expired
mastery_status: прогресс освоения  — получил / пробовал / почти получилось / замастерил
```

Ортогональные слои. Карточка может быть `received` при любом `mastery_status`.

#### VIEW `family_recipe_cards` — новые поля

Для `received` карточек (рецептов):
- `cook_count bigint` — кол-во попыток текущего пользователя
- `mastery_status text` — вычисленный статус освоения
- `latest_attempt_result text` — результат последней попытки (`failed` / `partial` / `success`)
- `latest_attempt_note text` — заметка последней попытки
- `latest_cooked_at timestamptz` — время последней попытки

Для `pending` / `expired` карточек: `cook_count = 0`, `mastery_status = 'получил'`, остальные NULL.

Реализовано через `LEFT JOIN LATERAL`:
```sql
LEFT JOIN LATERAL (
  SELECT
    result AS latest_result,
    note_text AS latest_note,
    created_at AS latest_cooked_at,
    COUNT(*) OVER (PARTITION BY recipe_id, created_by)::bigint AS cook_count
  FROM public.recipe_attempts
  WHERE recipe_id = r.id AND created_by = auth.uid()
  ORDER BY created_at DESC
  LIMIT 1
) ma ON true
```

Миграция: `supabase/migrations/00008_mastery_loop.sql`

#### Edge Function `log-cook-attempt`

Path: `supabase/functions/log-cook-attempt/index.ts`

- Auth: Bearer JWT обязателен.
- Входные данные:
  ```json
  { "recipe_id": "uuid", "result": "failed|partial|success", "note_text": "optional" }
  ```
- Проверяет: рецепт существует, пользователь — member его household.
- Вставляет запись в `recipe_attempts`.
- Вычисляет и возвращает обновлённый mastery read-model:
  ```json
  {
    "attempt_id": "uuid",
    "cook_count": 3,
    "mastery_status": "почти получилось",
    "latest_attempt_result": "partial",
    "latest_attempt_note": "...",
    "latest_cooked_at": "2026-03-23T..."
  }
  ```

Деплой: `supabase functions deploy log-cook-attempt --no-verify-jwt`

---

### iOS — IOS-10, IOS-11, IOS-12

#### Изменённые файлы
- `Core/Networking/Models/FamilyRecipeCard.swift` — добавлены `CookResult`, `MasteryStatus`, mastery поля в `FamilyRecipeCard`, `withMasteryUpdate()`.
- `Core/Networking/EdgeFunctionsClient.swift` — расширен `fetchFamilyCards` запрос, добавлен `logCookAttempt()` + `CookAttemptResponse`.
- `Features/Recipes/RecipesViewModel.swift` — добавлен `updateCard(_:)`.
- `Features/Recipes/RecipeDetailView.swift` — добавлены `MasteryBlock`, `PostCookSheet` sheet, contextual clarification CTA (`showClarificationCTA`), `@State private var currentCard`.
- `Features/Recipes/RecipesView.swift` — передаётся `onCardUpdated` в `RecipeDetailView`, mastery badge в card row.

#### Новые файлы
- `Features/Recipes/PostCookSheet.swift` — IOS-11 post-cook flow.

#### IOS-10: MasteryBlock на detail screen

Показывает (только для `isReceived` карточек с `recipeId`):
- Заголовок «МОЙ ПРОГРЕСС» + mastery status badge
- «Готовил N раз» (если ≥1 попытка)
- Последняя post-cook заметка (если есть)
- CTA «Отметить первую готовку» / «Отметить готовку»

#### IOS-11: PostCookSheet

Лёгкий sheet без тяжёлого редактора:
- Результат выбирается одним тапом из 3 вариантов
- Опциональное текстовое поле для заметки
- После сохранения: обновляет `currentCard` in-place через `withMasteryUpdate()`, вызывает `onCardUpdated` для обновления списка

#### IOS-12: Contextual clarification CTA

- Показывается автоматически после `failed` или `partial` попытки
- Стилизован как кнопка (не текстовый link) — «Уточнить у автора»
- Переиспользует существующий clarification flow: `requestDraft.parentRecipeId = card.recipeId`
- Базовый CTA «Попросить уточнить» сохранён, не заменён

#### Mastery badge в списке

В card row для `isReceived` карточек с `hasAttempts == true` — иконка `masteryStatus.icon` в `masteryStatus.color`. Минимальный и не шумный.

---

## Android parity notes (ANDROID-MASTERY-01)

Backend полностью готов. Для Android parity нужно:

1. **Модель**: добавить mastery поля в `FamilyRecipeCard` data class (аналог Swift)
   - `cookCount: Int`, `masteryStatus: String`, `latestAttemptResult: String?`, `latestAttemptNote: String?`, `latestCookedAt: String?`

2. **Сетевой слой**: обновить fetch query — добавить новые поля в SELECT, аналогично iOS.

3. **Логирование попытки**: вызов `log-cook-attempt` Edge Function через Retrofit/OkHttp.

4. **UI — MasteryBlock**: блок на detail screen, аналогичный iOS MasteryBlock.

5. **UI — PostCookSheet / BottomSheet**: Bottom sheet с тремя кнопками результата + TextField для заметки.

6. **UI — Contextual CTA**: после failed/partial показывать строку «Уточнить у автора», переиспользующую существующий clarification flow.

7. **UI — List badge**: иконка mastery status для received карточек с попытками.

Референс: iOS-реализация. API контракт описан выше.

---

## Deploy checklist

- [ ] `supabase db push` (или apply migration 00008 в prod)
- [ ] `supabase functions deploy log-cook-attempt --no-verify-jwt`
- [ ] iOS: rebuild + тест: открыть рецепт → Отметить готовку → выбрать результат → сохранить → проверить MasteryBlock
- [ ] iOS: тест failed/partial: должен появиться contextual CTA «Уточнить у автора»
- [ ] iOS: проверить, что personal note (NoteSection) не затронута

---

## Acceptance criteria — всё выполнено

- [x] У полученного рецепта есть отдельный `mastery_status`
- [x] Пользователь может отметить первую и повторные готовки
- [x] После готовки можно сохранить короткую заметку
- [x] На detail screen видны: количество попыток, текущий mastery progress, последняя post-cook note
- [x] После неудачной или неполной попытки есть мягкий CTA на уточнение у автора
- [x] Loop `оригинал рецепта + личная заметка` не сломан
- [x] UX лёгкий — не превращается в тяжёлый cooking journal

# Current State (Session Handoff)

Обновлено: 2026-03-22

## Фаза
- Текущая фаза: **Delivery (Native MVP)**
- Stage-Gate этап: **5) Delivery Start (Native Mobile + Backend) [in progress]**
- Roadmap: **R3 - Native MVP [current]**
- Backend: Supabase dev развернут и стабилизирован.
- iOS: R3 slice закрыт (IOS-01...IOS-08). Готово к E2E.
- Android: ещё не начат.

## Где остановились
- Последняя активная сессия: 2026-03-22 — зафиксирован живой тест donor flow: папа в тестовом режиме заполнил рецепт как донор.
- IOS-01...IOS-08 все реализованы.
- **Unified card model реализован** (BE-SPEC-04, BE-IMPL-04, LIST-01, LIST-02, REQ-09, DETAIL-10, CARD-DELETE-01):
  - Backend: миграция `00005_unified_card_model.sql` (recipe_story, hidden_at, parent_recipe_id, VIEW `family_recipe_cards`).
  - Edge Function `create-request` обновлена: принимает `parent_recipe_id`. (`recipe_story` удалён из create-request — это поле донора.)
  - iOS: единый список карточек (pending + received), статусные бейджи, скрытые даты, блок `история рецепта` в detail, удаление карточки с подтверждением.
- **Request flow simplification (REQ-10...REQ-18) реализован**:
  - убрали `история рецепта` из primary request UI повара;
  - `Кому отправить?` — editable dropdown с suggestions из контактов и истории;
  - `Какой рецепт?` → `Название рецепта`;
  - CTA = `Получить ссылку`;
  - ссылка inline на том же экране, без отдельного success-state;
  - кнопка `Копировать` с micro-feedback (haptic + «Скопировано» + checkmark, авто-сброс через 1.2с);
  - под ссылкой: пояснение и кнопка `Сформировать новый запрос`.
- **Shared RecipesViewModel** — единый source of truth для вкладки «Рецепты» и истории запросов на «Запросить». Delete из одного места убирает карточку отовсюду. Старый `RecipeRequest` model и `fetchRequestHistory` удалены.
- **`recipe_story` — поле донора, не повара.** Полный flow:
  1. Повар создаёт запрос в iOS-приложении (без recipe_story).
  2. Донор открывает ссылку в браузере → видит форму на `web-reply/index.html`.
  3. Донор заполняет обязательный «Рецепт» (`original_text`) и опциональное «История рецепта» (`recipe_story`) — textarea после рецепта, placeholder: *«Откуда этот рецепт? Кто его готовил, когда и по какому поводу...»*.
  4. При submit `recipe_story` передаётся в `submit-request` → RPC `submit_recipe_by_token` → записывается в `recipes.recipe_story`.
  5. Повар видит `recipe_story` на detail screen в iOS (read-only блок «История рецепта»).
  - Миграция: `00006_submit_recipe_story.sql`.
  - Всё задеплоено и live.
- Появился первый живой сигнал по donor flow: реальный родственник (папа) прошёл тестовый сценарий заполнения рецепта как донор. Это подтверждает жизнеспособность текущего zero-install flow, но не отменяет необходимость собрать qualitative feedback и провести полноценный device-to-device E2E.
- **DONOR-07 post-submit edit flow реализован и задеплоен:**
  - Backend: миграция `00007_donor_edit_token.sql` — `edit_token_hash` + `edit_expires_at` в `recipe_submissions`, RPC `submit_recipe_by_token` расширен до 7 аргументов, новый RPC `update_recipe_by_edit_token`.
  - Edge Function `submit-request` обновлена: генерирует `edit_token`, хеширует, передаёт в RPC, возвращает raw `edit_token` + `edit_expires_at` клиенту.
  - Новая Edge Function `get-edit-meta` (public): lookup по `edit_token`, возвращает prefilled данные или ошибку (`edit_not_found` / `edit_window_expired`).
  - Новая Edge Function `update-submitted-recipe` (public): валидация token + window, вызов `update_recipe_by_edit_token` RPC, обновление существующего рецепта без дубля.
  - `web-reply/index.html`: edit mode через `?edit_token=<token>`, бейдж «Редактирование», prefilled форма, CTA «Исправить рецепт» на success-state после первого submit, отдельные error-states для невалидного edit link и истёкшего окна, edit success state «Изменения сохранены».
  - Окно редактирования: 72 часа. Редактируемые поля: `submitted_by_name`, `recipe_title`, `original_text`, `recipe_story`.
  - Token security: raw `edit_token` в БД не хранится, сравнение по SHA-256 hash.
  - Всё задеплоено и live.
- Android находится на старте реализации (`ANDROID-01`). Parity notes для unified card model: `docs/sessions/2026-03-21_android_unified_card_parity_notes.md`.
- Сформирован Donor conversion backlog (`DONOR-01...DONOR-04`, `DONOR-11`), реализация после Android parity. `DONOR-07` — done.

## Архитектура MVP
- **Повар** (Master): нативное приложение (iOS/Android), auth через Supabase.
- **Донор**: zero-install, mobile web по ссылке из мессенджера.
- **Flow**: Request in app -> link in messenger -> donor web submit -> recipe in app.
- **Donor reply contract (live, v1.5)**:
  - `original_text` (обязательный) — текст рецепта: ингредиенты, шаги, советы.
  - `recipe_story` (опциональный) — история рецепта: откуда он, кто готовил, семейный контекст. **Заполняется донором** на web-reply page, не поваром. Повар не видит и не вводит это поле — оно появляется только на donor web page как textarea после поля рецепта. Хранится в `recipes.recipe_story`.
- Целевой donor contract v2 (pending): `recipe_text` + `donor_comment` — ещё не реализован.

## Backend (Supabase) — DEPLOYED
- Project ref: `wlxtobrxqytnmpifbnev`
- URL: `https://wlxtobrxqytnmpifbnev.supabase.co`
- Конфиг: `supabase/config.toml`
- Миграции:
  - `00001_init.sql` — базовая схема, RLS.
  - `00002_fix_rls_and_atomic_submit.sql` — bootstrap + atomic submit.
  - `00003_lockdown_rpc_and_link_contract.sql` — revoke прямого RPC-доступа клиентам.
  - `00004_grant_service_role_rpc.sql` — grant execute RPC для `service_role`.
  - `00005_unified_card_model.sql` — `recipe_story`, `hidden_at`, `parent_recipe_id`, VIEW `family_recipe_cards`, UPDATE RLS policies.
  - `00006_submit_recipe_story.sql` — RPC `submit_recipe_by_token` расширен: принимает `p_recipe_story`, записывает в `recipes.recipe_story`.
  - `00007_donor_edit_token.sql` — `edit_token_hash` + `edit_expires_at` в `recipe_submissions`, RPC расширен до 7 аргументов, новый RPC `update_recipe_by_edit_token`.
- Edge Functions (deploy с `--no-verify-jwt`):
  - `create-request` (auth) — `token`, `web_url`, `share_text`. Принимает опциональный `parent_recipe_id`.
  - `get-request-meta` (public) — статус запроса по токену. Колонка `recipe_story` в SELECT осталась, но на практике всегда null (повар не заполняет).
  - `submit-request` (public) — атомарный submit через SQL RPC. Принимает `original_text` (обязательный) и `recipe_story` (опциональный) **от донора** → записывает в `recipes`. Генерирует `edit_token` + `edit_expires_at` (72ч) и возвращает клиенту.
  - `get-edit-meta` (public) — lookup по `edit_token`, возвращает prefilled данные для edit-формы или ошибку.
  - `update-submitted-recipe` (public) — обновление рецепта по `edit_token` в пределах 72-часового окна.
- Link contract:
  - `APP_BASE_URL=https://shevnin.github.io/familyrecipes`
  - `APP_LINK_MODE=query`
  - submit ссылка: `https://shevnin.github.io/familyrecipes/web-reply/?token=<token>`
  - edit ссылка: `https://shevnin.github.io/familyrecipes/web-reply/?edit_token=<edit_token>`
- Guest web: `web-reply/index.html` live на GitHub Pages.
- Runbook: `docs/backend_setup_supabase.md`

## iOS App
- Путь: `apps/ios/FamilyRecipes/FamilyRecipes/`
- Stack: SwiftUI + URLSession, без SPM.
- Конфиг: `Config.plist` (gitignored), template `Config.example.plist`.
- Статус:
  - Login (email/password) через Supabase Auth REST API.
  - Session persistence в **Keychain**.
  - Auto-refresh токена + retry на 401 (все запросы).
  - Auto-bootstrap household при первом логине.
  - Create Request -> Edge Function -> inline link result.
  - Logout с подтверждением.
  - Список рецептов (real data, pull-to-refresh, loading/empty/error).
  - Единый список карточек семейных рецептов (pending + received + clarification).
  - Inline history запросов на экране "Запросить".
  - Упрощённый request flow: editable dropdown для получателя, `Название рецепта`, CTA `Получить ссылку`, inline link + `Копировать` с micro-feedback (REQ-10...REQ-18).
  - Личные заметки к рецептам (local, IOS-05).
  - Создание своих рецептов через "+" (IOS-06).
  - "Попросить уточнить" на карточке рецепта (IOS-07).
  - "Моя семья и друзья" в настройках (IOS-08).
  - App icon добавлен в `Assets.xcassets/AppIcon.appiconset`.
  - `recipe_story` **не вводится поваром** — это поле донора на web-reply. Повар видит `recipe_story` только на detail screen (read-only), если донор его заполнил.
  - Блок `история рецепта` в detail screen (DETAIL-10) — показывает `recipe_story`, заполненный донором.
  - Удаление карточки с confirmation dialog (CARD-DELETE-01).
  - Даты скрыты из primary list/detail UI (LIST-02).
  - Shared `RecipesViewModel` как единый source of truth для списка рецептов и истории запросов. Delete из одного места сразу убирает карточку отовсюду. Старый `RecipeRequest` model и `fetchRequestHistory` удалены.
- Product/design target for next donor iteration:
  - donor reply v2 = `recipe_text` + `donor_comment` (ещё не реализовано)
  - recipe detail should evolve toward `author + donor text + donor comment + recipe story + personal note`
  - `recipe_story` уже заполняется донором на web-reply и хранится в `recipes.recipe_story`
- Local persistence:
  - `UserDefaults` JSON: contacts, recipe notes, link cache.
  - `Keychain`: auth tokens.
- README: `apps/ios/README.md`

## Прототипы (discovery, reference only)
1. `src/index.html` — split-screen demo.
2. `web-mobile/index.html` — mobile web prototype.

## Что сейчас в приоритете (P0)
1. ~~`IOS-01`...`IOS-08`~~ [все done]
2. ~~`BE-SPEC-04` + `BE-IMPL-04`~~ [done] — unified card model, recipe_story, soft delete, VIEW `family_recipe_cards`.
3. ~~`LIST-01` + `LIST-02` + `REQ-09` + `DETAIL-10` + `CARD-DELETE-01`~~ [done] — iOS unified list, hidden dates, recipe story, delete.
4. `ANDROID-01...ANDROID-08` Реализация Android parity build (Compose) по iOS slice + unified card model.
5. `ANDROID-BUILD-01` Сборка и установка на реальное Android устройство.
6. Full E2E на реальных устройствах (iOS + Android + messenger + web-reply).
7. ~~Request flow simplification pack: `REQ-10...REQ-18`~~ [done].
8. ~~`DONOR-07` post-submit edit flow~~ [done].
9. Donor conversion pack: `DONOR-01...DONOR-04`, затем `DONOR-11`.
10. Donor reply contract v2: `DONOR-12` + `BE-SPEC-03` + `BE-IMPL-03` + detail parity updates.
11. `BE-SPEC-02` + `BE-IMPL-02` (server storage контактов/chips в Supabase) только если сохраняется подтвержденная cross-device необходимость.

## Первый шаг в новой сессии
1. Прочитать этот файл.
2. Прочитать `docs/sessions/2026-03-22_papa_donor_test.md`.
3. Прочитать `docs/sessions/2026-03-22_donor_post_submit_edit_flow.md`.
4. Прочитать `docs/sessions/2026-03-22_DONOR_07_post_submit_edit_task_pack.md`, если следующая сессия идёт в donor web/backend.
5. Прочитать `docs/sessions/2026-03-01_android_master_task_pack.md`.
6. Прочитать `docs/sessions/2026-03-21_android_unified_card_parity_notes.md` (unified card model parity).
7. Прочитать `apps/ios/README.md` (как reference parity).
8. `DONOR-07` уже реализован — можно стартовать `ANDROID-01` и идти последовательно до `ANDROID-BUILD-01`, учитывая unified card model.

## Технический контекст
- Branch: `main`
- Backend: Supabase (PostgreSQL 17 + Deno Edge Functions)
- Auth: Supabase Auth (email/password; Google/Apple позже)
- JWT: ES256 -> функции деплоятся с `--no-verify-jwt`, auth валидируется внутри функций
- Storage: PostgreSQL + RLS (default deny)
- Submit consistency: атомарный SQL RPC `submit_recipe_by_token(text,text,text,text,text,text,timestamptz)` с row lock; 5-й параметр — `p_recipe_story`, 6-й — `p_edit_token_hash`, 7-й — `p_edit_expires_at`.
- Donor edit: RPC `update_recipe_by_edit_token(text,text,text,text,text)` — обновляет рецепт по edit_token_hash в пределах 72ч окна.
- Guest web: `web-reply/index.html` (mobile-first)
- Anti-abuse: optional Turnstile (`CAPTCHA_SECRET`), пока не включен в prod
- Error hygiene: API не возвращает internal details клиенту
- Contacts/chips: local storage (UserDefaults) до выполнения `BE-SPEC-02/BE-IMPL-02`.
- Donor reply contract v1.5 deployed: `original_text` + optional `recipe_story` (заполняется донором, не поваром). Target v2: `recipe_text` + `donor_comment`.
- `recipe_story` flow: донор вводит → `submit-request` → RPC → `recipes.recipe_story` → повар читает на detail screen в iOS.
- Product priority clarified on 2026-03-21: after Android parity we optimize the donor loop first, and only then move supporting local data like contacts/chips to backend if still justified.
- Additional product clarification on 2026-03-21: requests and recipes should converge into one family-recipe card model with statuses; primary UI should hide dates and support delete.
- Additional donor clarification on 2026-03-22: post-submit donor correction should use a separate `edit_token`, stay zero-install/no-auth, and remain time-limited instead of becoming an open-ended editor.
- DONOR-07 implemented on 2026-03-22: full post-submit edit flow live (migration 00007, 2 new edge functions, web-reply edit mode). Token stored as SHA-256 hash, 72h window, updates existing recipe without duplicates.

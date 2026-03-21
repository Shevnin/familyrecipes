# BE-SPEC-04: Unified Family Recipe Card — Backend Specification

Дата: 2026-03-21

## Цель

Определить backend-контракт для единой карточки семейного рецепта, объединяющей `recipe_requests` и `recipes` в одну read-model с поддержкой:
- unified list (pending + received в одном запросе);
- unified detail;
- статусной модели;
- поля `recipe_story`;
- soft delete.

## Текущая схема (reference)

### Таблицы
- `recipes` — id, household_id, title, author_name, original_text, structured_json, created_by, created_at
- `recipe_requests` — id, household_id, requested_by, recipient_name, dish_name, token_hash, status (pending/fulfilled/expired/cancelled), expires_at, fulfilled_at, created_at
- `recipe_submissions` — request_id → created_recipe_id (связь запроса с рецептом)

### Связи
- Fulfilled request → recipe_submissions → recipes (1:1)
- Manual recipe → recipes без связи с request
- Clarification request (IOS-07) → новый recipe_request без явной связи с parent recipe

## Статусная модель карточки

Для пользователя карточка может быть в одном из состояний:

| card_status | Источник | Логика |
|---|---|---|
| `pending` | recipe_request с status='pending' | Ожидает ответа донора |
| `received` | recipe (manual или из fulfilled request) | Рецепт получен/создан |
| `clarification` | recipe, у которого есть связанный pending request с parent_recipe_id | Уточнение запрошено |
| `expired` | recipe_request с status='expired' или expires_at < now() | Запрос истёк |

## Изменения в схеме БД

### Migration: `00005_unified_card_model.sql`

#### 1. Новые колонки

```sql
-- recipe_story: семейный контекст / происхождение блюда
ALTER TABLE public.recipe_requests ADD COLUMN recipe_story text;
ALTER TABLE public.recipes ADD COLUMN recipe_story text;

-- soft delete
ALTER TABLE public.recipes ADD COLUMN hidden_at timestamptz;
ALTER TABLE public.recipe_requests ADD COLUMN hidden_at timestamptz;

-- clarification link: связывает follow-up request с parent recipe
ALTER TABLE public.recipe_requests ADD COLUMN parent_recipe_id uuid
  REFERENCES public.recipes(id) ON DELETE SET NULL;
```

#### 2. Database VIEW: `family_recipe_cards`

```sql
CREATE VIEW public.family_recipe_cards
WITH (security_invoker = true)
AS

-- Part 1: Unfulfilled requests (pending/expired) → card без recipe text
SELECT
  rr.id              AS card_id,
  rr.household_id,
  rr.dish_name       AS title,
  rr.recipient_name  AS author_name,
  NULL::text          AS original_text,
  CASE
    WHEN rr.status = 'pending' AND rr.expires_at < now() THEN 'expired'
    ELSE rr.status
  END                 AS card_status,
  rr.recipe_story,
  NULL::uuid          AS recipe_id,
  rr.id               AS request_id,
  rr.created_at
FROM public.recipe_requests rr
WHERE rr.status IN ('pending', 'expired')
  AND rr.hidden_at IS NULL

UNION ALL

-- Part 2: Recipes (from fulfilled requests or manual creation)
SELECT
  r.id                AS card_id,
  r.household_id,
  r.title,
  r.author_name,
  r.original_text,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM public.recipe_requests cr
      WHERE cr.parent_recipe_id = r.id
        AND cr.status = 'pending'
        AND cr.hidden_at IS NULL
    ) THEN 'clarification'
    ELSE 'received'
  END                  AS card_status,
  COALESCE(r.recipe_story, rr.recipe_story) AS recipe_story,
  r.id                 AS recipe_id,
  rs.request_id        AS request_id,
  r.created_at
FROM public.recipes r
LEFT JOIN public.recipe_submissions rs ON rs.created_recipe_id = r.id
LEFT JOIN public.recipe_requests rr ON rr.id = rs.request_id
WHERE r.hidden_at IS NULL;
```

#### 3. RLS policies для update (soft delete)

```sql
-- Recipes: members can soft-delete
CREATE POLICY "Members can update household recipes"
  ON public.recipes FOR UPDATE
  USING (public.is_household_member(household_id))
  WITH CHECK (public.is_household_member(household_id));

-- Requests: members can soft-delete
CREATE POLICY "Members can update household requests"
  ON public.recipe_requests FOR UPDATE
  USING (public.is_household_member(household_id))
  WITH CHECK (public.is_household_member(household_id));
```

#### 4. Index

```sql
CREATE INDEX idx_recipe_requests_parent_recipe
  ON public.recipe_requests (parent_recipe_id)
  WHERE parent_recipe_id IS NOT NULL;
```

## API Contracts

### Unified List

**Endpoint:** `GET /rest/v1/family_recipe_cards?household_id=eq.{hid}&order=created_at.desc`

**Headers:**
- `Authorization: Bearer {access_token}`
- `apikey: {anon_key}`

**Response:** `[FamilyRecipeCard]`

```json
{
  "card_id": "uuid",
  "household_id": "uuid",
  "title": "string",
  "author_name": "string",
  "original_text": "string | null",
  "card_status": "pending | received | clarification | expired",
  "recipe_story": "string | null",
  "recipe_id": "uuid | null",
  "request_id": "uuid | null",
  "created_at": "timestamptz"
}
```

Клиент фильтрует по `household_id` (RLS гарантирует видимость только для members).

### Unified Detail

Для detail экрана клиент использует тот же `family_recipe_cards` с фильтром по `card_id`:

**Endpoint:** `GET /rest/v1/family_recipe_cards?card_id=eq.{id}`

Дополнительные данные (personal notes) хранятся локально на клиенте.

### Delete (Soft Hide)

Клиент делает PATCH на соответствующую таблицу:

**Recipe card (card_status=received):**
```
PATCH /rest/v1/recipes?id=eq.{recipe_id}
Body: { "hidden_at": "2026-03-21T12:00:00Z" }
```

**Request card (card_status=pending/expired):**
```
PATCH /rest/v1/recipe_requests?id=eq.{request_id}
Body: { "hidden_at": "2026-03-21T12:00:00Z" }
```

RLS гарантирует, что PATCH доступен только members household.

### Create Request с recipe_story

Обновлённый контракт `create-request` Edge Function:

**Input (добавлено поле):**
```json
{
  "recipient_name": "string",
  "dish_name": "string",
  "recipe_story": "string | null",
  "parent_recipe_id": "string | null",
  "expires_in_days": 30,
  "household_id": "string | null"
}
```

**Поведение:**
- `recipe_story` сохраняется в `recipe_requests.recipe_story`.
- `parent_recipe_id` сохраняется для связи с parent recipe (IOS-07 clarification flow).
- Остальной flow без изменений.

## Delete Semantics

### Что считается удалением
- **Soft delete**: `hidden_at = now()` — карточка перестаёт отображаться в unified list.
- Данные остаются в БД для audit / возможного восстановления.

### Что происходит со связанными данными
- Удаление recipe: `recipe.hidden_at = now()`. Связанная submission и fulfilled request остаются в БД. Request не «воскрешается».
- Удаление pending request: `recipe_request.hidden_at = now()`. Если донор ответит на уже скрытый запрос, рецепт всё равно создастся (submit не проверяет hidden_at — это frontend concern). Клиент может при необходимости скрыть и этот рецепт.
- Already submitted donor data не удаляется и не модифицируется.

### Что НЕ делаем
- Hard delete.
- Каскадное удаление связанных записей.
- Undo/restore UI (можно добавить позже через `hidden_at IS NOT NULL` query).

## Совместимость

### Что не ломается
- Текущий public link flow: create-request → share → donor submit → recipe in app. `submit_recipe_by_token` не затрагивается.
- Auth / RLS гарантии: view использует `security_invoker = true`, RLS работает через underlying tables.
- Donor web flow (`web-reply/index.html`): контракт submit-request не меняется.
- Существующие Edge Functions: create-request получает два опциональных поля, остальные функции без изменений.

### Будущая совместимость
- `recipe_story` на recipes позволит future donor reply v2 копировать story при submit.
- `parent_recipe_id` подготавливает clarification tracking без усложнения текущего flow.
- `hidden_at` готов для future undo/restore.

## Acceptance Criteria для BE-IMPL-04

1. Migration `00005_unified_card_model.sql` применяется без ошибок.
2. View `family_recipe_cards` возвращает объединённые данные через PostgREST.
3. RLS на view работает: member видит только карточки своего household.
4. `create-request` Edge Function принимает `recipe_story` и `parent_recipe_id`.
5. PATCH на recipes/recipe_requests с `hidden_at` работает для household members.
6. Текущий flow (create → share → submit → fetch) не сломан.

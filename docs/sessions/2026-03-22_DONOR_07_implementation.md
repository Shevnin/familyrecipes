# Сессия: DONOR-07 Implementation — Post-Submit Edit Flow

Дата: 2026-03-22

## Что сделано

### Backend (Supabase)
- **Миграция `00007_donor_edit_token.sql`**:
  - Добавлены колонки `edit_token_hash` (text, unique) и `edit_expires_at` (timestamptz) в `recipe_submissions`.
  - Индекс `idx_recipe_submissions_edit_token_hash`.
  - Обновлён `submit_recipe_by_token` RPC: 7 аргументов (+ `p_edit_token_hash`, `p_edit_expires_at`). При submit записывает edit token metadata в `recipe_submissions`.
  - Новый RPC `update_recipe_by_edit_token`: lookup по hash, проверка окна, обновление `recipes` + `recipe_submissions`.
  - Гранты: revoke public/anon/authenticated, grant service_role (оба RPC).

### Edge Functions
- **`submit-request` обновлён**: генерирует `edit_token` (UUID), хеширует SHA-256, передаёт hash + expires в RPC, возвращает raw `edit_token` + `edit_expires_at` в response.
- **`get-edit-meta` (новая)**: принимает `edit_token`, хеширует, lookup в `recipe_submissions`, валидирует окно, возвращает prefilled данные (`submitted_by_name`, `recipe_title`, `original_text`, `recipe_story`, `edit_expires_at`) или ошибку.
- **`update-submitted-recipe` (новая)**: принимает `edit_token` + поля для обновления, вызывает `update_recipe_by_edit_token` RPC, возвращает результат.

### Web-reply (`web-reply/index.html`)
- **Routing**: `?edit_token=<token>` запускает edit mode, `?token=<token>` — submit mode (как раньше).
- **Edit mode**:
  - Бейдж «Редактирование» над формой.
  - Prefilled форма с текущими значениями из `get-edit-meta`.
  - CTA: «Сохранить изменения».
  - Edit success: «Изменения сохранены».
- **Submit success обновлён**:
  - Текст: «В течение 72 часов вы можете внести правки.»
  - CTA «Исправить рецепт» — навигация на `?edit_token=<token>`.
- **Новые error states**:
  - `state-edit-not-found`: «Ссылка для редактирования не найдена».
  - `state-edit-expired`: «Время для правок истекло».
  - `state-edit-success`: «Изменения сохранены».

### Deploy
- Миграция: `supabase db push`
- Edge Functions: `supabase functions deploy` (submit-request, get-edit-meta, update-submitted-recipe)
- Web-reply: `git push` → GitHub Pages

## Token security
- Raw `edit_token` никогда не хранится в БД — только SHA-256 hash.
- Паттерн аналогичен request token flow.
- Окно: 72 часа от момента первого submit.

## Что НЕ менялось
- Исходный request-link по-прежнему одноразовый.
- `submit-request` не стал mixed create/update endpoint.
- Donor auth не добавлен.
- Версионирование рецептов не добавлено.
- iOS/Android не затронуты.

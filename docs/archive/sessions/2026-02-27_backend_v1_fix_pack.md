# Сессия: Backend v1 Fix Pack #1

Дата: 2026-02-27

## Цель
Закрыть найденные риски в backend v1 без расширения scope.

## Что сделано

### 1. Закрыта уязвимость self-insert в household_members
- Убрана логика `auth.uid() = user_id` из INSERT policy.
- INSERT в `household_members` теперь только для owner соответствующего household.
- Прямой INSERT в `households` через RLS тоже закрыт (убрана policy).

### 2. Добавлен безопасный bootstrap
- SQL function `create_household_with_owner(p_name text)`:
  - `security definer`, `search_path = ''`
  - Создаёт household + membership (owner) атомарно.
  - Доступ: только `authenticated` (revoke from public/anon).

### 3. Submit стал атомарным
- SQL function `submit_recipe_by_token(...)`:
  - `SELECT ... FOR UPDATE` на recipe_requests — блокирует row.
  - В одной транзакции: проверка статуса/TTL → INSERT recipes → INSERT recipe_submissions → UPDATE status.
  - При гонке: второй запрос ждёт lock, получает status=fulfilled → exception.
  - Стабильные коды ошибок: `request_not_found`, `request_expired`, `request_already_fulfilled`, `request_not_pending`.
- Edge Function `submit-request` переписан: вызывает `rpc('submit_recipe_by_token')`, маппит PG exceptions в HTTP коды (404/409/410/500).

### 4. Multi-household в create-request
- Добавлен optional `household_id` во вход.
- Если передан — проверяется membership (403 если не участник).
- Если не передан и household один — используется.
- Если households несколько — 400 `household_id_required` + список ID.
- Если 0 — 404 как раньше.

### 5. Docs синхронизированы
- `roadmap.md`: R1 [done], R2 [current], добавлен R3 (Native MVP).
- `backlog.md`: P0 = delivery foundation, P1 = нативные клиенты.
- `current_state.md`: обновлён до актуального состояния.
- `backend_setup_supabase.md`: добавлены тесты self-join и concurrency.

### 6. Откачено случайное изменение прототипа
- `src/index.html`: revert изменения demo-данных (Мама→Папа).

## Артефакты
- `supabase/migrations/00002_fix_rls_and_atomic_submit.sql`
- `supabase/functions/submit-request/index.ts` (переписан)
- `supabase/functions/create-request/index.ts` (обновлён)
- `docs/roadmap.md`, `docs/backlog.md`, `docs/current_state.md`
- `docs/backend_setup_supabase.md`

## Что осталось
1. Деплой в Supabase dev project.
2. E2E тестирование всех сценариев по runbook.
3. Начать нативный клиент.

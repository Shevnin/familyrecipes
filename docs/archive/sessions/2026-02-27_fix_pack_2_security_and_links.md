# Сессия: Fix Pack #2 — Security + Link Contract + Error Hygiene

Дата: 2026-02-27

## Цель
Закрыть выявленные риски: RPC lockdown, link contract, error hygiene, CAPTCHA alignment.

## Что сделано

### 1. RPC Lockdown (P0)
- Новая миграция `00003_lockdown_rpc_and_link_contract.sql`.
- `revoke execute` на `submit_recipe_by_token` для `public`, `anon`, `authenticated`.
- Функция доступна только через service_role key (Edge Function).
- Добавлен SQL comment с пояснением.

### 2. Link Contract (P1)
- `create-request` теперь использует `APP_LINK_MODE` env:
  - `path` (default): `${APP_BASE_URL}/r/<token>` — для Cloudflare/Vercel с rewrite.
  - `query`: `${APP_BASE_URL}?token=<token>` — для GitHub Pages.
- `APP_BASE_URL` trailing slash нормализуется.
- Runbook обновлён с двумя пресетами.

### 3. Error Hygiene (P1)
- Все 3 Edge Functions: убраны `details` из публичных ответов.
- Internal errors → `console.error()` (server logs only).
- Стабильные коды: `create_request_failed`, `submit_failed`, `internal_error`.

### 4. CAPTCHA Alignment (P2)
- `web-reply/index.html`: добавлен `CAPTCHA_TOKEN` placeholder и отправка в payload если задан.
- Runbook: явный блокер — **не включать `CAPTCHA_SECRET` до интеграции Turnstile виджета**.
- Задокументировано ожидаемое поведение: 400 `captcha_required` если секрет задан без фронта.

### 5. Документация
- `current_state.md`: обновлён (миграция 00003, link mode, error hygiene, RPC lockdown).
- `backend_setup_supabase.md`: пресеты link mode, CAPTCHA blocker, тесты #8 (RPC lockdown) и #9 (error hygiene).

## Артефакты
- `supabase/migrations/00003_lockdown_rpc_and_link_contract.sql` (новый)
- `supabase/functions/create-request/index.ts` (обновлён)
- `supabase/functions/submit-request/index.ts` (обновлён)
- `supabase/functions/get-request-meta/index.ts` (обновлён)
- `web-reply/index.html` (обновлён)
- `docs/current_state.md` (обновлён)
- `docs/backend_setup_supabase.md` (обновлён)

## Что осталось
1. Деплой в Supabase dev + E2E full flow.
2. iOS skeleton (SwiftUI): auth + рецепты + запрос + share.

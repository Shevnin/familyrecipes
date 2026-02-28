# Current State (Session Handoff)

Обновлено: 2026-02-28

## Фаза
- Текущая фаза: **Delivery (Native MVP)**
- Stage-Gate этап: **5) Delivery Start (Native Mobile + Backend) [in progress]**
- Roadmap: **R3 - Native MVP [current]**
- Backend: Supabase dev развернут и стабилизирован.
- iOS: v1 работает на реальном устройстве (auth + create request + share).
- Android: ещё не начат.

## Где остановились
- Последняя сессия: `docs/sessions/2026-02-28_ios01_ios02_recipes.md`
- IOS-01 и IOS-02 готовы: список рецептов с real data + detail view.

## Архитектура MVP
- **Повар** (Master): нативное приложение (iOS/Android), auth через Supabase.
- **Донор**: zero-install, mobile web по ссылке из мессенджера.
- **Flow**: Request in app -> link in messenger -> donor web submit -> recipe in app.

## Backend (Supabase) — DEPLOYED
- Project ref: `wlxtobrxqytnmpifbnev`
- URL: `https://wlxtobrxqytnmpifbnev.supabase.co`
- Конфиг: `supabase/config.toml`
- Миграции:
  - `00001_init.sql` — базовая схема, RLS.
  - `00002_fix_rls_and_atomic_submit.sql` — bootstrap + atomic submit.
  - `00003_lockdown_rpc_and_link_contract.sql` — revoke прямого RPC-доступа клиентам.
  - `00004_grant_service_role_rpc.sql` — grant execute RPC для `service_role`.
- Edge Functions (deploy с `--no-verify-jwt`):
  - `create-request` (auth) — `token`, `web_url`, `share_text`.
  - `get-request-meta` (public) — статус запроса по токену.
  - `submit-request` (public) — атомарный submit через SQL RPC.
- Link contract:
  - `APP_BASE_URL=https://shevnin.github.io/familyrecipes`
  - `APP_LINK_MODE=query`
  - ссылка: `https://shevnin.github.io/familyrecipes/web-reply/?token=<token>`
- Guest web: `web-reply/index.html` live на GitHub Pages.
- Runbook: `docs/backend_setup_supabase.md`

## iOS App
- Путь: `apps/ios/FamilyRecipes/FamilyRecipes/`
- Stack: SwiftUI + URLSession, без SPM.
- Конфиг: `Config.plist` (gitignored), template `Config.example.plist`.
- Статус v1:
  - Login (email/password) через Supabase Auth REST API.
  - Session persistence в **Keychain**.
  - Auto-refresh токена + retry на 401 при create-request.
  - Auto-bootstrap household при первом логине.
  - Create Request -> Edge Function -> Share Sheet.
  - Logout с подтверждением.
  - Список рецептов (real data, pull-to-refresh, loading/empty/error).
  - Карточка рецепта (detail view: title, author, date, original_text).
  - Retry-on-401 для fetchRecipes (pre-flight JWT check + 1 retry).
  - App icon добавлен в `Assets.xcassets/AppIcon.appiconset`.
- README: `apps/ios/README.md`

## Прототипы (discovery, reference only)
1. `src/index.html` — split-screen demo.
2. `web-mobile/index.html` — mobile web prototype.

## Что сейчас в приоритете (P0)
1. ~~`IOS-01` Список рецептов (real data, refresh, loading/empty/error).~~ [done]
2. ~~`IOS-02` Карточка рецепта (detail screen из списка).~~ [done]
3. `IOS-03` Список запросов (history + статусы).
4. `IOS-04` Редизайн success-экрана после create-request.
5. `ANDROID-SPEC-01` Зеркально зафиксировать parity-спеку для Android по `IOS-01...IOS-04`.
6. Прогнать full E2E на реальных устройствах после задач `IOS-01...IOS-04`.

## Первый шаг в новой сессии
1. Прочитать этот файл.
2. Прочитать `docs/sessions/2026-02-28_ios01_ios02_recipes.md`.
3. Прочитать `apps/ios/README.md`.
4. Взять `IOS-03` как следующий инкремент.

## Технический контекст
- Branch: `main`
- Backend: Supabase (PostgreSQL 17 + Deno Edge Functions)
- Auth: Supabase Auth (email/password; Google/Apple позже)
- JWT: ES256 -> функции деплоятся с `--no-verify-jwt`, auth валидируется внутри функций
- Storage: PostgreSQL + RLS (default deny)
- Submit consistency: атомарный SQL RPC `submit_recipe_by_token` с row lock
- Guest web: `web-reply/index.html` (mobile-first)
- Anti-abuse: optional Turnstile (`CAPTCHA_SECRET`), пока не включен в prod
- Error hygiene: API не возвращает internal details клиенту

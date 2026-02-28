# Current State (Session Handoff)

Обновлено: 2026-02-28

## Фаза
- Текущая фаза: **Delivery (Native MVP)**
- Stage-Gate этап: **5) Delivery Start (Native Mobile + Backend) [in progress]**
- Roadmap: **R3 - Native MVP [current]**
- Backend: Supabase dev развернут и стабилизирован.
- iOS: R3 slice закрыт (IOS-01...IOS-08). Готово к E2E.
- Android: ещё не начат.

## Где остановились
- Последняя сессия: `docs/sessions/2026-02-28_ios_r3_completion.md`
- IOS-01...IOS-08 все реализованы.

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
- Статус:
  - Login (email/password) через Supabase Auth REST API.
  - Session persistence в **Keychain**.
  - Auto-refresh токена + retry на 401 (все запросы).
  - Auto-bootstrap household при первом логине.
  - Create Request -> Edge Function -> Share Sheet.
  - Logout с подтверждением.
  - Список рецептов (real data, pull-to-refresh, loading/empty/error).
  - Карточка рецепта (detail view: title, author, date, original_text).
  - Inline history запросов на экране "Запросить" (IOS-03).
  - Redesigned success state с "Что дальше" (IOS-04).
  - Цветные чипы "Уже просили у..." (IOS-04).
  - Личные заметки к рецептам (local, IOS-05).
  - Создание своих рецептов через "+" (IOS-06).
  - "Попросить уточнить" на карточке рецепта (IOS-07).
  - "Моя семья и друзья" в настройках (IOS-08).
  - App icon добавлен в `Assets.xcassets/AppIcon.appiconset`.
- Local persistence:
  - `UserDefaults` JSON: contacts, recipe notes, link cache.
  - `Keychain`: auth tokens.
- README: `apps/ios/README.md`

## Прототипы (discovery, reference only)
1. `src/index.html` — split-screen demo.
2. `web-mobile/index.html` — mobile web prototype.

## Что сейчас в приоритете (P0)
1. ~~`IOS-01`...`IOS-08`~~ [все done]
2. `ANDROID-SPEC-01/02/03/04` Зеркально зафиксировать parity-спеку для Android.
3. Full E2E на реальных устройствах после iOS R3.
4. `BE-SPEC-02` + `BE-IMPL-02` (server storage контактов/chips в Supabase).

## Первый шаг в новой сессии
1. Прочитать этот файл.
2. Прочитать `docs/sessions/2026-02-28_ios_r3_completion.md`.
3. Прочитать `apps/ios/README.md`.
4. Собрать iOS и прогнать E2E.

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
- Contacts/chips: local storage (UserDefaults) до выполнения `BE-SPEC-02/BE-IMPL-02`.

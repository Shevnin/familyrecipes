# Current State (Session Handoff)

Обновлено: 2026-03-21

## Фаза
- Текущая фаза: **Delivery (Native MVP)**
- Stage-Gate этап: **5) Delivery Start (Native Mobile + Backend) [in progress]**
- Roadmap: **R3 - Native MVP [current]**
- Backend: Supabase dev развернут и стабилизирован.
- iOS: R3 slice закрыт (IOS-01...IOS-08). Готово к E2E.
- Android: ещё не начат.

## Где остановились
- Последняя активная сессия: `docs/sessions/2026-03-21_BE_SPEC_04_unified_card_read_model.md`
- IOS-01...IOS-08 все реализованы.
- **Unified card model реализован** (BE-SPEC-04, BE-IMPL-04, LIST-01, LIST-02, REQ-09, DETAIL-10, CARD-DELETE-01):
  - Backend: миграция `00005_unified_card_model.sql` (recipe_story, hidden_at, parent_recipe_id, VIEW `family_recipe_cards`).
  - Edge Function `create-request` обновлена: принимает `recipe_story` и `parent_recipe_id`.
  - iOS: единый список карточек (pending + received), статусные бейджи, скрытые даты, поле `история рецепта` в request flow, блок `история рецепта` в detail, удаление карточки с подтверждением.
- После просмотра живой сборки принят новый direction для вкладки "Запросить рецепт":
  - убрать `история рецепта` из primary request UI;
  - `Кому отправить?` сделать редактируемым выпадающим списком;
  - `Какой рецепт?` переименовать в `Название рецепта`;
  - CTA = `Получить ссылку`;
  - ссылку показывать inline на том же экране, без отдельного success-state;
  - под ссылкой: `Копировать`, пояснение и кнопка `Сформировать новый запрос`.
- Android находится на старте реализации (`ANDROID-01`). Parity notes для unified card model: `docs/sessions/2026-03-21_android_unified_card_parity_notes.md`.
- Сформирован Donor conversion backlog (`DONOR-01...DONOR-11`), реализация после Android parity.
- Принят новый продуктовый контракт донора: ответ донора = `recipe_text` + `donor_comment` (два текстовых поля). Реализация ещё pending.

## Архитектура MVP
- **Повар** (Master): нативное приложение (iOS/Android), auth через Supabase.
- **Донор**: zero-install, mobile web по ссылке из мессенджера.
- **Flow**: Request in app -> link in messenger -> donor web submit -> recipe in app.
- Целевой donor contract (pending implementation): `recipe_text` + `donor_comment`.

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
- Edge Functions (deploy с `--no-verify-jwt`):
  - `create-request` (auth) — `token`, `web_url`, `share_text`.
  - `get-request-meta` (public) — статус запроса по токену.
  - `submit-request` (public) — атомарный submit через SQL RPC.
- Важно: задеплоенный public contract пока ещё **v1** (`original_text` как одно поле). Новый contract `recipe_text + donor_comment` ещё не внедрён.
- `create-request` обновлена: принимает опциональные `recipe_story` и `parent_recipe_id`.
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
  - Create Request -> Edge Function -> inline link result.
  - Logout с подтверждением.
  - Список рецептов (real data, pull-to-refresh, loading/empty/error).
  - Единый список карточек семейных рецептов (pending + received + clarification).
  - Inline history запросов на экране "Запросить".
  - Упрощённый request flow: editable dropdown для получателя, `Название рецепта`, CTA `Получить ссылку`, inline link + `Копировать` (REQ-10...REQ-18).
  - Личные заметки к рецептам (local, IOS-05).
  - Создание своих рецептов через "+" (IOS-06).
  - "Попросить уточнить" на карточке рецепта (IOS-07).
  - "Моя семья и друзья" в настройках (IOS-08).
  - App icon добавлен в `Assets.xcassets/AppIcon.appiconset`.
  - Поле `история рецепта` в create-request flow (REQ-09) реализовано, но больше не считается целевым primary flow.
  - Блок `история рецепта` в detail screen (DETAIL-10).
  - Удаление карточки с confirmation dialog (CARD-DELETE-01).
  - Даты скрыты из primary list/detail UI (LIST-02).
  - Shared `RecipesViewModel` как единый source of truth для списка рецептов и истории запросов. Delete из одного места сразу убирает карточку отовсюду. Старый `RecipeRequest` model и `fetchRequestHistory` удалены.
- Product/design target for next donor iteration:
  - donor reply = `recipe_text` + `donor_comment`
  - recipe detail should evolve toward `author + donor text + donor comment + personal note`
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
7. Request flow simplification pack: `REQ-10...REQ-18`.
8. Donor conversion pack: `DONOR-01...DONOR-04`, затем `DONOR-11`.
9. Donor reply contract v2: `DONOR-12` + `BE-SPEC-03` + `BE-IMPL-03` + detail parity updates.
10. `BE-SPEC-02` + `BE-IMPL-02` (server storage контактов/chips в Supabase) только если сохраняется подтвержденная cross-device необходимость.

## Первый шаг в новой сессии
1. Прочитать этот файл.
2. Прочитать `docs/sessions/2026-03-01_android_master_task_pack.md`.
3. Прочитать `docs/sessions/2026-03-21_android_unified_card_parity_notes.md` (unified card model parity).
4. Прочитать `apps/ios/README.md` (как reference parity).
5. Стартовать `ANDROID-01` и идти последовательно до `ANDROID-BUILD-01`, учитывая unified card model.

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
- Donor reply contract: deployed code still uses single-field `original_text`; product docs now target two-field reply (`recipe_text` + `donor_comment`).
- Product priority clarified on 2026-03-21: after Android parity we optimize the donor loop first, and only then move supporting local data like contacts/chips to backend if still justified.
- Additional product clarification on 2026-03-21: requests and recipes should converge into one family-recipe card model with statuses; primary UI should hide dates and support delete + `recipe_story`.

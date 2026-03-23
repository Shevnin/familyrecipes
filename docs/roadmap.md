# Roadmap

Статус: обновлён 2026-03-21.

## R0 - Problem/Solution Fit [done]
Цель: выбрать один главный пользовательский сценарий и подтвердить ценность.

Результат:
- Сформирован `product_brief.md` — два режима (передатчик/мастер), двойное хранение рецепта.
- Выбран top flow: мама набирает рецепт → отправляет → сын видит оригинал + структурированную версию.

## R1 - Split Screen Prototype [done]
Цель: рабочий прототип top flow, доступный по URL.

Что сделано:
- `src/index.html` — split screen (два телефонных экрана: Передатчик + Мастер).
- `web-mobile/index.html` — mobile-first web-app (основной прототип).
- Деплой на GitHub Pages.
- Эвристический парсер маминого текста → структурированная версия.
- Запрос рецепта по ссылке через localStorage.
- Editorial Premium дизайн (Modern Heritage).

## R2 - Delivery Foundation [done]
Цель: backend foundation + guest web flow.

Что сделано:
- Supabase backend: схема БД (6 таблиц), RLS (default deny), Edge Functions.
- Атомарный submit через SQL function (race-safe, `SELECT ... FOR UPDATE`).
- Bootstrap household: `create_household_with_owner()`.
- Multi-household поддержка в create-request.
- Share-link contract: `token`, `web_url`, `share_text`.
- Guest donor web page: `web-reply/index.html` (mobile-first, zero-install).
- Optional CAPTCHA hook (Cloudflare Turnstile).

## R3 - Native MVP [current]
Цель: рабочий нативный клиент (iOS или Android first) с backend.

Уточнённый фокус R3:
- Сначала закрываем **functional parity** текущего native MVP на Android.
- Затем приводим клиентскую модель к одной сущности `семейный рецепт`:
  - единый список вместо раздельных списков запросов и рецептов;
  - скрытые даты;
  - удаление карточки.
- Затем упрощаем request flow:
  - без поля `история рецепта`;
  - `Кому отправить?` как редактируемый выпадающий список;
  - `Название рецепта` вместо `Какой рецепт?`;
  - CTA `Получить ссылку`;
  - inline link result без отдельного success screen.
- Затем усиливаем **core donor loop**:
  - повысить вероятность submit;
  - перейти на `recipe_text + donor_comment`;
  - показать donor comment отдельно в detail.
- Supporting infrastructure задачи делаем после этого, если они не блокируют core loop.

Прогресс:
- [done] Backend deployed to Supabase dev (migrations + Edge Functions + secrets).
- [done] E2E smoke tests passed (6/6).
- [done] iOS app v1: auth + create request + share sheet.
- [done] web-reply deployed to GitHub Pages (`/web-reply/?token=...`).
- [done] Security hardening after smoke: restored atomic RPC submit, no auth detail leak in API errors.
- [done] iOS auth security pass: Keychain token storage + removed token debug logs.
- [done] iOS recipes list + recipe detail (`IOS-01`, `IOS-02`).
- [done] iOS inline request history on "Запросить" (`IOS-03`).
- [done] iOS request flow redesign + chips (`IOS-04`).
- [done] iOS recipe comments (`IOS-05`).
- [done] iOS create own recipe (`IOS-06`).
- [done] iOS CTA "Попросить уточнить" (`IOS-07`).
- [done] iOS Settings -> "Моя семья и друзья" + color chips (`IOS-08`).
- [todo] Android implementation pack `ANDROID-01...ANDROID-08` (Compose parity with iOS slice).
- [todo] Android device build validation (`ANDROID-BUILD-01`).
- [todo] Full E2E on real devices (iOS + Android + web-reply).
- [done] Unified recipe card model (BE-SPEC-04, BE-IMPL-04, LIST-01/02, REQ-09, DETAIL-10, CARD-DELETE-01):
  - backend: migration 00005, VIEW `family_recipe_cards`, Edge Function update
  - iOS: one combined list, statuses, hidden dates, delete with confirmation
  - `recipe_story` field in DB schema — **filled by donor on web-reply**, shown read-only on detail
  - migration 00006: `submit_recipe_by_token` accepts `p_recipe_story` from donor
  - Android parity notes prepared
- [done] Request flow simplification pack (REQ-10...REQ-18):
  - `recipe_story` removed from chef request UI (it's a donor field)
  - editable dropdown for `Кому отправить?`
  - rename `Какой рецепт?` → `Название рецепта`
  - primary CTA `Получить ссылку`
  - inline link result + `Копировать` (micro-feedback) + explanation + `Сформировать новый запрос`
- [done] `DONOR-07` post-submit edit flow: migration 00007, edge functions `get-edit-meta` + `update-submitted-recipe`, web-reply edit mode via `?edit_token=`, 72h window, CTA `Исправить рецепт`
- [todo] Donor conversion pack after Android parity:
  - `DONOR-01` share text v2
  - `DONOR-02` onboarding block
  - `DONOR-03` modes `Коротко / Подробно`
  - `DONOR-04` draft autosave
- [todo] Donor reply contract v2 after donor conversion pack:
  - `DONOR-12`
  - `BE-SPEC-03`
  - `BE-IMPL-03`
  - `IOS-09`
  - `ANDROID-09`
- [done] Mastery loop package `REPEAT-LOOP-01` (iOS + backend, 2026-03-23):
  - migration `00008_mastery_loop.sql`: table `recipe_attempts`, RLS, updated VIEW `family_recipe_cards` with mastery read-model
  - Edge Function `log-cook-attempt`: auth, household validation, append-only insert, mastery response
  - `IOS-10` MasteryBlock on detail screen: cook_count, mastery_status badge, latest post-cook note, CTA
  - `IOS-11` PostCookSheet: result picker (failed/partial/success) + optional note, saves to backend
  - `IOS-12` Contextual clarification CTA after failed/partial attempt (reuses existing clarification flow)
  - mastery badge in recipe list row (subtle icon for received cards with attempts)
- [done] `TECHNIQUES-01` content_kind package (iOS + backend + donor web, 2026-03-23):
  - migration `00009_content_kind.sql`: `content_kind` column on `recipes` + `recipe_requests` (CHECK 'recipe'|'technique', DEFAULT 'recipe'), updated VIEW + RPC
  - Edge Functions: `create-request` accepts `content_kind`, `get-request-meta` returns it, `get-edit-meta` returns it from recipe record
  - donor web form: copy adapts to `content_kind` (labels, button, success/fulfilled states, about block)
  - iOS: `FamilyRecipeCard.contentKind`, segmented control (Рецепты / Техники) in RecipesView, type picker in CreateRequestView, `CreateRecipeView(contentKind:)`, adapted copy in detail/mastery/postcook
  - clarification flow preserves `content_kind` through `RequestDraft`
- [todo] Android mastery loop parity (`ANDROID-MASTERY-01`) — backend ready, iOS is reference
- [todo] Android techniques parity (`ANDROID-TECHNIQUES-01`) — after Android main parity
- [todo] Backend contacts storage (`BE-SPEC-02` -> `BE-IMPL-02`) после donor loop upgrade, если по-прежнему нужно.

Инициативы:
- iOS SwiftUI app: auth, список рецептов, создание запроса, share.
- Android Compose app: то же.
- Реальная связка мама ↔ сын (разные устройства, guest web).
- Unified family recipe list with statuses instead of separate request/recipe sections.
- Donor conversion improvements в zero-install web flow.
- Donor post-submit correction flow: limited-time edit after successful submit, without login.
- Donor reply v2: основной текст рецепта + отдельный личный комментарий донора.
- Mastery loop: повторные попытки, короткая post-cook note, progress toward `замастерил`, contextual clarification.
- Читаемое recipe detail experience с акцентом на оригинальный текст и личную заметку.
- Push-уведомления о выполненном запросе.

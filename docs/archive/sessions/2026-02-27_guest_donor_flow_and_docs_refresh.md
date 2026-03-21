# Сессия: Guest Donor Flow + Full Docs Refresh

Дата: 2026-02-27

## Цель
Production-подобный guest web flow по ссылке + полная синхронизация документации.

## Что сделано

### 1. Share-link contract (create-request)
- Ответ расширен: `token`, `web_url`, `share_text`.
- `share_text` — готовый текст для мессенджера: `"{recipient_name}, поделитесь рецептом "{dish_name}"!\n{web_url}"`.
- Нативный клиент сможет использовать `share_text` для системного share sheet.

### 2. Guest donor web page (web-reply/index.html)
- Новый артефакт: `web-reply/index.html`.
- Mobile-first, Editorial Premium стиль (Fraunces + Manrope).
- 6 состояний UI: loading, not_found, expired, fulfilled, form, success.
- Поддержка token из path (`/r/<token>`) и query (`?token=<token>`).
- Prefill: `submitted_by_name` = `recipient_name`, `recipe_title` = `dish_name`.
- Disable кнопки во время submit.
- Controlled errors без утечки внутренних деталей.
- One-time submit: после 201 → success, повторный 409 → "уже отправлен".
- API URL конфигурируется через `DEFAULT_API` или `?api=...` query param.

### 3. Anti-abuse (submit-request)
- Optional Cloudflare Turnstile CAPTCHA.
- Включается через env `CAPTCHA_SECRET`.
- Если секрет не задан — работает без captcha (dev mode).
- Если задан и `captcha_token` не передан — 400 `captcha_required`.
- Если проверка не пройдена — 403 `captcha_failed`.

### 4. Full Docs Refresh (8 файлов)
Все docs приведены к единому состоянию:
- **README.md**: обновлён — delivery фаза, архитектура MVP, donor zero-install.
- **product_brief.md**: добавлена секция "MVP модель взаимодействия" — повар в нативном app, донор через web.
- **workflow.md**: discovery завершена, delivery current, stage-gate обновлён.
- **roadmap.md**: R2 done, R3 Native MVP current.
- **backlog.md**: P0 = деплой + E2E + iOS skeleton.
- **decisions.md**: 5 новых решений (zero-install donor, guest web, share contract, CAPTCHA).
- **current_state.md**: актуальное состояние, архитектура MVP, P0 приоритеты.
- **backend_setup_supabase.md**: full flow test (телефон + мессенджер), деплой web-reply (3 варианта).

### 5. Backend hardening (из Fix Pack #1, уже было сделано)
- Self-insert в household_members закрыт.
- Bootstrap: `create_household_with_owner()`.
- Atomic submit: `submit_recipe_by_token()`.
- Multi-household в create-request.

## Артефакты
- `web-reply/index.html` (новый)
- `supabase/functions/create-request/index.ts` (обновлён: share contract)
- `supabase/functions/submit-request/index.ts` (обновлён: CAPTCHA hook)
- `docs/README.md` (обновлён)
- `docs/product_brief.md` (обновлён)
- `docs/workflow.md` (обновлён)
- `docs/roadmap.md` (обновлён)
- `docs/backlog.md` (обновлён)
- `docs/decisions.md` (обновлён)
- `docs/current_state.md` (обновлён)
- `docs/backend_setup_supabase.md` (обновлён)

## Что осталось
1. Создать Supabase dev project, задеплоить миграции + функции.
2. Задеплоить `web-reply/` (выбрать хостинг, задать `DEFAULT_API`).
3. E2E full flow test (телефон + мессенджер).
4. iOS клиент skeleton (SwiftUI): auth + рецепты + запрос + share.

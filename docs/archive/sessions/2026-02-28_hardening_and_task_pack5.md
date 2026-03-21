# Сессия: Hardening + Task Pack 5 + docs sync

Дата: 2026-02-28

## Что сделано

1. **Backend hardening после dev deploy**
- Восстановлен атомарный `submit-request` через SQL RPC `submit_recipe_by_token`.
- Зафиксирован корректный link contract:
  - `APP_BASE_URL` = root сайта,
  - query mode = `/web-reply/?token=<token>`.
- Убрана утечка auth details из ответов `create-request`.

2. **Task Pack 5 (security/docs hygiene)**
- iOS токены перенесены в Keychain (`KeychainStore`), legacy `UserDefaults` очищается.
- Убраны debug-логи с JWT фрагментами и raw body ошибок.
- Runbook (`docs/backend_setup_supabase.md`) синхронизирован: `apikey` добавлен в проблемные curl-примеры.
- Добавлены `#if canImport(UIKit)` guards для UIKit-частей в `CreateRequestView`.

3. **Реальное устройство**
- Приложение запущено на iPhone (signing/dev mode/trust пройдены).
- Flow `create request -> share -> web submit` работает.
- Выявлено текущее ограничение: список рецептов в iOS пока заглушка.

4. **UI/brand**
- Добавлен `AppIcon` в `Assets.xcassets/AppIcon.appiconset`.

## Итоговое состояние
- Backend и web-reply готовы для полевого E2E.
- iOS v1 рабочий для auth + create-request + share.
- Главный следующий шаг: реализовать recipes list в iOS (fetch из Supabase).

## Следующий Task Pack
**Task Pack 6 — iOS Recipes List**
1. Запрос `recipes` из Supabase REST с `Authorization` + `apikey`.
2. Состояния `loading/empty/error/data`.
3. Pull-to-refresh.
4. После этого — повторный full E2E на реальных устройствах.

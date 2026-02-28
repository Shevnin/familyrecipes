# Backlog

Формат:
- `P0` = критично для текущей фазы (R3 — Native MVP)
- `P1` = важно, но после P0
- `P2` = позже

## P0
1. ~~Supabase backend: схема, RLS, Edge Functions.~~ [done]
2. ~~Atomic submit (race-safe SQL function).~~ [done]
3. ~~Fix RLS: закрыть self-insert в household_members.~~ [done]
4. ~~Bootstrap: create_household_with_owner().~~ [done]
5. ~~Multi-household поддержка в create-request.~~ [done]
6. ~~Share-link contract (token, web_url, share_text).~~ [done]
7. ~~Guest donor web page (web-reply/).~~ [done]
8. ~~Optional CAPTCHA hook.~~ [done]
9. ~~Создать Supabase dev project и задеплоить.~~ [done]
10. ~~E2E тестирование full flow (app → messenger → web-reply → app).~~ [done — smoke 6/6]
11. ~~iOS клиент skeleton (SwiftUI): auth + создание запроса + share.~~ [done]
12. ~~Задеплоить web-reply/ на GitHub Pages.~~ [done]
13. ~~`IOS-01` Список рецептов (real data): fetch `recipes` из Supabase, состояния `loading/empty/error`, pull-to-refresh.~~ [done]
14. ~~`IOS-02` Карточка рецепта: тап по рецепту из списка открывает detail screen (title, author, original text, created_at).~~ [done]
15. `IOS-03` Список запросов (request history): экран со статусами `pending/fulfilled/expired`, сортировка по дате (новые сверху).
16. `IOS-04` Редизайн success-экрана после create-request: понятный блок "что дальше", ссылка, `Share`, `Copy`, переход в список запросов.
17. `ANDROID-SPEC-01` Зафиксировать parity-спеку для Android (Compose) по `IOS-01...IOS-04` без реализации кода.
18. Full E2E на реальных устройствах (iPhone + мессенджер + web-reply в браузере) после `IOS-01...IOS-04`.

## P0 Acceptance (для iOS и Android parity)
- `IOS-01 / ANDROID-SPEC-01`: после submit через web-reply рецепт отображается в списке после refresh.
- `IOS-02 / ANDROID-SPEC-01`: из списка открывается detail карточка рецепта без потери контекста навигации.
- `IOS-03 / ANDROID-SPEC-01`: новый запрос сразу виден в истории запросов с корректным статусом.
- `IOS-04 / ANDROID-SPEC-01`: success-экран не "тупик"; пользователь сразу понимает следующий шаг и может поделиться ссылкой повторно.

## Android parity scope (документация, без кода)
1. `ANDROID-UI-01` Recipes List: те же состояния (`loading/empty/error/data`) и сортировка, что в `IOS-01`.
2. `ANDROID-UI-02` Recipe Detail Card: тот же набор полей и навигационный возврат, что в `IOS-02`.
3. `ANDROID-UI-03` Request History: те же статусы и порядок сортировки, что в `IOS-03`.
4. `ANDROID-UI-04` Create Request Success: те же действия (`Share`, `Copy`, переход в Request History), что в `IOS-04`.

## P1
1. Android клиент (Jetpack Compose) — то же что iOS.
2. Режим готовки (пошаговый вид).
3. Редактирование структурированной версии.
4. Уведомление о выполненном запросе.
5. Google/Apple Sign-In.
6. История запросов (request list) в iOS app.

## P2
1. Голосовой ввод для донора.
2. Импорт фото блокнота.
3. Push-уведомления.
4. Метрики после запуска MVP.
5. Turnstile CAPTCHA включение в production.

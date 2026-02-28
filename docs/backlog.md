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
15. ~~`IOS-03` Список запросов (request history) на **той же странице "Запросить"**.~~ [done]
16. ~~`IOS-04` Редизайн флоу "Запросить рецепт" (чипы + success redesign).~~ [done]
17. `ANDROID-SPEC-01` Зафиксировать parity-спеку для Android (Compose) по `IOS-01...IOS-04` без реализации кода.
18. Full E2E на реальных устройствах (iPhone + мессенджер + web-reply в браузере) после `IOS-01...IOS-04`.
19. ~~`IOS-05` Комментарии к рецептам (personal notes, local persistence).~~ [done]
20. ~~`IOS-06` Создание своих рецептов (форма + POST /rest/v1/recipes).~~ [done]
21. `ANDROID-SPEC-02` Parity-спека для `IOS-05` и `IOS-06` (комментарии и создание своих рецептов) без реализации кода.
22. `BE-SPEC-01` Backend-спека для recipe comments: таблица/политики/RLS/контракт API.
23. ~~`IOS-07` "Попросить уточнить" CTA на карточке рецепта (prefilled request).~~ [done]
24. `ANDROID-SPEC-03` Parity-спека для `IOS-07` (аналогичная кнопка и prefilled request flow).
25. ~~`IOS-08` Настройки "Моя семья и друзья" (CRUD контактов, цветные чипы, local persistence).~~ [done]
26. `ANDROID-SPEC-04` Parity-спека для `IOS-08` (аналогичный список контактов + чипы в request flow).
27. `BE-SPEC-02` Backend-спека для contacts/chips (таблица, RLS, API-контракт, миграции) — **deferred** после завершения `IOS-03...IOS-08`.
28. `BE-IMPL-02` Реализация server storage для contacts/chips в Supabase (миграции + RLS + доступ из iOS/Android) — **deferred** после `BE-SPEC-02`.

## P0 Acceptance (для iOS и Android parity)
- `IOS-01 / ANDROID-SPEC-01`: после submit через web-reply рецепт отображается в списке после refresh.
- `IOS-02 / ANDROID-SPEC-01`: из списка открывается detail карточка рецепта без потери контекста навигации.
- `IOS-03 / ANDROID-SPEC-01`: новый запрос сразу виден в истории запросов на той же странице "Запросить" с корректным статусом.
- `IOS-04 / ANDROID-SPEC-01`: success-экран не "тупик"; пользователь сразу понимает следующий шаг и может поделиться ссылкой повторно.
- `IOS-04 / ANDROID-SPEC-01`: если уже были запросы, пользователь видит блок подсказок с чипами получателей и может в 1 тап переиспользовать имя.
- `IOS-05 / ANDROID-SPEC-02`: комментарий к рецепту сохраняется и отображается при повторном открытии рецепта.
- `IOS-06 / ANDROID-SPEC-02`: созданный вручную рецепт сразу появляется в общем списке рецептов.
- `IOS-07 / ANDROID-SPEC-03`: из карточки рецепта можно в 1-2 тапа отправить запрос на уточнение автору рецепта.
- `IOS-08 / ANDROID-SPEC-04`: пользователь может управлять списком контактов в "Моя семья и друзья", и эти контакты доступны как чипы в "Запросить рецепт".
- `IOS-08 / ANDROID-SPEC-04`: чипы контактов цветные и визуально различимы; цвет контакта повторяемый между сессиями.

## Android parity scope (документация, без кода)
1. `ANDROID-UI-01` Recipes List: те же состояния (`loading/empty/error/data`) и сортировка, что в `IOS-01`.
2. `ANDROID-UI-02` Recipe Detail Card: тот же набор полей и навигационный возврат, что в `IOS-02`.
3. `ANDROID-UI-03` Request History на экране "Запросить": те же статусы, сортировка и quick actions (`Share`/`Copy`), что в `IOS-03`.
4. `ANDROID-UI-04` Create Request flow redesign: success-действия (`Share`, `Copy`, переход/скролл к истории запросов) + блок чипов "Уже просили у..." в форме запроса.
5. `ANDROID-UI-05` Recipe comments: добавить/редактировать личный комментарий к рецепту.
6. `ANDROID-UI-06` Create own recipe: форма создания своего рецепта и мгновенное появление в списке.
7. `ANDROID-UI-07` Recipe clarification request: на detail-карточке CTA "Попросить уточнить" с prefilled request формой.
8. `ANDROID-UI-08` Family & Friends contacts: CRUD контактов в Settings и цветные чипы (стабильный цвет на контакт) для быстрого выбора получателя в request flow.

## P1
1. Android клиент (Jetpack Compose) — то же что iOS.
2. Режим готовки (пошаговый вид).
3. Редактирование структурированной версии.
4. Уведомление о выполненном запросе.
5. Google/Apple Sign-In.
6. Фильтры/поиск по истории запросов в iOS app.

## P2
1. Голосовой ввод для донора.
2. Импорт фото блокнота.
3. Push-уведомления.
4. Метрики после запуска MVP.
5. Turnstile CAPTCHA включение в production.

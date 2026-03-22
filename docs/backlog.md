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
17. `ANDROID-SPEC-01` Зафиксировать parity-спеку для Android (Compose) по `IOS-01...IOS-04` без реализации кода. [done, replaced by `ANDROID-01...08` implementation pack]
18. Full E2E на реальных устройствах (iPhone + мессенджер + web-reply в браузере) после `IOS-01...IOS-04`.
19. ~~`IOS-05` Комментарии к рецептам (personal notes, local persistence).~~ [done]
20. ~~`IOS-06` Создание своих рецептов (форма + POST /rest/v1/recipes).~~ [done]
21. `ANDROID-SPEC-02` Parity-спека для `IOS-05` и `IOS-06` (комментарии и создание своих рецептов) без реализации кода. [done, replaced by `ANDROID-01...08` implementation pack]
22. `BE-SPEC-01` Backend-спека для recipe comments: таблица/политики/RLS/контракт API.
23. ~~`IOS-07` "Попросить уточнить" CTA на карточке рецепта (prefilled request).~~ [done]
24. `ANDROID-SPEC-03` Parity-спека для `IOS-07` (аналогичная кнопка и prefilled request flow). [done, replaced by `ANDROID-01...08` implementation pack]
25. ~~`IOS-08` Настройки "Моя семья и друзья" (CRUD контактов, цветные чипы, local persistence).~~ [done]
26. `ANDROID-SPEC-04` Parity-спека для `IOS-08` (аналогичный список контактов + чипы в request flow). [done, replaced by `ANDROID-01...08` implementation pack]
27. `ANDROID-01` Android app skeleton (Jetpack Compose): auth + tabs + session restore.
28. `ANDROID-02` Recipes list + recipe detail (parity with `IOS-01/02`).
29. `ANDROID-03` Inline request history on "Запросить" screen (parity with `IOS-03`).
30. `ANDROID-04` Request flow redesign + success actions + chips (parity with `IOS-04`).
31. `ANDROID-05` Recipe comments (parity with `IOS-05`).
32. `ANDROID-06` Create own recipe (parity with `IOS-06`).
33. `ANDROID-07` Recipe detail CTA "Попросить уточнить" (parity with `IOS-07`).
34. `ANDROID-08` Settings -> "Моя семья и друзья" + color chips (parity with `IOS-08`).
35. `ANDROID-BUILD-01` Собрать debug APK/AAB и проверить установку на реальном Android устройстве.
36. ~~`LIST-01` Единый список карточек семейных рецептов: pending-запросы и полученные рецепты отображаются вместе, с разными статусами и CTA.~~ [done — iOS]
37. ~~`LIST-02` Скрыть даты из primary list/detail UI; приоритет у названия, автора, статуса и контекста.~~ [done — iOS]
38. ~~`REQ-09` Добавить поле `история рецепта` в create-request flow.~~ [done → **obsoleted**: recipe_story теперь заполняется донором на web-reply, не поваром. Поле удалено из request flow повара.]
39. ~~`DETAIL-10` Показать `история рецепта` отдельным блоком на detail screen.~~ [done — iOS, read-only блок показывает recipe_story, заполненный донором]
40. ~~`CARD-DELETE-01` Добавить удаление карточки семейного рецепта в iOS и Android UI.~~ [done — iOS; Android pending]
41. ~~`BE-SPEC-04` Backend-спека для unified recipe card read-model + delete contract + `recipe_story`.~~ [done]
42. ~~`BE-IMPL-04` Реализация unified recipe card read-model + delete + `recipe_story` (donor field) в Supabase/Edge Functions/read queries.~~ [done]
43. ~~`REQ-10` Убрать поле `история рецепта` из primary request flow.~~ [done]
44. ~~`REQ-11` Поле `Кому отправить?` сделать редактируемым выпадающим списком.~~ [done]
45. ~~`REQ-12` Синхронизировать редактирование контактов между request dropdown и разделом друзей во вкладке `Ещё`.~~ [done]
46. ~~`REQ-13` Переименовать `Какой рецепт?` в `Название рецепта`.~~ [done]
47. ~~`REQ-14` Переименовать primary CTA в `Получить ссылку`.~~ [done]
48. ~~`REQ-15` Убрать отдельный success state; показывать ссылку inline на том же экране.~~ [done]
49. ~~`REQ-16` Показывать рядом со ссылкой действие `Копировать`.~~ [done]
50. ~~`REQ-17` Добавить поясняющий текст под ссылкой.~~ [done]
51. ~~`REQ-18` Добавить кнопку `Сформировать новый запрос`.~~ [done]
52. `DONOR-01` Share text v2: явное сообщение "без установки/регистрации, 2-3 минуты", персонализированный текст.
53. `DONOR-02` Web-reply onboarding block: короткое объяснение на первом экране ("вас попросили поделиться рецептом").
54. `DONOR-03` Режимы ответа в web-reply: `Коротко` / `Подробно`.
55. `DONOR-04` Черновик донора (autosave/restore) в web-reply.
56. ~~`DONOR-07` Post-submit редактирование ответа донора через `edit_token`: success CTA `Исправить рецепт`, prefilled reopen flow, ограниченное окно 72 часа.~~ [done]
57. `DONOR-11` Метрики воронки донора (open/start/success/error/retry).
58. `DONOR-12` Donor reply v2: разбить ответ донора на два поля — `recipe_text` + `donor_comment`.
59. `BE-SPEC-03` Backend-спека для donor comment: storage, API-контракт, миграции, detail read-model.
60. `BE-IMPL-03` Реализация donor comment в backend (`submit-request`, БД, read queries).
61. `IOS-09` Recipe detail v2: показать donor comment отдельно от основного текста рецепта.
62. `ANDROID-09` Android parity для donor comment / recipe detail v2.
63. `BE-SPEC-02` Backend-спека для contacts/chips (таблица, RLS, API-контракт, миграции) — **deferred** до подтвержденной cross-device необходимости.
64. `BE-IMPL-02` Реализация server storage для contacts/chips в Supabase (миграции + RLS + доступ из iOS/Android) — **deferred** после `BE-SPEC-02`.

## P0 Order Of Execution
1. ~~`BE-SPEC-04` + `BE-IMPL-04`~~ [done]
2. ~~`LIST-01` + `LIST-02` + `REQ-09` + `DETAIL-10` + `CARD-DELETE-01` (iOS)~~ [done]
3. `ANDROID-01...ANDROID-08` (включая unified card model parity)
4. `ANDROID-BUILD-01`
5. Full E2E на реальных устройствах
6. ~~`REQ-10...REQ-18`~~ [done]
7. `DONOR-01...DONOR-04`
8. ~~`DONOR-07`~~ [done]
9. `DONOR-11`
10. `DONOR-12` + `BE-SPEC-03` + `BE-IMPL-03` + `IOS-09` + `ANDROID-09`
11. `BE-SPEC-02` + `BE-IMPL-02` только если server storage контактов всё ещё подтверждён как реальная боль

## P0 Acceptance (для iOS и Android parity)
- `IOS-01 / ANDROID-02`: после submit через web-reply рецепт отображается в списке после refresh.
- `LIST-01`: pending-запросы и полученные рецепты отображаются в одном списке без отдельного разделения по экранам.
- `LIST-01`: карточка имеет понятный статус и корректные действия для своего состояния.
- `LIST-02`: дата не является primary metadata ни в списке, ни на detail screen.
- `CARD-DELETE-01`: карточку можно удалить через явное подтверждение без поломки остальных данных household.
- `REQ-10`: в основном request flow нет поля `история рецепта`.
- `REQ-11 / REQ-12`: `Кому отправить?` работает как редактируемый выпадающий список, связанный с контактами из раздела друзей.
- `REQ-13`: поле называется `Название рецепта`.
- `REQ-14 / REQ-15 / REQ-16 / REQ-17 / REQ-18`: после действия `Получить ссылку` пользователь остаётся на том же экране, видит ссылку, кнопку `Копировать`, поясняющий текст и кнопку `Сформировать новый запрос`.
- `IOS-02 / ANDROID-02`: из списка открывается detail карточка рецепта без потери контекста навигации.
- `IOS-03 / ANDROID-03`: новый запрос сразу виден в истории запросов на той же странице "Запросить" с корректным статусом.
- `IOS-04 / ANDROID-04`: success-экран не "тупик"; пользователь сразу понимает следующий шаг и может поделиться ссылкой повторно.
- `IOS-04 / ANDROID-04`: если уже были запросы, пользователь видит блок подсказок с чипами получателей и может в 1 тап переиспользовать имя.
- `IOS-05 / ANDROID-05`: комментарий к рецепту сохраняется и отображается при повторном открытии рецепта.
- `IOS-06 / ANDROID-06`: созданный вручную рецепт сразу появляется в общем списке рецептов.
- `IOS-07 / ANDROID-07`: из карточки рецепта можно в 1-2 тапа отправить запрос на уточнение автору рецепта.
- `IOS-08 / ANDROID-08`: пользователь может управлять списком контактов в "Моя семья и друзья", и эти контакты доступны как чипы в "Запросить рецепт".
- `IOS-08 / ANDROID-08`: чипы контактов цветные и визуально различимы; цвет контакта повторяемый между сессиями.
- `ANDROID-01...08`: Android UX/флоу функционально совпадает с iOS реализацией текущего MVP slice.

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
7. `DONOR-05` Reminder по pending-запросу из app с cooldown.
8. `DONOR-06` Мультирецепты в одном request context (`Добавить еще рецепт`, отдельные recipe records).

## P2
1. Голосовой ввод для донора.
2. Импорт фото блокнота.
3. Push-уведомления.
4. Метрики после запуска MVP.
5. Turnstile CAPTCHA включение в production.
6. `DONOR-08` Запрос правок по блокам (ингредиенты/шаги/советы) с deep-link в нужный блок.
7. `DONOR-09` Индикатор прогресса заполнения в web-reply.
8. `DONOR-10` Встроенный пример "как хорошо описать рецепт".

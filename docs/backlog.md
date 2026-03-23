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
52. `DONOR-01` Share text v2/v3: явное сообщение "без установки/регистрации, 2-3 минуты", персонализированный и тёплый invite text, который объясняет зачем нужен рецепт и что можно добавить историю рецепта.
53. `DONOR-02` Web-reply onboarding block: короткое и тёплое объяснение на первом экране (`зачем это`, no app/login, рецепт + история, рецепты близких людей).
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
65. `POSITION-01` Copy refresh первого касания: сместить framing от узкого "семейные рецепты" к более живому "рецепты близких людей / рецепты с историей / от кого этот рецепт" в share text, donor web, app copy и тестовых презентациях.
66. `DONOR-13` Story helper prompts для `recipe_story`: optional prompt chips / examples (`от кого рецепт`, `когда готовили`, `по какому поводу`, `какой главный нюанс`), чтобы история рецепта было легче заполнить.
67. `DETAIL-11` Provenance-first recipe detail: явный верхний блок `от кого`, `почему важен`, `история`, а не только основной текст рецепта.

## P0 Order Of Execution
1. ~~`BE-SPEC-04` + `BE-IMPL-04`~~ [done]
2. ~~`LIST-01` + `LIST-02` + `REQ-09` + `DETAIL-10` + `CARD-DELETE-01` (iOS)~~ [done]
3. `ANDROID-01...ANDROID-08` (включая unified card model parity)
4. `ANDROID-BUILD-01`
5. Full E2E на реальных устройствах
6. ~~`REQ-10...REQ-18`~~ [done]
7. `POSITION-01`
8. `DONOR-01...DONOR-04` + `DONOR-13`
9. `DETAIL-11`
10. ~~`DONOR-07`~~ [done]
11. `DONOR-11`
12. `DONOR-12` + `BE-SPEC-03` + `BE-IMPL-03` + `IOS-09` + `ANDROID-09`
13. `BE-SPEC-02` + `BE-IMPL-02` только если server storage контактов всё ещё подтверждён как реальная боль

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
- `POSITION-01`: first-touch copy на ключевых экранах и в invite text объясняет продукт как "рецепты близких людей / рецепты с историей", а не только как generic family recipe storage.
- `DONOR-01 / DONOR-02`: донор по share text и первому экрану за 3-5 секунд понимает, что не нужно ставить приложение, можно написать своими словами и история рецепта приветствуется.
- `DONOR-13`: поле `История рецепта` поддержано optional prompts / examples и не выглядит как пустая сложная форма.
- `DETAIL-11`: recipe detail явно показывает автора / происхождение / story layer, а не прячет смысл только в основном тексте.
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
9. `REQ-19` Optional personal reason в create-request / invite: короткая личная фраза вроде "хочу научиться готовить это как ты", чтобы запрос ощущался не утилитарно, а по-человечески.
10. ~~`REPEAT-LOOP-01` Mastery loop package: превратить разрозненные `REPEAT-01...04` в один цельный loop.~~ [done — iOS + backend 2026-03-23]
11. ~~`REPEAT-01` Attempt logging: отметить факт первой/повторной готовки и сохранить результат попытки без тяжёлого журнала.~~ [done — iOS + backend]
12. ~~`REPEAT-02` Post-cook note: короткая заметка после готовки без отдельного structured editor.~~ [done — iOS PostCookSheet]
13. ~~`REPEAT-03` Mastery progress for recipe: стадии `получил`, `пробовал`, `почти получилось`, `замастерил` + видимость прогресса на detail screen.~~ [done — iOS MasteryBlock]
14. ~~`REPEAT-04` Contextual clarification after attempt: мягкий CTA после неудачной/неполной попытки.~~ [done — iOS IOS-12]
15. `ANDROID-MASTERY-01` Android parity для mastery loop: mastery block на detail, attempt logging sheet, post-cook note, contextual clarification CTA. Backend уже готов. Parity notes: `docs/sessions/2026-03-23_REPEAT_LOOP_01_implementation.md`.
16. ~~`TECHNIQUES-01` Блок «Техники»: content_kind через backend + Edge Functions + donor web + iOS (segmented control, type picker, adapted copy).~~ [done — 2026-03-23]
17. `ANDROID-TECHNIQUES-01` Android parity для techniques block: content_kind в Android client, segmented control (Рецепты / Техники), type picker в create request flow, adapted copy на detail/mastery screens. Backend и donor web уже готовы.
16. `ARCHIVE-01` Browse / filters по людям, происхождению и occasion (`от мамы`, `друзья`, `праздничное`, `из Одессы`) вместо поиска только по названию блюда.
17. `DONOR-16` Reply-like-a-message / voice-first donor mode: сделать ответ ещё ближе к привычному сообщению, а позже поддержать voice-to-text для доноров, которым проще рассказывать, чем печатать.
18. `REPEAT-05` Personal stable version: дать пользователю собирать свой повторяемый вариант рецепта рядом с оригиналом, не стирая голос автора.

## P2
1. Голосовой ввод для донора.
2. Импорт фото блокнота.
3. Push-уведомления.
4. Метрики после запуска MVP.
5. Turnstile CAPTCHA включение в production.
6. `DONOR-08` Запрос правок по блокам (ингредиенты/шаги/советы) с deep-link в нужный блок.
7. `DONOR-09` Индикатор прогресса заполнения в web-reply.
8. `DONOR-10` Встроенный пример "как хорошо описать рецепт".
9. `SHARE-02` View-only recipe memory page: отдельная читаемая web-страница `рецепт + история + автор`, которую можно отправить близким без установки приложения.

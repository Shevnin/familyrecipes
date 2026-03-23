# Decision Log

Формат: одна строка на решение — **YYYY-MM-DD — решение**.
Примечание: ранние записи содержат исторические пути и могут ссылаться на старую структуру docs.

## 2026-03-23
- 2026-03-23 — Техники вводятся через единый `content_kind` ('recipe' | 'technique') на существующих таблицах, без параллельной инфраструктуры. Таблицы `recipes` и `recipe_requests` расширены колонкой `content_kind DEFAULT 'recipe'`, VIEW `family_recipe_cards` возвращает её. RPC `submit_recipe_by_token` передаёт `content_kind` из request в recipe автоматически — Edge Function `submit-request` не изменена.
- 2026-03-23 — Internal naming сохранено: таблица `recipes`, view `family_recipe_cards`, field `recipe_id`, `recipe_title`. Отличие рецепта от техники только через `content_kind`. Переименование инфраструктуры признано нецелесообразным для MVP.
- 2026-03-23 — iOS UI: segmented control «Рецепты / Техники» в RecipesView фильтрует единый список карточек по `contentKind`. Отдельная корневая tab bar вкладка для техник отклонена.
- 2026-03-23 — Mastery loop один для рецептов и техник: таблица `recipe_attempts`, Edge Function `log-cook-attempt`, `MasteryBlock`, `PostCookSheet` переиспользуются без дублирования. User-facing copy адаптируется («Готовил» / «Практиковал», «Отметить готовку» / «Отметить практику»).
- 2026-03-23 — Donor web form адаптирует copy динамически на основе `content_kind`, возвращаемого `get-request-meta`. Отдельная страница для техник отклонена.

## 2026-02-15
- 2026-02-15 — Работаем итеративно: прототип → тест флоу → дизайн → спека → код (Claude Code).
- 2026-02-15 — Каждая итерация = 1 end-to-end user flow, проходимый в прототипе/приложении.
- 2026-02-15 — Source of truth: /docs/PROJECT.md + /docs/DECISIONS.md.
- 2026-02-15 — Текущий фокус: Core Flow v1 (link → view → save → my → share).
- 2026-02-15 — Прототип v1 делаем на plain HTML/JS без фреймворка (скорость > архитектура на этапе прототипа).
- 2026-02-15 — В прототипе “сохранение” реализуем локально (localStorage) как имитацию аккаунта.

## 2026-02-22
- 2026-02-22 — Принята рекомендованная схема совместной работы (Человек + ChatGPT + Claude) с каноничным workflow в `/docs/workflow.md` и task-card шаблоном (текущий путь: `/docs/templates/delivery_task_template.md`).
- 2026-02-22 — Проект переведен в режим `discovery-first`: сначала идея/flow/roadmap/backlog, затем delivery.
- 2026-02-22 — Первый прототип (папки `src/` и `data/`) удален как неактуальный для текущей фазы.
- 2026-02-22 — Прототипные flow-документы перенесены в `/docs/archive/prototype_flows/`.
- 2026-02-22 — Документация упрощена до единой точки входа `/docs/README.md`; актуальные файлы вынесены в корень `docs/`, шаблоны в `/docs/templates/`, старые материалы в `/docs/archive/`.
- 2026-02-22 — Переход от чистого discovery к прототипированию: создан split-screen прототип "Мама → Сын" (`src/index.html`), подтверждающий концепцию из `product_brief.md` (два режима, оригинал + адаптация).
- 2026-02-22 — Прототип деплоится на GitHub Pages: https://shevnin.github.io/familyrecipes/src/index.html
- 2026-02-22 — Структура docs — плоская (без вложенных `00_start_here/`, `01_product/`, `planning/` и т.д.).
- 2026-02-22 — Для восстановления контекста между сессиями введен обязательный handoff-файл `docs/current_state.md` и протокол чтения/обновления в `docs/workflow.md`.

## 2026-02-25
- 2026-02-25 — Запрос рецепта реализован через UUID-ссылку (`?r=token`) без backend: localStorage на одном домене, родственник открывает ту же страницу. Достаточно для прототипа; для production потребуется серверное хранение.
- 2026-02-25 — Данные рецептов хранятся в двух ключах localStorage: `recipe_requests` (запросы) и `recipe_responses` (ответы), связаны через `token`.
- 2026-02-25 — Создан отдельный mobile-first прототип `web-mobile/index.html` параллельно со split-screen (`src/index.html`). Старый прототип не удаляем — он полезен для демо на десктопе. Новый — основной для тестирования на телефоне.

## 2026-02-27
- 2026-02-27 — Delivery идет нативно: iOS (SwiftUI) + Android (Jetpack Compose) с общим backend на Supabase. Flutter отклонен в пользу нативных клиентов.
- 2026-02-27 — Backend foundation: Supabase (PostgreSQL + Edge Functions + Auth). Структура в `supabase/` — миграции, Edge Functions, config.
- 2026-02-27 — Публичные endpoints (get-request-meta, submit-request) работают через Edge Functions с service_role key. Anon-доступ к таблицам закрыт через RLS (default deny).
- 2026-02-27 — Токен для ссылки-запроса: UUID в открытом виде передается пользователю, в БД хранится только SHA-256 hash.
- 2026-02-27 — Донор рецепта не обязан ставить приложение (zero-install). Получает ссылку в мессенджере, открывает mobile web (`web-reply/`), отправляет рецепт через форму. Ключевая продуктовая стратегия.
- 2026-02-27 — Guest web page (`web-reply/index.html`) — отдельный entrypoint от discovery-прототипов. Деплоится на GitHub Pages, Cloudflare Pages или Vercel.
- 2026-02-27 — `create-request` возвращает `token`, `web_url` и `share_text` (готовый текст для мессенджера). Нативный клиент использует `share_text` для системного share.
- 2026-02-27 — Anti-abuse: optional Cloudflare Turnstile CAPTCHA в `submit-request`, включается через env `CAPTCHA_SECRET`. Без секрета работает без captcha (dev mode).

## 2026-02-28
- 2026-02-28 — Для Supabase Edge Functions принят обязательный deploy с `--no-verify-jwt` (ES256 JWT в проекте, валидация auth выполняется внутри функций).
- 2026-02-28 — Link contract зафиксирован: `APP_BASE_URL` хранит root сайта (без `/web-reply`), query-mode ссылка формируется как `/web-reply/?token=<token>`.
- 2026-02-28 — `submit-request` возвращён к атомарному SQL RPC (`submit_recipe_by_token`), последовательная non-atomic реализация отклонена.
- 2026-02-28 — В iOS хранение auth токенов переведено с `UserDefaults` в Keychain; токен-фрагменты и raw 401 body удалены из debug логов.
- 2026-02-28 — web-reply закреплён как production-like guest entrypoint на GitHub Pages: `https://shevnin.github.io/familyrecipes/web-reply/?token=...`.
- 2026-02-28 — P0 mobile slice разрезан на `IOS-01...IOS-04`; для Android принят parity-first подход: сначала зеркальная спецификация (`ANDROID-SPEC-01`), потом реализация.
- 2026-02-28 — История запросов (`IOS-03`) должна быть inline на экране "Запросить", а не отдельным экраном: так быстрее повторно отправлять запросы и переиспользовать контакт.
- 2026-02-28 — После `IOS-03/04` в MVP добавляем пользовательские комментарии к рецептам (`IOS-05`) и создание своих рецептов (`IOS-06`) с обязательным Android parity в документации.
- 2026-02-28 — На карточке рецепта добавляется CTA "Попросить уточнить" (`IOS-07`): запускает prefilled create-request автору рецепта для уточнений/правок.
- 2026-02-28 — В Settings добавляется раздел "Моя семья и друзья" (`IOS-08`) как источник управляемых чипов для экрана "Запросить".
- 2026-02-28 — Контакты/чипы (`IOS-08`) в текущем пакете допускают локальное хранение; server storage переносится в отдельный backend этап (`BE-SPEC-02` -> `BE-IMPL-02`).

## 2026-03-01
- 2026-03-01 — Запускаем Android реализацию как parity-пакет `ANDROID-01...ANDROID-08` + `ANDROID-BUILD-01`, с референсом на iOS фичи и UX.

## 2026-03-21
- 2026-03-21 — Принят новый donor reply contract v2: ответ донора состоит из двух текстовых полей — основной текст рецепта (`recipe_text`) и отдельный личный комментарий (`donor_comment`); комментарий не смешивается с самим рецептом.
- 2026-03-21 — Запросы на рецепты и полученные рецепты объединяются в один список как одна сущность с разными статусами (`запрошен`, `получен`, `уточняется`), а не как два независимых раздела.
- 2026-03-21 — В основном UI скрываем даты; приоритет в списке и detail screen у названия, автора, статуса и смыслового контекста, а не у времени создания.
- 2026-03-21 — В flow запроса добавляется отдельное поле `история рецепта`; это важный семейный контекст, который должен отображаться в detail screen отдельным блоком над основным текстом рецепта.
- 2026-03-21 — В MVP должна быть возможность удаления карточки семейного рецепта/запроса.
- 2026-03-21 — Поле `история рецепта` убирается из основного request flow; для вкладки "Запросить рецепт" целевой сценарий должен остаться максимально коротким.
- 2026-03-21 — Экран "Запросить рецепт" упрощается: `Кому отправить?` — редактируемый выпадающий список контактов, `Какой рецепт?` переименовывается в `Название рецепта`, CTA = `Получить ссылку`.
- 2026-03-21 — После создания запроса не нужен отдельный success screen: ссылка должна показываться на том же экране inline, рядом с действием `Копировать`, с поясняющим текстом и кнопкой `Сформировать новый запрос`.
- 2026-03-21 — **`recipe_story` (история рецепта) заполняется донором, а не поваром.** Повар не вводит это поле — он только просит рецепт. Донор на web-reply page видит опциональное поле «История рецепта» после основного текста рецепта и заполняет его сам (откуда рецепт, кто готовил, семейная история). Записывается в `recipes.recipe_story`, повар видит на detail screen read-only.

## 2026-03-22
- 2026-03-22 — Для донорского редактирования принят **post-submit flow**, а не постоянное редактирование по исходной ссылке. После успешной отправки донор получает отдельное действие `Исправить рецепт`, которое открывает prefilled web-flow по `edit_token`.
- 2026-03-22 — Donor edit должен быть **time-limited** (стартовое окно: 72 часа), zero-install и без логина/регистрации.
- 2026-03-22 — Через donor edit можно менять только donor-originated данные текущего ответа (`submitted_by_name`, `recipe_title`, `original_text`, `recipe_story`; позже также `donor_comment`), без превращения MVP в полноценный versioned editor.
- 2026-03-22 — `DONOR-07` реализован и задеплоен: миграция `00007_donor_edit_token.sql`, edge functions `get-edit-meta` + `update-submitted-recipe`, web-reply edit mode `?edit_token=`, `edit_token` хранится как SHA-256 hash (как и request token), обновление recipe без дубля.

## 2026-03-23
- 2026-03-23 — Mastery loop оформляется как единый пакет `REPEAT-LOOP-01`, а не как набор разрозненных фич `REPEAT-01...04`; sequencing: после Android parity, donor conversion pack и donor reply v2.
- 2026-03-23 — `mastery_status` — это отдельный слой прогресса рецепта (`получил`, `пробовал`, `почти получилось`, `замастерил`), который не подменяет текущий lifecycle status карточки (`pending`, `received`, `clarification`).
- 2026-03-23 — `post-cook note` не заменяет существующую personal note; это отдельная сущность, привязанная к попытке готовки.
- 2026-03-23 — Для mastery loop MVP выбираем backend-backed направление хранения попыток готовки; local-only реализация отклоняется как тупиковая для метрик и cross-device consistency.
- 2026-03-23 — `REPEAT-LOOP-01` реализован: таблица `recipe_attempts` (append-only, per-user), Edge Function `log-cook-attempt`, VIEW `family_recipe_cards` расширен mastery read-model полями (`cook_count`, `mastery_status`, `latest_attempt_result`, `latest_attempt_note`, `latest_cooked_at`). iOS: MasteryBlock (IOS-10), PostCookSheet (IOS-11), contextual CTA после failed/partial (IOS-12).
- 2026-03-23 — Mastery status вычисляется по последней попытке текущего пользователя: `failed`→`пробовал`, `partial`→`почти получилось`, `success`→`замастерил`, 0 попыток→`получил`.
- 2026-03-23 — Для Android mastery loop оставлены parity notes; iOS + backend реализованы полностью в рамках сессии 2026-03-23.
- 2026-03-23 — In-app Help screen рассматривается как продуктовый экран смысла, а не как технический FAQ; он должен объяснять связь между людьми, историю рецепта, расстояние/сепарацию и путь к мастерству.
- 2026-03-23 — `docs/help_content.md` принят как каноничный source of truth для in-app help copy; app-side help данные должны быть централизованы в одном файле/модели, а не размазаны по view.

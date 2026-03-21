# FamilyRecipes Docs

Точка входа в документацию проекта.

## Фаза проекта
- **Delivery** — нативные мобильные клиенты (iOS SwiftUI + Android Compose) + backend (Supabase).
- Discovery-прототипы (`src/`, `web-mobile/`) остаются как reference.
- Текущий фокус: Android parity build `ANDROID-01...ANDROID-BUILD-01`.
- Следующий продуктовый фокус после Android: Donor conversion pack `DONOR-01...DONOR-11`.

## Архитектурная модель MVP
- **Повар** (Master) работает в нативном приложении (iOS/Android, auth).
- **Донор** (Transmitter) не обязан ставить приложение — получает ссылку в мессенджере, отправляет рецепт через мобильный web (`web-reply/`).
- **Целевой donor reply contract v2**: два текстовых поля — `recipe_text` + `donor_comment`.
- **Основной flow**: Request in app -> link in messenger -> donor web submit -> recipe in app.

## Start Here
1. Прочитать текущее состояние: `current_state.md`
2. Прочитать продуктовую рамку: `product_brief.md`
3. Пройти рабочий процесс: `workflow.md`
4. Проверить текущий план: `roadmap.md`
5. Открыть приоритеты: `backlog.md`
6. Посмотреть решения: `decisions.md`
7. Backend runbook: `backend_setup_supabase.md`

## Структура
- `product_brief.md` — что за продукт, для кого, ключевая гипотеза.
- `current_state.md` — где остановились и с чего начинать новую сессию.
- `workflow.md` — как ведём работу (роли, stage-gate, цикл).
- `roadmap.md` — план релизов/фаз.
- `backlog.md` — приоритизированный список задач.
- `decisions.md` — журнал решений.
- `backend_setup_supabase.md` — runbook: деплой, тесты, curl-примеры.
- `sessions/` — только активные task packs и последние опорные сессии.
- `stitch_design_package.md` — рабочий runbook по текущему visual direction.
- `stitch_exports/` — принятые reference-экспорты для дизайна.
- `templates/` — шаблоны для delivery.
- `archive/` — исторические session-логи, старые дизайн-материалы и legacy-документы.

## Правило актуальности
- Всё, что влияет на текущую работу, держим в корне `docs/`.
- В `docs/sessions/` держим только несколько актуальных файлов, нужных для следующего шага.
- Исторические материалы переносим в `docs/archive/`, а не держим рядом с активным контекстом.

# Workflow: Человек + ChatGPT (Codex) + Claude Code

## Роли

- **Человек (Owner)**: решает, что делать дальше; принимает или отклоняет результат.
- **ChatGPT (Codex)**: продуктовая голова — гипотезы, flow, product brief, ревью документации, формулировка следующего шага.
- **Claude Code**: руки — код, коммиты, пуш, деплой, обновление docs по результату.

## Граница фаз

- **Discovery** (завершена): прототипы, моки, UI-эксперименты, Pages-деплой.
- **Delivery** (текущая): нативные мобильные клиенты (iOS SwiftUI + Android Compose) + backend (Supabase) + guest web.
- Discovery-прототипы (`src/index.html`, `web-mobile/index.html`) остаются как reference, не модифицируются.

## Stage-Gate (Lean B2C, упрощенно)

### 1) Problem Fit [done]
- Что делаем: подтверждаем реальную боль и контекст пользователя.
- Критерий выхода: есть четко сформулированная проблема в `docs/product_brief.md`.

### 2) Solution Fit [done]
- Что делаем: фиксируем продуктовую гипотезу и целевой flow решения.
- Критерий выхода: описаны решение и top flow, который лучше текущих альтернатив.

### 3) MVP Validation [done]
- Что делаем: проверяем гипотезу через работающий прототип и фидбек реального пользователя.
- Критерий выхода: есть результаты проверки и обновленные `roadmap/backlog/decisions`.

### 4) MVP Scope Freeze [done]
- Что делаем: режем объем до минимального состава первой реализации.
- Критерий выхода: P0-задачи для первой сборки зафиксированы.

### 5) Delivery Start (Native Mobile + Backend) [current]
- Что делаем: реализуем нативные клиенты (iOS SwiftUI + Android Compose), backend (Supabase), guest web flow.
- Критерий выхода: работающий E2E flow на реальных устройствах.

## Единый источник текущего контекста

- Главный файл handoff: `docs/current_state.md`
- Он обязателен для обновления после каждой рабочей сессии (Codex или Claude).

## Протокол восстановления контекста (новая сессия)

### Для Codex
1. Прочитать `docs/current_state.md`.
2. Прочитать последнюю активную запись из `docs/sessions/` (архивные материалы искать только при необходимости в `docs/archive/sessions/`).
3. Проверить последние решения в `docs/decisions.md`.
4. Сверить `docs/roadmap.md` и `docs/backlog.md` с фактом в сессии.
5. Явно зафиксировать "контекст восстановлен" и только потом предлагать следующий шаг.

### Для Claude Code
1. Прочитать `docs/current_state.md`.
2. Прочитать целевую задачу (из чата или по шаблону `docs/templates/delivery_task_template.md`).
3. Прочитать последнюю активную запись в `docs/sessions/`.
4. Перед началом реализации коротко подтвердить понимание scope и acceptance criteria.
5. После выполнения обновить `docs/sessions/` и `docs/current_state.md`.

## Цикл работы

1. Codex формулирует следующий шаг (задача/план).
2. Owner передает задачу Claude.
3. Claude реализует, коммитит, пушит, фиксирует итог в `docs/sessions/`.
4. Codex ревьюит обновленные docs и синхронизирует roadmap/backlog/decisions.
5. Повторяем цикл.

## Специальный протокол для in-app Help

- Каноничный source of truth для help-контента: `docs/help_content.md`
- Этот файл описывает **смысл и copy** help screen, а не только UI-структуру.

### Если Owner меняет смысл help-контента
1. Owner обсуждает новую framing / copy с Codex.
2. Codex обновляет `docs/help_content.md`.
3. Если изменился product meaning, Codex синхронизирует:
   - `docs/product_brief.md`
   - `docs/backlog.md`
   - `docs/decisions.md`
   - `docs/current_state.md`
4. Owner передаёт Claude задачу на sync help screen в приложении.
5. Claude обновляет app-side help data и UI.
6. Claude фиксирует sync в `docs/sessions/` и `docs/current_state.md`.
7. Codex проверяет, что app и `docs/help_content.md` не расходятся.

### Обязательное правило для Claude
- Не хардкодить help copy по нескольким view.
- Help-контент в приложении должен жить в одном app-side источнике данных и рендериться из него.
- Если Claude меняет help copy в app code, но видит, что `docs/help_content.md` отстаёт, он должен обновить docs или явно отметить drift в session note.

### Когда help-сессия считается завершённой
- `docs/help_content.md` актуален.
- App help screen соответствует этому файлу.
- В `docs/current_state.md` есть запись, если help-контент или процесс были существенно изменены.

## Правила завершения любой сессии

- Есть запись в `docs/sessions/` с тем, что сделано.
- Обновлен `docs/current_state.md`:
  - что сейчас за фаза
  - где остановились
  - что делать первым шагом в новой сессии
- Если принято новое решение — обновлен `docs/decisions.md`.
- Если изменились приоритеты — обновлены `docs/roadmap.md` и `docs/backlog.md`.

## Обязательные артефакты

- Продуктовая рамка: `docs/product_brief.md`
- Текущий статус (handoff): `docs/current_state.md`
- Roadmap: `docs/roadmap.md`
- Backlog: `docs/backlog.md`
- Журнал решений: `docs/decisions.md`
- Backend runbook: `docs/backend_setup_supabase.md`
- Help source of truth: `docs/help_content.md`
- Активные протоколы сессий: `docs/sessions/`
- История сессий и старые материалы: `docs/archive/`
- Шаблоны: `docs/templates/`

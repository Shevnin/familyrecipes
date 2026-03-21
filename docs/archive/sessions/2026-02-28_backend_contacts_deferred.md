# Сессия: Backend contacts storage deferred

Дата: 2026-02-28

## Решение
Контакты/чипы для `IOS-08` должны храниться на сервере, но реализация backend storage выносится в отдельный этап после текущего iOS UX-пакета.

## Что обновлено
- `docs/backlog.md`:
  - `BE-SPEC-02` отмечен как deferred.
  - добавлен `BE-IMPL-02` (реализация server storage).
- `docs/current_state.md`:
  - добавлен следующий шаг после `IOS-03...IOS-08`: `BE-SPEC-02 -> BE-IMPL-02`.
- `docs/roadmap.md`:
  - добавлен TODO про backend contacts storage после текущего iOS slice.
- `docs/decisions.md`:
  - зафиксирован компромисс: локально сейчас, сервер позже.

## Почему
- Claude уже выполняет большой iOS-пакет.
- Чтобы не ломать текущий темп, backend часть выделена отдельным, явным блоком.

# Сессия: Backlog slicing for iOS + Android parity

Дата: 2026-02-28

## Цель
Разбить следующий мобильный инкремент на конкретные карточки для iOS и одновременно зафиксировать зеркальные требования для Android.

## Что обновлено
- `docs/backlog.md`
- `docs/roadmap.md`
- `docs/current_state.md`
- `docs/README.md`
- `docs/decisions.md`

## Новая нарезка задач (P0)
- `IOS-01` Список рецептов (real data, states, refresh)
- `IOS-02` Карточка рецепта (detail screen)
- `IOS-03` Список запросов (history + status)
- `IOS-04` Редизайн success-экрана create-request
- `ANDROID-SPEC-01` Android parity-спека для `IOS-01...IOS-04` (без кода)
- `ANDROID-UI-01...04` — зафиксирован mirror scope экранов/состояний в `docs/backlog.md`

## Почему так
- Фича "видеть рецепт в приложении после web-submit" закрывается только при наличии `IOS-01`.
- UX-ценность следующего шага после создания запроса закрывается `IOS-03` + `IOS-04`.
- Чтобы Android не отстал по UX/flow, parity фиксируется заранее как часть документации, а не после iOS-реализации.

## Следующий шаг
Взять в реализацию `IOS-01` как отдельный Task Pack, не смешивая с `IOS-02...IOS-04`.

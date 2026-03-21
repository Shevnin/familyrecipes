# Сессия: Android build kickoff (parity with iOS)

Дата: 2026-03-01

## Запрос
Сделать Android build с тем же продуктовым срезом, что уже реализован в iOS.

## Решение
Запускать Android реализацию последовательным пакетом:
- `ANDROID-01` ... `ANDROID-08`
- затем `ANDROID-BUILD-01`

## Порядок
1. Skeleton (auth + tabs + session restore)
2. Recipes list + detail
3. Inline request history на "Запросить"
4. Request flow redesign + chips
5. Comments
6. Create own recipe
7. "Попросить уточнить" на карточке рецепта
8. "Моя семья и друзья" + цветные чипы
9. Debug build и тест на реальном Android

## Важно
- Android должен быть parity с iOS UX/flow.
- Backend contacts storage (`BE-SPEC-02` -> `BE-IMPL-02`) остается отдельным этапом после мобильного parity build.

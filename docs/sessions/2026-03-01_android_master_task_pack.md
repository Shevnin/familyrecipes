# Сессия: Android parity build (master task pack)

Дата: 2026-03-01

## Контекст
- iOS slice `IOS-01...IOS-08` завершен.
- Нужно сделать Android build с тем же функциональным объёмом.
- Backend и web-reply уже в прод-используемом dev контуре Supabase/GitHub Pages.

## Master Task Pack для Claude

### Цель
Собрать рабочее Android-приложение (Jetpack Compose), функционально зеркальное текущему iOS MVP, и установить на реальное устройство.

### Ограничения
- Не менять существующий iOS код.
- Не ломать `web-reply/` и Edge Functions контракты.
- Делать Android app в `apps/android/`.
- Секреты не коммитить; только шаблоны конфигов.

### Порядок задач
1. `ANDROID-01` Skeleton:
   - Compose app structure, tabs (`Рецепты`, `Запросить`, `Настройки`), auth (email/password), session restore.
2. `ANDROID-02` Recipes:
   - Список рецептов (loading/empty/error/data, refresh) + экран карточки рецепта.
3. `ANDROID-03` Request history:
   - История запросов на том же экране `Запросить` под формой.
4. `ANDROID-04` Request redesign:
   - Success state с понятными next actions + чипы "уже просили у...".
5. `ANDROID-05` Comments:
   - Личные заметки к рецептам (локальное хранилище).
6. `ANDROID-06` Own recipes:
   - Создание собственного рецепта и мгновенное появление в списке.
7. `ANDROID-07` Clarification CTA:
   - На карточке рецепта кнопка `Попросить уточнить` с prefilled формой.
8. `ANDROID-08` Family & Friends:
   - Экран настроек с CRUD контактов и цветными чипами.
9. `ANDROID-BUILD-01` Device build:
   - Debug build + установка на реальный Android.

### Технический контракт
- Использовать те же backend endpoints/таблицы, что iOS.
- Для Edge Functions отправлять `Authorization` + `apikey`.
- Реализовать retry на 401 с refresh (аналог iOS).
- Локально хранить:
  - auth session в безопасном storage;
  - contacts/notes/link cache в локальном persistence.

### Acceptance
- Flow работает end-to-end:
  - login -> create request -> open shared link -> submit recipe -> recipe виден в Android app.
- Повторный submit по той же ссылке даёт корректное состояние "уже отправлен".
- После restart app сессия сохранена.
- Все `ANDROID-01...ANDROID-08` закрыты и отражены в `docs/backlog.md` и `docs/current_state.md`.

### Формат финального отчёта от Claude
- Список changed files с коротким описанием.
- Что собрано/чем запускать (`./gradlew ...`).
- Что проверено на устройстве (чек-лист).
- Остаточные риски/блокеры.
- Конкретные следующие шаги.

## Следующий шаг
Передать этот pack в Claude и запускать реализацию последовательно с `ANDROID-01`.

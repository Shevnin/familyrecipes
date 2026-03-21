# Session: IOS-01 + IOS-02 — Recipes List & Detail View

Дата: 2026-02-28

## Что сделано

### IOS-01: Список рецептов (real data)
- `RecipeModels.swift`: добавлено поле `originalText: String?` (маппинг `original_text`), добавлен `Hashable`.
- `EdgeFunctionsClient.swift`:
  - `fetchRecipes()` теперь включает `original_text` в select query.
  - Добавлен retry-on-401 (pre-flight JWT expiry check + 1 retry после refreshSession), аналогично `createRequest`.
  - Извлечён private `performFetchRecipes()` для retry pattern.
- `RecipesView.swift`: empty state обновлён — подсказка перейти на вкладку «Запросить».
- Состояния: loading, error (с retry), empty (с подсказкой), data (pull-to-refresh).

### IOS-02: Карточка рецепта (detail view)
- Создан `RecipeDetailView.swift`:
  - Отображает title (navigationTitle, large), author (с иконкой), date, original_text.
  - Fallback для пустого original_text: italic «Текст рецепта отсутствует.»
  - ScrollView для длинных рецептов.
- `RecipesView.swift`: добавлен `NavigationLink(value: recipe)` + `.navigationDestination(for: Recipe.self)`.
- `Recipe` получил `Hashable` для работы с navigation value.
- Back navigation сохраняет позицию в списке (стандартное поведение NavigationStack).

## Файлы изменены
- `apps/ios/.../Core/Networking/Models/RecipeModels.swift`
- `apps/ios/.../Core/Networking/EdgeFunctionsClient.swift`
- `apps/ios/.../Features/Recipes/RecipesView.swift`
- `apps/ios/.../Features/Recipes/RecipeDetailView.swift` (новый)
- `docs/backlog.md` — IOS-01, IOS-02 отмечены [done]
- `docs/current_state.md` — обновлён статус и приоритеты

## Требуется пересборка iOS
Да — изменения в Swift-коде требуют пересборки в Xcode.

## Следующий шаг
`IOS-03` — Список запросов (request history): экран со статусами pending/fulfilled/expired.

# Android Parity Notes: Unified Family Recipe Card Model

Дата: 2026-03-21

## Контекст

После реализации unified card model в iOS и backend, Android-приложение должно реализовать ту же модель. Эти заметки описывают, что нужно учесть при реализации Android parity.

## Что изменилось в backend

### Новая миграция: `00005_unified_card_model.sql`
- Добавлены колонки: `recipe_story`, `hidden_at`, `parent_recipe_id`
- Создан VIEW `family_recipe_cards` (unified read-model)
- Добавлены UPDATE RLS policies для soft delete

### Обновлённый Edge Function: `create-request`
- Принимает два новых опциональных поля: `recipe_story`, `parent_recipe_id`

## Что нужно реализовать в Android

### 1. Data model: `FamilyRecipeCard`
```kotlin
data class FamilyRecipeCard(
    val cardId: String,
    val householdId: String,
    val title: String,
    val authorName: String,
    val originalText: String?,
    val cardStatus: String,       // pending, received, clarification, expired
    val recipeStory: String?,
    val recipeId: String?,
    val requestId: String?,
    val createdAt: String
)
```

### 2. Networking
- `GET /rest/v1/family_recipe_cards` — unified list (вместо отдельных запросов recipes + recipe_requests)
- `PATCH /rest/v1/recipes?id=eq.{id}` с `{ "hidden_at": "..." }` — soft delete recipe
- `PATCH /rest/v1/recipe_requests?id=eq.{id}` с `{ "hidden_at": "..." }` — soft delete request
- `create-request` теперь принимает `recipe_story` и `parent_recipe_id`

### 3. UI изменения

#### Unified List (вместо отдельных экранов)
- Один список на главном экране: pending + received + clarification cards
- Каждая карточка показывает: title, author, status badge
- **Даты скрыты** из primary UI — не показывать `created_at` ни в списке, ни в detail
- Поиск по title и author

#### Detail Screen
- Author + status badge вверху
- **Recipe Story** блок — отдельный визуальный блок над основным текстом (если есть)
- Recipe text (для received cards)
- Pending state (для pending cards — "Ожидаем ответ...")
- CTA "Попросить уточнить" (для received cards) — теперь передаёт `parent_recipe_id`
- Personal notes (только для received cards с `recipe_id`)
- **Delete** — кнопка удаления с confirmation dialog

#### Create Request Flow
- Добавить поле **"История рецепта"** — TextEditor/TextField для семейного контекста
- Передавать `recipe_story` в `create-request` Edge Function
- Передавать `parent_recipe_id` при clarification flow

#### Request History Section (на экране "Запросить")
- Убрать даты из отображения (LIST-02)
- Остальное без изменений

### 4. Статусы и цвета
| Status | Label | Цвет |
|---|---|---|
| pending | Ожидает | accent/orange |
| received | Получен | green |
| clarification | Уточняется | accent/orange |
| expired | Истёк | secondary/grey |

### 5. Delete Flow
- Кнопка trash в toolbar detail screen
- Confirmation dialog: "Удалить «{title}»?"
- PATCH hidden_at на соответствующую таблицу
- Dismiss detail + обновить список

## Порядок реализации
1. Создать `FamilyRecipeCard` data class
2. Добавить `fetchFamilyCards()` и `hideCard()` в networking layer
3. Заменить recipes list на unified cards list
4. Обновить detail screen (recipe story, delete, status)
5. Добавить `recipe_story` в create request flow
6. Обновить request history (убрать даты)
7. Проверить build + тест на устройстве

## Совместимость
- Старые API (`/rest/v1/recipes`, `/rest/v1/recipe_requests`) по-прежнему работают
- Новый VIEW `family_recipe_cards` доступен через тот же PostgREST
- Edge Function backwards-compatible: `recipe_story` и `parent_recipe_id` опциональны

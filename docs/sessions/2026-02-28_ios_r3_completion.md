# Session: iOS R3 Completion (IOS-03...IOS-08)

Дата: 2026-02-28

## Что сделано

### IOS-03: Inline Request History
- `RequestHistoryModels.swift`: модель `RecipeRequest` (id, recipientName, dishName, status, createdAt) + computed statusLabel/statusColor/formattedDate.
- `EdgeFunctionsClient.swift`: `fetchRequestHistory()` с retry-on-401 (тот же паттерн).
- `RequestHistorySection.swift`: секция с loading/empty/error/data. Строки: dish, recipient, status chip, date. Quick actions: Share/Copy (только если link cached).
- `CreateRequestViewModel.swift`: history loading, link cache on create success.
- `CreateRequestView.swift`: history section под формой, загрузка в `.task`.

### IOS-04: Redesign Request Flow + Chips
- Success state: блок "Что дальше" с Share, Copy, scroll-to-history (ScrollViewReader), "Новый запрос".
- Chips: "Уже просили у..." — horizontal ScrollView с ChipView. Источник: contacts + recent recipients (dedup). Тап заполняет recipientName.
- `ChipView.swift`: reusable, djb2 hash → palette из 10 цветов. Стабильный цвет между перезапусками.

### IOS-05: Recipe Comments (Personal Notes)
- `NotesStore.swift`: local persistence (UserDefaults JSON), keyed by recipeId.
- `RecipeDetailView.swift`: секция "Моя заметка" — добавить/редактировать/сохранить.
- `RecipesView.swift`: индикатор заметки (note.text icon) в строке рецепта.

### IOS-06: Create Own Recipe
- `CreateRecipeView.swift`: sheet с Form (title + TextEditor для originalText).
- `EdgeFunctionsClient.swift`: `createRecipe()` — resolve household_id, POST `/rest/v1/recipes` с `Prefer: return=minimal`.
- `HTTPClient.swift`: + `requestNoContent()` для void POST.
- `RecipesView.swift`: toolbar "+" button, sheet, refresh после создания.

### IOS-07: "Попросить уточнить" CTA
- `RequestDraft.swift`: shared @Observable (recipientName, dishName, hasDraft, consume).
- `MainTabView.swift`: `@State selectedTab`, `@State requestDraft`, передаются в RecipesView и CreateRequestView.
- `RecipeDetailView.swift`: кнопка "Попросить уточнить" → sets draft + switches tab.
- `CreateRequestView.swift`: `.onChange(of: requestDraft.hasDraft)` → consume draft, prefill fields.

### IOS-08: Settings "Моя семья и друзья"
- `ContactsStore.swift`: @Observable singleton, CRUD, local persistence (UserDefaults JSON).
- `ContactsView.swift`: список контактов с цветными аватарами (первая буква), swipe-to-delete, "+" button.
- `ContactEditView.swift`: форма add/edit (имя, тип, заметка).
- `MainTabView.swift` SettingsView: NavigationLink на ContactsView.

### Foundation Layer
- `LocalStore.swift`: generic UserDefaults JSON load/save.
- `LinkCacheStore.swift`: cache {requestId → webURL, shareText}, пополняется после create-request.

## Новые файлы (11)
- `Core/Persistence/LocalStore.swift`
- `Core/Persistence/ContactsStore.swift`
- `Core/Persistence/NotesStore.swift`
- `Core/Persistence/LinkCacheStore.swift`
- `Core/UI/ChipView.swift`
- `Core/Networking/Models/RequestHistoryModels.swift`
- `Features/Request/RequestHistorySection.swift`
- `Features/Recipes/CreateRecipeView.swift`
- `Features/Settings/ContactsView.swift`
- `Features/Settings/ContactEditView.swift`
- `App/RequestDraft.swift`

## Изменённые файлы (7)
- `Core/Networking/HTTPClient.swift` — requestNoContent()
- `Core/Networking/EdgeFunctionsClient.swift` — fetchRequestHistory(), createRecipe()
- `Features/Request/CreateRequestView.swift` — chips, history, success redesign, draft
- `Features/Request/CreateRequestViewModel.swift` — history, link cache, chipNames
- `Features/Recipes/RecipesView.swift` — "+" button, note indicator, requestDraft/selectedTab
- `Features/Recipes/RecipeDetailView.swift` — notes, "Попросить уточнить"
- `App/MainTabView.swift` — selectedTab, RequestDraft, contacts link

## Требуется пересборка iOS
Да — все изменения в Swift-коде.

## Ограничения / Риски
- Contacts и notes хранятся в UserDefaults (local only). Потеряются при переустановке. Backend storage запланирован в `BE-SPEC-02`.
- Link cache пополняется только при create-request в текущей сессии. Старые запросы не имеют cached link → Share/Copy disabled.
- `String.hashValue` в Swift нестабилен → используем djb2 hash для стабильного цвета чипов.

## Следующий шаг
1. Собрать iOS в Xcode и прогнать E2E.
2. `ANDROID-SPEC-01...04` — parity-спека для Android.
3. `BE-SPEC-02` — backend для contacts.

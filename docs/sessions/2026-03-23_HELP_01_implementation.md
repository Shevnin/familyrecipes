# Сессия: HELP-01 — in-app Help screen

Дата: 2026-03-23
Статус: **DONE**

---

## Что сделано

### Новые файлы

**`Features/Settings/HelpContent.swift`**
Централизованный app-side источник данных для help screen.
- Структура `HelpSection`: `icon: String`, `title: String`, `body: String`
- `enum HelpContent`: `screenTitle` + `sections: [HelpSection]` (5 секций)
- `HelpView` рендерит данные из этой структуры, без хардкода строк

**`Features/Settings/HelpView.swift`**
Экран «Как это работает».
- `ScrollView` + `ForEach(HelpContent.sections)` → `HelpSectionCard`
- `HelpSectionCard`: иконка + bold title + readable body с lineSpacing
- Стиль: `Color.WP.surface`, `DS.panelRadius`, `Color.WP.divider` border — в рамках текущего visual language

### Изменённые файлы

**`App/MainTabView.swift`** (SettingsView)
Добавлен `NavigationLink { HelpView() }` с:
- label «Как это работает»
- иконка `questionmark.circle`
- позиция: между «Семья и друзья» и «Авторские права», с разделителями
- логика `settingsRow()` не дублировалась — переиспользована существующая

---

## App-side source of truth

`Features/Settings/HelpContent.swift` — единственное место в коде, где живут тексты help screen.
`HelpView` не содержит ни одной длинной строки контента.

---

## Sync с docs/help_content.md

Copy совпадает 1-в-1. Никаких правок в тексте не потребовалось.

Секции и заголовки:
| # | Заголовок в app | Заголовок в docs |
|---|---|---|
| 1 | О чём FamilyRecipes | О чём FamilyRecipes ✓ |
| 2 | Почему важна история рецепта | Почему важна история рецепта ✓ |
| 3 | Если вы живёте далеко | Если вы живёте далеко ✓ |
| 4 | Не просто сохранить, а освоить | Не просто сохранить, а освоить ✓ |
| 5 | Как пользоваться | Как пользоваться ✓ |

`docs/help_content.md` не изменялся — drift отсутствует.

---

## Acceptance criteria

- [x] Во вкладке «Ещё» появился пункт «Как это работает»
- [x] По тапу открывается отдельный help screen
- [x] Единый app-side источник данных (`HelpContent.swift`)
- [x] `HelpView` не захардкожен длинными строками
- [x] Help screen объясняет: связь между людьми, историю рецепта, расстояние/сепарацию, путь к мастерству
- [x] Синхронизирован с `docs/help_content.md`
- [x] Визуально в рамках текущего WP visual language

---

## Что не трогалось

Auth, recipe flow, request flow, mastery loop, donor web — без изменений.

---

## Следующие шаги

Если copy/framing help-экрана потребует обновления:
1. Codex обновляет `docs/help_content.md`
2. Owner передаёт Claude sync-задачу
3. Claude обновляет `HelpContent.swift` и фиксирует sync в session note

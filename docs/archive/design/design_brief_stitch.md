# FamilyRecipes — Техническое задание на дизайн для Google Stitch

**Дата**: 21 марта 2026
**Статус**: MVP — R3 (iPhone)
**Платформа**: iOS (SwiftUI)
**Целевая аудитория**: Семьи 30+, хотящие надежно готовить по семейным рецептам

---

## 📱 Обзор приложения

**FamilyRecipes** помогает семьям превращать устные рецепты в надежно воспроизводимые инструкции.

**Ключевые особенности**:
- Получение рецептов от членов семьи через простую веб-ссылку (без установки приложения для донора)
- Сохранение рецептов с авторством и датой
- Возможность просмотра, аннотирования и запроса уточнений
- Трех-табовая навигация: Рецепты → Запросить → Настройки

**Целевые метрики**:
- Простота: одна цель на экран, не перегружать интерфейс
- Скорость: готовка из приложения, быстрый доступ к информации
- Доверие: четкое авторство, дата добавления, контактные данные автора

---

## 🎨 Дизайн-система

### Цветовая палитра
- **Primary (теплый)**: #FF6B35 (оранжевый — ассоциация с кухней, теплом, семьей)
- **Secondary**: #4A90E2 (голубой — для вторичных действий)
- **Background**: #FFFFFF (светлый фон — кухонная чистота)
- **Surface cards**: #F5F5F5 (светло-серый — карточки контента)
- **Accent neutral**: #6B6B6B (темно-серый для текста)
- **Danger**: #E74C3C (красный — для деструктивных действий)

### Типография
- **Headline**: SF Pro Display, 20pt, weight 700
- **Subheading**: SF Pro Display, 16pt, weight 600
- **Body**: SF Pro Text, 15pt, weight 400
- **Caption**: SF Pro Text, 12pt, weight 500
- **Spacing**: Line height 1.4-1.6 для улучшения читаемости рецептов

### Компоненты
- **Скругления**: Border radius 14pt (постоянный, iOS-like)
- **Padding**: 16-20pt между элементами
- **Bottom tab bar**: 60pt высота с иконками + текстом
- **Кнопки**: Solid primary (#FF6B35), bordered secondary
- **Карточки рецептов**: 1pt border #E0E0E0, shadow subtle

---

## 🖥️ Экран 1: Recipes List (Рецепты)

### Назначение
Показать список всех полученных рецептов. Каждый рецепт — карточка с авторством и датой.

### Структура
```
┌─────────────────────────┐
│ Рецепты    [📖]        │  ← Large title, tab icon
├─────────────────────────┤
│                         │
│ ┌─────────────────────┐ │
│ │ [🍴] Борщ          │ │  ← Recipe card
│ │ От мамы • 25 февр  │ │
│ │ Текст рецепта...   │ │
│ │ нарезаем, варим... │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ [🍴] Паста Карбо   │ │
│ │ От папы • 10 февр  │ │
│ │ Текст рецепта...   │ │
│ └─────────────────────┘ │
│                         │
└─────────────────────────┘
   [📖] Рецепты | Запросить...
```

### Google Stitch промпт

```
iOS app screen — Recipes List view.

Header:
- "Рецепты" as large title (20pt, weight 700)
- Tab bar icon "📖" badge visible at bottom
- Vertical scrolling list, no horizontal scroll

Main Content:
- List of recipe cards, each with:
  * Recipe icon [fork and knife] on left
  * Recipe title (16pt, weight 600) — "Борщ", "Паста Карбо", "Щи", "Сыр по-домашнему"
  * Author + date meta row (12pt, secondary color): "От мамы • 25 февр"
  * Recipe text excerpt (15pt, secondary) — 2-3 lines, gray color
  * Card rounded corners (14pt), light gray background (#F5F5F5)
  * 1-2px border, subtle shadow
  * Tap to navigate to detail view
  * List padding: 16pt horizontal, 8pt between cards

Footer:
- Tab bar at bottom with 3 tabs:
  * [📖] "Рецепты" (selected, orange highlight)
  * [✈️] "Запросить"
  * [⚙️] "Ещё"
- Tab bar height: 60pt, icons + text centered

Style:
- Light theme, clean white background (#FFFFFF)
- Primary accent color: warm orange (#FF6B35)
- Text primary: dark gray (#2C2C2C)
- Text secondary: medium gray (#6B6B6B)
- One-handed use friendly: tap targets 48pt minimum

Behavior:
- Tap any card → navigates to Recipe Detail screen
```

---

## 🖥️ Экран 2: Recipe Detail (Деталь рецепта)

### Назначение
Показать полный рецепт с возможностью добавления персональных заметок и запроса уточнений.

### Структура
```
┌─────────────────────────────┐
│ ← Борщ               [⋯]  │  ← Back + title + more
├─────────────────────────────┤
│                             │
│ [👤] Мама • 25 февраля      │  ← Author + date (pill)
│                             │
│ ┌─────────────────────────┐ │
│ │ Нарезаем свеклу,       │ │  ← Full recipe text
│ │ варим в подсоленой     │ │
│ │ воде 30 минут. Затем   │ │
│ │ добавляем масло...     │ │
│ └─────────────────────────┘ │
│                             │
│ [↩️] Попросить уточнить    │  ← CTA button (only if has author)
│                             │
│ ┌─ Моя заметка ────────────┐│
│ │ Нажимать кнопку          ││
│ │ "Добавить заметку"       ││
│ │ чтобы сохранить тонкости ││
│ └──────────────────────────┘│
│                             │
│ [Редактировать]             │  ← Edit note button (if note exists)
│                             │
└─────────────────────────────┘
```

### Google Stitch промпт

```
iOS app screen — Recipe Detail view.

Header:
- Back button (<) left side, 24pt icon
- Recipe title as navigation title: "Борщ" (20pt, weight 700)
- More menu button (...) right side, 24pt icon
- Header background: white with bottom subtle divider

Main Content (scrollable):
- Metadata row (author + date):
  * Person icon [👤] + "Мама" text in orange accent pill
  * Capsule background (#F0F0F0), padding 12px horizontal, 6px vertical
  * Followed by spacer and date in gray (12pt): "25 февраля"
  * Full-width row, 20pt padding

- Recipe text card:
  * Large text block (15pt, line height 1.6), dark gray color
  * Multiline content: "Нарезаем свеклу, варим в подсоленой воде 30 минут..."
  * Background: light gray (#F5F5F5)
  * Rounded corners 14pt, padding 16pt
  * 1px subtle border
  * Top spacing 20pt, bottom spacing 20pt

- "Попросить уточнить" button (only if recipe.authorName is not empty):
  * Icon: ↩️ (arrow.uturn.left.circle.fill)
  * Text: "Попросить уточнить" (13pt, weight 600)
  * Style: bordered, full width, large control size
  * Tint: secondary gray (#6B6B6B)
  * Padding vertical: 4pt
  * Tap action: switches to "Запросить" tab with author name pre-filled

- Notes section:
  * Header: "Моя заметка" with 📝 icon (16pt, weight 600)
  * Two states:
    ✓ No note: "Добавить заметку" button (bordered, tint secondary)
    ✓ Note exists: gray pill showing note text (15pt, line height 1.4), "Редактировать" link below

  * Edit mode (TextEditor):
    - Minimum height: 90pt
    - Padding: 8pt
    - Background: light gray (#F5F5F5), border radius 10pt
    - Two buttons below: "Сохранить" (solid, orange), "Отмена" (bordered)
    - Button size: small, spacing 10pt between

Footer: None (scrollable content ends with notes section)

Style:
- Light theme, white background (#FFFFFF)
- Primary accent: warm orange (#FF6B35) for important elements
- Secondary accent: gray (#6B6B6B) for metadata
- Text primary: dark (#2C2C2C)
- Text secondary: medium gray (#6B6B6B)
- Supports one-handed reach: no elements beyond 150pt from bottom

Spacing:
- Vertical spacing between sections: 20pt
- Horizontal padding: 20pt on sides
```

---

## 🖥️ Экран 3: Create Request (Запросить)

### Назначение
Создать запрос рецепта для отправки родственнику. Пользователь вводит имя и название блюда.

### Структура
```
┌─────────────────────────────┐
│ Запросить    [✈️]          │  ← Large title
├─────────────────────────────┤
│                             │
│ Кого попросить?             │  ← Label
│ [_____________________]     │  ← Text field
│ Например: Мама, Бабушка    │  ← Helper text
│                             │
│ Название блюда              │  ← Label
│ [_____________________]     │  ← Text field
│ Например: Борщ, Паста      │  ← Helper text
│                             │
│ [Создать запрос] → [📋]     │  ← Generate link button
│                             │
│ ┌──────────────────────────┐│
│ │ Ссылка создана! Готово к│ │  ← Success state
│ │ отправке в мессенджер:  │ │
│ │ https://familyrec...    │ │
│ │ [Скопировать] [Share]   │ │
│ └──────────────────────────┘│
│                             │
└─────────────────────────────┘
   [📖] Рецепты | Запросить... | Ещё...
```

### Google Stitch промпт

```
iOS app screen — Create Request view.

Header:
- "Запросить" as large title (20pt, weight 700)
- Tab icon "✈️" visible at bottom
- No back button (tab view)

Main Content (scrollable):
- Form with two text input fields:

Field 1 - "Кого попросить?" (Request recipient)
  * Label: "Кого попросить?" (16pt, weight 600, dark gray)
  * Input field: placeholder "Мама, Бабушка, Папа" (light gray)
  * Text size: 15pt
  * Padding: 12px
  * Border: 1px light gray (#E0E0E0), radius 10pt
  * Helper text below (12pt, gray): "Например: Мама, Бабушка"
  * Spacing: 16pt from label to field, 8pt to helper

Field 2 - "Название блюда" (Dish name)
  * Label: "Название блюда" (16pt, weight 600, dark gray)
  * Input field: placeholder "Борщ, Паста, Плов" (light gray)
  * Text size: 15pt
  * Padding: 12px
  * Border: 1px light gray (#E0E0E0), radius 10pt
  * Helper text below (12pt, gray): "Например: Борщ, Паста"
  * Spacing: 16pt from label to field, 8pt to helper
  * Total top spacing from field 1: 24pt

- "Создать запрос" button:
  * Text: "Создать запрос" (15pt, weight 600)
  * Icon: none (or paper plane icon optional)
  * Style: solid, primary orange (#FF6B35)
  * Full width
  * Control size: large
  * Padding: 16pt vertical
  * Top spacing: 32pt
  * Tap action: generates shareable link

- Success state (conditional, after button tap):
  * Card with light orange background (#FFF0E6)
  * Title: "✓ Ссылка создана!" (16pt, weight 600, orange)
  * Body text: "Готово к отправке в мессенджер:" (14pt, gray)
  * Generated link display: monospace font, truncated at 40 chars
    Format: "https://familyrecipes.app/request/abc123..." (#FF6B35)
  * Two buttons below:
    - "Скопировать" (solid, secondary)
    - "Поделиться" (solid, orange)
  * Rounded corners 12pt, padding 16pt
  * Top spacing: 24pt

Form styling:
- Vertical padding: 20pt on sides
- White background (#FFFFFF)
- No scrollable content if both fields visible

Style:
- Light theme
- Primary accent: warm orange (#FF6B35)
- Label text: dark gray (#2C2C2C), weight 600
- Input text: dark gray (#2C2C2C)
- Placeholder text: light gray (#B0B0B0)
- Helper text: medium gray (#6B6B6B), italic

Behavior:
- Both fields required before button is enabled (button grayed out otherwise)
- Keyboard appears on field focus
- Success state replaces button and shows generated link
- Copy action copies link to clipboard with toast notification
- Share action opens iOS share sheet
```

---

## 🖥️ Экран 4: Settings (Ещё)

### Назначение
Доступ к контактам семьи, авторским правам и выходу из аккаунта.

### Структура
```
┌─────────────────────────────┐
│ Настройки    [⚙️]          │  ← Large title
├─────────────────────────────┤
│                             │
│ [👥] Семья и друзья   >     │  ← Link row
│                             │
│ [©️] Авторские права   >    │  ← Link row
│                             │
│ [Выйти из аккаунта]        │  ← Destructive button
│                             │
│ ┌────────────────────────┐ │
│ │ Вы уверены, что хотите │ │  ← Confirmation dialog
│ │ выйти из аккаунта?     │ │
│ │                        │ │
│ │ [Отмена] [Выйти] (red) │ │
│ └────────────────────────┘ │
│                             │
└─────────────────────────────┘
   [📖] Рецепты | Запросить... | Ещё...
```

### Google Stitch промпт

```
iOS app screen — Settings view.

Header:
- "Настройки" as large title (20pt, weight 700)
- Tab icon "⚙️" visible at bottom
- Navigation style: NavigationStack

Main Content:
- List of navigation links and buttons:

Link 1 - "Семья и друзья"
  * Icon: 👥 (person.2)
  * Text: "Семья и друзья" (16pt, weight 500)
  * Disclosure: > (chevron right)
  * Tap: navigates to Contacts screen
  * Background: white, 1px bottom divider
  * Full width, padding 16pt vertical, 20pt horizontal
  * Tap animation: subtle gray background

Link 2 - "Авторские права"
  * Icon: © (c.circle)
  * Text: "Авторские права" (16pt, weight 500)
  * Disclosure: > (chevron right)
  * Tap: navigates to Credits screen
  * Background: white, 1px bottom divider
  * Full width, padding 16pt vertical, 20pt horizontal

Button - "Выйти из аккаунта"
  * Text: "Выйти из аккаунта" (16pt, weight 600)
  * Style: destructive (red background #E74C3C)
  * Full width
  * Padding: 16pt vertical, 20pt horizontal
  * Top spacing: 24pt from link above
  * Tap action: shows confirmation dialog

Confirmation Dialog:
  * Title: "Выйти из аккаунта?"
  * Buttons:
    - "Отмена" (secondary)
    - "Выйти" (destructive, red)
  * Dialog background: white, blur backdrop
  * Border radius: 12pt

Style:
- Light theme, white background
- List style: plain
- Text primary: dark gray (#2C2C2C)
- Dividers: light gray (#E0E0E0), 1px
- Destructive button: red (#E74C3C)
- Chevron icon: light gray (#B0B0B0)
```

---

## 🔄 Общие правила компоновки

1. **Padding & Spacing**:
   - Horizontal padding (sides): 16-20pt
   - Vertical spacing (between sections): 16-24pt
   - Card padding (inside): 12-16pt

2. **Скругления**:
   - Карточки и inputs: 12-14pt border radius
   - Buttons: 10pt border radius (iOS standard)

3. **Шрифты**:
   - Headlines: SF Pro Display, 20pt, weight 700
   - Subheadings: SF Pro Display, 16pt, weight 600
   - Body: SF Pro Text, 15pt, weight 400
   - Captions: SF Pro Text, 12pt, weight 500

4. **Тени**:
   - Карточки: subtle shadow, offset (0, 2), blur 4, opacity 0.1
   - Buttons: no shadow (clean iOS style)

5. **Состояния элементов**:
   - Disabled: opacity 0.5, cursor not-allowed
   - Hover/pressed: background slightly darker (2-5% opacity)
   - Loading: spinner (SF Symbols: hourglass)

6. **Доступность**:
   - Все tap targets: minimum 48x48pt
   - Text contrast: WCAG AA (4.5:1 minimum)
   - Font sizes: not smaller than 12pt

---

## 📋 Порядок генерации в Google Stitch

**Рекомендуемый порядок для максимально точного результата**:

1. **Экран 1: Recipes List** (самый базовый)
   - Карточки рецептов, табовая навигация
   - Используйте промпт "Recipes List"

2. **Экран 2: Recipe Detail** (самый сложный)
   - Все элементы: карточка рецепта, заметки, кнопка уточнения
   - Используйте промпт "Recipe Detail"

3. **Экран 3: Create Request** (форма)
   - Два текстовых поля, кнопка, success state
   - Используйте промпт "Create Request"

4. **Экран 4: Settings** (список)
   - Ссылки и кнопка logout
   - Используйте промпт "Settings"

---

## 🎯 Ожидаемый результат

После генерации каждого экрана в Google Stitch:

✅ Экспортируйте в **Figma** (Standard Mode)
✅ Соберите все 4 экрана в один Figma файл
✅ Создайте **component library** (buttons, cards, input fields)
✅ Поделитесь ссылкой в пуле дизайнов для handoff разработчикам

**Ожидаемое время**: ~30-45 минут на все 4 экрана (350 генераций / месяц = ~90 слов на экран)

---

## 📞 Контакты и clarifications

- **Product Owner**: пользователи 30+, семьи
- **Design Review**: проверить соответствие color scheme, spacing, font sizes
- **Dev Handoff**: экспортировать координаты, дистанции, цвета в Figma Specs mode

---

*Это ТЗ скормлено в Google Stitch. Каждый промпт независим и может использоваться отдельно.*

# Сессия 2026-02-25 — Editorial Premium Redesign

## Задача
Полный визуальный редизайн `web-mobile/index.html` в стиле Modern Heritage — "семейная книга рецептов в современном приложении".

## Что сделали

### Дизайн-система
- CSS custom properties: `--bg`, `--surface`, `--text`, `--muted`, `--line`, `--primary`, + цвета авторов (`--mom`, `--dad`, `--bro`, `--sis`).
- Все стили через переменные, ноль хардкодов.

### Типографика
- Google Fonts: Fraunces (заголовки), Manrope (UI/текст), IBM Plex Sans (labels).
- Иерархия: H1 34px, H2 22-26px, card title 19px, body 15-16px, labels 11-12px.

### Layout
- Segment-control табы (вместо underline-табов).
- Sticky header + tabs.
- Safe-area для iOS.

### Карточки рецептов
- Premium: radius 20px, border `--line`, soft shadow, surface background.
- Цветная левая полоса по автору (4px, CSS `::before`).
- Author chip с цветным фоном (Мама — розовый, Папа — синий, Брат — зелёный, Сестра — золотой).

### Детали рецепта
- Fraunces заголовок 26px.
- Цветной author chip.
- Оригинал: итальик, `--surface-2` фон, `--line` левая полоса.

### Вкладка "Запросить"
- Тёплые поля ввода, оранжевая CTA-кнопка.
- "История запросов" визуально отделена divider + заголовок Fraunces.
- Бейджи `ожидает`/`получен` в тёплых тонах.

### Reply screen
- Тёплый фон `--bg`.
- Оранжевый accent вместо синего.
- Fraunces заголовки.

### Микроанимации
- 180ms ease transitions на: табах, карточках (scale), кнопках, полях (focus border).

## Что не менялось
- `src/index.html` не тронут.
- localStorage-схема без изменений.
- JS логика (tab switching, reply flow, recipe parsing) без изменений.
- Demo recipes данные без изменений.

## Handoff
- Где остановились: редизайн done, commit pushed.
- Следующий шаг: тест на телефоне, собрать обратную связь от семьи.

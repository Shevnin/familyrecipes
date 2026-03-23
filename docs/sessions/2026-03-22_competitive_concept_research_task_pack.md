# Сессия: Research похожих концепций + backlog synthesis

Дата: 2026-03-22

## Контекст
- FamilyRecipes — не "ещё одно приложение с рецептами", а продукт на стыке:
  - личной кулинарной памяти;
  - передачи рецептов от близких людей;
  - zero-install donor flow;
  - сохранения не только инструкции, но и истории рецепта;
  - кулинарной культуры как формы общения между поколениями.
- Пользователь хочет не просто посмотреть прямых recipe-конкурентов, а найти **похожие концепции в интернете**, в которых есть:
  - личная передача знания;
  - память о человеке;
  - тёплый / “ламповый” контекст;
  - low-friction contribution;
  - коллекция, к которой потом возвращаются для практического использования;
  - межпоколенческая коммуникация через еду, привычки, ритуалы и семейные способы готовить.
- По итогам исследования нужно не абстрактное summary, а **набор конкретных backlog-задач** для продукта.

## Задача для Claude
Проведи внешний research по похожим концепциям и на основе находок предложи backlog-задачи для FamilyRecipes.

## Что именно искать
Искать не только recipe apps. Нужны и смежные паттерны:

1. Продукты для семейной памяти / наследия
   - family memory apps
   - legacy / keepsake apps
   - story preservation products

2. Продукты для передачи знаний между близкими людьми
   - apps for passing down traditions
   - voice/text memory capture
   - personal archive / life stories / family history
   - intergenerational knowledge transfer

3. Продукты с низким барьером участия для второго человека
   - invite-by-link flows
   - no-login contribution flows
   - guest submission / share-back experiences

4. Продукты, где важен не только контент, но и автор / происхождение
   - provenance / author context
   - “who taught me this” mechanics
   - annotation / story around content

5. Продукты, где люди возвращаются к сохранённому не ради коллекции, а ради повторения / практики
   - repeatable cooking / craft / rituals
   - saved-how-to knowledge

## Что нужно собрать по каждому примеру
Для каждого найденного продукта / концепции:
- что это такое;
- чем он похож на FamilyRecipes;
- какая там сильная идея или механика;
- какая там подача / framing;
- что можно адаптировать;
- что не подходит для нашего MVP.

## Как проводить анализ
- Не ограничивайся прямыми конкурентами из категории “recipe app”.
- Ищи cross-category аналоги.
- Отделяй:
  - category competitors;
  - adjacent products;
  - concept analogies.
- Смотри не только на фичи, но и на:
  - positioning;
  - copywriting;
  - onboarding;
  - contribution mechanics;
  - emotional framing;
  - how products frame tradition, inheritance, and communication between generations.

## Что нужно получить на выходе

### 1. Короткий synthesis
Сделай краткий вывод:
- какие повторяющиеся паттерны встретились;
- где FamilyRecipes реально отличается;
- какие product angles звучат сильнее всего.

### 2. Product angles
Сформулируй 3-5 возможных product framings для FamilyRecipes.

Например, проверить такие оси:
- “рецепты как память о человеке”
- “личная кулинарная библиотека близких людей”
- “получить рецепт у конкретного человека без барьера”
- “не каталог, а живая передача рецепта”
- “рецепты, которые хочется повторять, а не просто хранить”
- “кулинарная культура как способ общения между поколениями”

### 3. Backlog proposals
Сконвертируй выводы в конкретные backlog items.

Для каждой backlog-задачи укажи:
- короткий id / название;
- проблему, которую она решает;
- гипотезу ценности;
- примерный scope;
- почему это важно именно сейчас / позже;
- приоритет: `P0`, `P1` или `P2`.

## Типы задач, которые особенно интересны
- onboarding / explainer copy
- donor conversion improvements
- share text / invite framing
- recipe story UX
- trust / warmth cues
- attribution / provenance in recipe detail
- repeat cooking loop
- reminders to return to recipe
- personal adaptation layer
- “from whom / why special” signals

## Ограничения
- Не предлагать большой social/feed layer как ближайший шаг.
- Не уводить продукт в generic recipe discovery.
- Не раздувать MVP в сторону тяжёлого structured editor.
- Не предлагать всё подряд: лучше меньше, но точнее.
- Приоритетно искать идеи, которые усиливают:
  - donor conversion;
  - emotional differentiation;
  - repeat usage;
  - sense of authorship and story;
  - intergenerational meaning of the product.

## Формат ответа
Ответ оформи в 4 блоках:

1. `Похожие концепции`
2. `Повторяющиеся паттерны`
3. `Что это значит для FamilyRecipes`
4. `Предлагаемые backlog-задачи`

Backlog-задачи отсортируй по приоритету.

## Отдельная просьба
Если увидишь, что в исследовании начинают лучше работать слова не “семейные рецепты”, а что-то шире:
- “рецепты близких людей”
- “личная кулинарная память”
- “рецепты с историей”
- “от кого этот рецепт”

то зафиксируй это отдельно как рекомендацию для product positioning.

Отдельно проверь и зафиксируй, насколько сильна такая рамка:
- “культура кулинарии — это культура общения между поколениями”
- “рецепт — это не только инструкция, но и форма передачи опыта, интонации и семейного языка”

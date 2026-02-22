# FamilyRecipes Workflow (Discovery First)

## Цель
Сначала договориться о правильной идее и сценарии, потом переходить к реализации.

## Роли
- Человек (Owner): задает направление, выбирает приоритеты, принимает решения.
- ChatGPT: ведет discovery, фиксирует решения, собирает roadmap и backlog.
- Claude: подключается на фазе delivery и работает по task-card.

## Цикл discovery
1. **Idea framing**: для кого делаем и какую проблему решаем.
2. **Problem validation**: почему проблема реальна и как ее решают сейчас.
3. **Value proposition**: чем мы лучше текущих альтернатив.
4. **User flow draft**: happy path, edge-cases, риски срыва сценария.
5. **Success criteria**: как поймем, что гипотеза сработала.
6. **Initiatives**: какие продуктовые инициативы нужны.
7. **Roadmap assembly**: разложение инициатив по релизам/фазам.
8. **Backlog prioritization**: конкретные задачи в порядке приоритета.
9. **Decision**: `continue`, `pivot` или `stop`.

## Обязательные артефакты
- Продуктовая рамка: `/Users/user/git-project/familyrecipes/docs/product_brief.md`
- Roadmap: `/Users/user/git-project/familyrecipes/docs/roadmap.md`
- Backlog: `/Users/user/git-project/familyrecipes/docs/backlog.md`
- Журнал решений: `/Users/user/git-project/familyrecipes/docs/decisions.md`
- Протоколы сессий: `/Users/user/git-project/familyrecipes/docs/sessions/`
- Шаблоны: `/Users/user/git-project/familyrecipes/docs/templates/`

## Формат сессии
1. Вход: тема, гипотеза, что хотим проверить.
2. Разбор: пользователь, боль, альтернативы, главный риск.
3. Выход: что решили и какие файлы обновили.

## Условие перехода в delivery
- Есть 1 приоритетный flow.
- Есть roadmap минимум на 2 фазы.
- Есть backlog с приоритетами и критериями готовности.
- Есть task-card шаблон и готовый набор первых задач.

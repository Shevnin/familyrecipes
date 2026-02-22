# FamilyRecipes

Проект: **FamilyRecipes** — приложение для обмена рецептами.

## Как работаем
Итеративно: **discovery → приоритизация → roadmap/backlog → delivery**.

Роли:
- **Человек (Owner)** = формулирует идею, выбирает приоритеты, принимает решения.
- **ChatGPT** = ведет product discovery: гипотезы, флоу, рамки экспериментов, roadmap и backlog.
- **Claude Code** = подключается позже, только на фазе delivery, после согласованных task-card.

## Принципы discovery
- Сначала валидируем проблему и ценность, потом пишем код.
- Каждый цикл заканчивается явным решением: `continue`, `pivot` или `stop`.
- Любая идея доводится до артефактов: flow, roadmap, backlog.
- Документация — source of truth: `/docs/project.md`, `/docs/workflow.md`, `/docs/decisions.md`, `/docs/planning/*`.

## Текущий фокус
- Фаза: **Product Discovery**
- Цель фазы: определить 1 приоритетный пользовательский сценарий и собрать первый реалистичный roadmap с backlog.

## Основные документы
- Discovery процесс: `/Users/user/git-project/familyrecipes/docs/workflow.md`
- Discovery flow: `/Users/user/git-project/familyrecipes/docs/flows/discovery_flow.md`
- Roadmap: `/Users/user/git-project/familyrecipes/docs/planning/roadmap.md`
- Backlog: `/Users/user/git-project/familyrecipes/docs/planning/backlog.md`
- Сессии обсуждений: `/Users/user/git-project/familyrecipes/docs/sessions/`

## Репозиторий
- `docs/` — продуктовая документация и артефакты discovery
- `docs/archive/` — архив старых артефактов (включая ранние прототипные флоу)

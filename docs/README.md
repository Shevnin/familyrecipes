# FamilyRecipes Docs

Один стартовый файл для текущей фазы `product discovery`.

## Граница фаз
- Пока не начата реализация реальных мобильных приложений (Flutter) и серверной части, проект находится в фазе **product discovery**.
- Прототипы, макеты, тестовые экраны и гипотезы до этого момента считаются discovery-работой.
- Фаза **delivery (реальная разработка)** начинается только с запуска мобильной + серверной реализации.

## Start Here
1. Прочитать текущее состояние: `/Users/user/git-project/familyrecipes/docs/current_state.md`
2. Прочитать продуктовую рамку: `/Users/user/git-project/familyrecipes/docs/product_brief.md`
3. Пройти рабочий процесс: `/Users/user/git-project/familyrecipes/docs/workflow.md`
4. Проверить текущий план: `/Users/user/git-project/familyrecipes/docs/roadmap.md`
5. Открыть приоритеты на сейчас: `/Users/user/git-project/familyrecipes/docs/backlog.md`
6. Посмотреть последние решения: `/Users/user/git-project/familyrecipes/docs/decisions.md`

## Структура
- `product_brief.md` - что за продукт, для кого, ключевая гипотеза.
- `current_state.md` - где остановились и с чего начинать новую сессию.
- `workflow.md` - как мы ведем discovery от идеи до roadmap/backlog.
- `roadmap.md` - план релизов/фаз.
- `backlog.md` - приоритизированный список задач.
- `decisions.md` - журнал решений.
- `sessions/` - протоколы обсуждений.
- `templates/` - шаблоны для discovery и delivery.
- `archive/` - старые материалы, которые не используем в текущем фокусе.

## Правило актуальности
- Все, что влияет на текущую работу, держим в корне `docs/`.
- Все исторические материалы перемещаем в `docs/archive/`.

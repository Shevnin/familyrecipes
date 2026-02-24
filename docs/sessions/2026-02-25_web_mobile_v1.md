# Сессия 2026-02-25 — Web Mobile v1

## Задача
Новый прототип `web-mobile/` — мобильный web-app для сбора рецептов по ссылкам.

## Что сделали
- Создан `web-mobile/index.html` — отдельный mobile-first прототип, не трогая `src/index.html`.
- Экран requester: список рецептов + вкладка "Запросить" (кому + блюдо → генерация ссылки).
- Reply flow (`?r=token`): мобильная форма "Делимся / Вас попросили поделиться рецептом".
- iOS web-app meta: apple-mobile-web-app-capable, viewport-fit=cover, safe-area padding.
- Empty state с иконкой и подсказкой.
- Эвристический парсер рецепта (ингредиенты + шаги).
- Статусы запросов: "ожидает" / "получен".
- Всё на localStorage, без backend.

## localStorage-схема (те же ключи, что в src/)
- `recipe_requests`: `[{ id, token, requester, target_person, requested_title, status, created_at }]`
- `recipe_responses`: `[{ token, title, body, sender, created_at }]`

## URL (GitHub Pages)
- Requester: `https://shevnin.github.io/familyrecipes/web-mobile/`
- Reply: `https://shevnin.github.io/familyrecipes/web-mobile/?r=<token>`

## Handoff
- Где остановились: v1 done.
- Следующий шаг: тест на телефоне, показать маме.

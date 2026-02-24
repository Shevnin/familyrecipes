# Current State (Session Handoff)

Обновлено: 2026-02-25

## Фаза
- Текущая фаза: **Product Discovery + Prototype Validation**
- Stage-Gate этап: **3) MVP Validation [current]**
- Важно: до старта Flutter + backend это не delivery.

## Где остановились
- Текущий roadmap-этап: `R1 - Split Screen Prototype` (`docs/roadmap.md`)
- Последняя зафиксированная сессия: `docs/sessions/2026-02-25_web_mobile_v1.md`

## Прототипы
1. **Split-screen** (старый): `src/index.html` — два телефонных экрана рядом
   - URL: https://shevnin.github.io/familyrecipes/src/index.html
2. **Web Mobile** (новый, основной): `web-mobile/index.html` — мобильный web-app
   - Requester: https://shevnin.github.io/familyrecipes/web-mobile/
   - Reply: `https://shevnin.github.io/familyrecipes/web-mobile/?r=<token>`

## Что умеет web-mobile
1. **Requester:** список полученных рецептов, запрос рецепта по ссылке, история запросов.
2. **Reply flow:** родственник открывает ссылку → видит форму "Делимся" → вводит рецепт → submit.
3. **Детали рецепта:** оригинал + структурированная версия (эвристический парсер).
4. **iOS web-app:** meta для add-to-home-screen, safe-area, mobile-first UI.
5. **Персистентность:** `recipe_requests` и `recipe_responses` в localStorage.

## Что сейчас в приоритете (P0)
1. Тест web-mobile на реальном телефоне.
2. Показать прототип маме и собрать обратную связь.

## Первый шаг в новой сессии
1. Прочитать этот файл.
2. Прочитать последнюю запись в `docs/sessions/`.
3. Проверить `docs/backlog.md` и выбрать задачу.

## Технический контекст
- Branch: `main`
- Файлы: `src/index.html` (split-screen), `web-mobile/index.html` (mobile)
- localStorage ключи: `recipe_requests`, `recipe_responses`
- Деплой: GitHub Pages (автоматический с main)

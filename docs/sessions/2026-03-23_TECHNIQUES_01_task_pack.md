# Сессия: TECHNIQUES-01 — новый блок `Техники` с тем же циклом, что и у рецептов

Дата: 2026-03-23

## Контекст
- В FamilyRecipes уже есть полноценный цикл для рецепта:
  - запрос рецепта;
  - donor web reply без установки приложения;
  - unified card в приложении;
  - detail screen;
  - clarification request через `parent_recipe_id`;
  - mastery loop (`получил` -> `пробовал` -> `почти получилось` -> `замастерил`).
- Сейчас этот цикл жёстко зафреймлен как `recipe`, хотя по продуктовой логике рядом нужен ещё один тип сущности: **базовые кулинарные техники**.
- Пользовательский смысл нового блока:
  - это не отдельная новая вкладка продукта и не отдельный мини-апп;
  - это соседняя сущность рядом с рецептами;
  - техника должна жить через тот же request/reply/mastery loop, что и рецепт.

Примеры того, что считается техникой:
- как жарить лук до нужного состояния;
- как варить прозрачный бульон;
- как делать зажарку;
- как замешивать дрожжевое тесто;
- как формировать котлеты, чтобы не разваливались.

Это не seed-каталог и не библиотека chef tips. Это те же "карточки знаний от близких людей", но про **базовый кулинарный навык**, а не про конкретное блюдо.

Основные source-of-truth документы:
- `/Users/user/git-project/familyrecipes/docs/current_state.md`
- `/Users/user/git-project/familyrecipes/docs/decisions.md`
- `/Users/user/git-project/familyrecipes/docs/backlog.md`
- `/Users/user/git-project/familyrecipes/docs/roadmap.md`
- `/Users/user/git-project/familyrecipes/docs/product_brief.md`

Ключевые технические точки в текущем коде:
- `/Users/user/git-project/familyrecipes/supabase/migrations/00005_unified_card_model.sql`
- `/Users/user/git-project/familyrecipes/supabase/migrations/00008_mastery_loop.sql`
- `/Users/user/git-project/familyrecipes/supabase/functions/create-request/index.ts`
- `/Users/user/git-project/familyrecipes/supabase/functions/get-request-meta/index.ts`
- `/Users/user/git-project/familyrecipes/supabase/functions/submit-request/index.ts`
- `/Users/user/git-project/familyrecipes/supabase/functions/get-edit-meta/index.ts`
- `/Users/user/git-project/familyrecipes/supabase/functions/update-submitted-recipe/index.ts`
- `/Users/user/git-project/familyrecipes/web-reply/index.html`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/RecipesView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/RecipeDetailView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Request/CreateRequestView.swift`

## Цель
Добавить в первый пользовательский раздел приложения новый блок `Техники`, который по смыслу параллелен `Рецептам`, но предназначен для базовых кулинарных техник и проходит **тот же цикл**:

1. пользователь просит технику у близкого человека;
2. близкий человек отправляет технику через web form;
3. техника появляется в приложении как карточка;
4. пользователь практикует её и видит mastery progress;
5. при необходимости может запросить уточнение тем же clarification flow.

Итог должен ощущаться так:
- FamilyRecipes хранит не только блюда, но и способы научиться готовить;
- базовые техники не выбиваются в отдельный продуктовый мир;
- рецепты и техники живут в одном loop, но различаются смыслом и copy.

## Главная продуктовая модель

### 1. Нужен не второй backend-мир, а второй `content kind`
В этом пакете **не нужно** создавать параллельную инфраструктуру наподобие отдельных таблиц `techniques`, отдельных request-таблиц и отдельного mastery-loop стека.

Предпочтительная модель MVP:
- сохранить существующую архитектуру;
- добавить в существующие сущности явный тип контента, например:
  - `recipe`
  - `technique`
- провести этот `content_kind` через:
  - storage;
  - read-model;
  - create request flow;
  - donor submit/edit flow;
  - iOS UI.

Иными словами:
- рецепт и техника различаются **типом карточки**;
- жизненный цикл и mastery loop у них общие.

### 2. Не надо ломать существующие названия на уровне инфраструктуры, если это слишком дорого
Допустимо, если внутренне временно сохранятся старые имена:
- таблица `recipes`;
- view `family_recipe_cards`;
- `FamilyRecipeCard`;
- `recipe_id`;
- `recipe_title`;
- `original_text`.

Но при этом должен появиться новый явный `content_kind`, а user-facing copy должна корректно различать:
- `рецепт`;
- `техника`.

### 3. `Техника` — не "совет", а полноценная карточка
Техника в MVP должна:
- иметь название;
- иметь основной текст;
- при желании иметь story/context;
- уметь быть запрошенной;
- уметь быть уточнённой;
- участвовать в mastery loop.

Техника в этом пакете **не обязана** иметь специальную structured schema.

## Что нужно сделать

### 1. Backend: ввести `content_kind`

#### `BE-SPEC-06`
Нужно зафиксировать и затем реализовать storage/read-model контракт для двух типов:
- `recipe`
- `technique`

Предпочтительный путь:
- добавить `content_kind` в `recipes`;
- добавить `content_kind` в `recipe_requests`;
- при необходимости синхронизировать его в `recipe_submissions` только если это реально помогает edit/read flow;
- существующим строкам проставить default `recipe`.

#### Read-model
`family_recipe_cards` должен возвращать `content_kind` для:
- pending request cards;
- received cards;
- clarification cards.

Важно:
- `mastery_status` остаётся ортогональным `card_status`;
- логика mastery loop должна одинаково работать и для рецептов, и для техник;
- clarification через `parent_recipe_id` может продолжать работать поверх существующей сущности, если `recipe_id` остаётся id любой полученной карточки.

### 2. Edge Functions и public contract
Нужно обновить flow так, чтобы тип контента не терялся.

#### `create-request`
Должен начать принимать `content_kind`.

Для техники share copy должна быть другой по смыслу, например:
- рецепт: `поделитесь рецептом ...`
- техника: `поделитесь техникой ...`

#### `get-request-meta`
Должен возвращать `content_kind`, чтобы donor web form умела адаптировать copy.

#### `submit-request`
При submit техника не должна превращаться обратно в `recipe` по default.
При создании записи type должен сохраниться.

#### `get-edit-meta`
Должен возвращать `content_kind` для edit mode.

#### `update-submitted-recipe`
Edit flow не должен терять `content_kind`.

### 3. Donor web flow
`/Users/user/git-project/familyrecipes/web-reply/index.html`

Нужно сделать donor form copy-aware по `content_kind`.

Минимально:
- если `content_kind = recipe`
  - оставить текущую механику;
- если `content_kind = technique`
  - адаптировать все user-facing тексты.

Что должно меняться для техники:
- заголовок/контекст формы;
- label `Название рецепта` -> `Название техники`;
- label `Рецепт` -> `Техника` или `Описание техники`;
- CTA `Отправить рецепт` -> `Отправить технику`;
- fulfilled/success/edit-success states;
- copy в about block, чтобы там были упомянуты и рецепты, и техники.

Важно:
- не делать отдельную вторую страницу;
- использовать ту же donor web форму;
- edit flow тоже должен корректно называться для техники.

### 4. iOS: новый пользовательский блок `Техники`
Нужен новый блок/раздел внутри текущего первого app section.

Важно:
- **не выносить это в отдельную корневую tab bar вкладку**;
- пользователь должен понимать, что это соседний блок рядом с рецептами, а не другой продукт.

Допустимые UX-формы:
- segmented control `Рецепты / Техники`;
- или два явно разделённых блока/секции в одном экране.

Предпочтение:
- выбрать решение, которое чище всего ложится в текущий `RecipesView` и не превращает экран в длинную смешанную ленту.

Минимально пользователь должен уметь:
- переключиться на `Техники`;
- увидеть только карточки техник;
- открыть detail техники;
- создать технику вручную;
- запросить технику у близкого человека;
- пройти тот же mastery loop.

### 5. iOS list/detail/request flows

#### List screen
В `FamilyRecipeCard` / read-model на клиенте должен появиться `contentKind`.

На list screen:
- фильтрация и поиск должны работать и для техник;
- status badge остаётся;
- mastery badge остаётся;
- copy не должна говорить "рецепт", если это техника.

#### Detail screen
Нужна адаптация copy под тип карточки.

Примеры:
- `История рецепта` -> для техники нужен нейтральный или специальный заголовок;
- если CTA звучит как `Отметить готовку`, для техники это уже неидеально;
- для техники лучше framing уровня:
  - `Отметить практику`
  - `Отметить попытку`
  - `Потренировал(а)`.

Claude может выбрать формулировку сам, но она должна:
- звучать естественно для базовой техники;
- не ломать recipe copy;
- не делать из UI спортивный трекер.

#### Request creation flow
Пользователь должен уметь запросить именно технику, а не только рецепт.

Предпочтительно:
- в request form добавить явный выбор типа:
  - `Рецепт`
  - `Техника`
- поле `Название рецепта` должно адаптироваться по типу.

#### Clarification flow
Если пользователь уточняет уже полученную технику:
- новый draft должен сохранять `content_kind = technique`;
- prefill должен звучать как уточнение техники, а не рецепта.

### 6. Manual create flow
Сейчас в iOS есть manual create только для рецепта.

Нужно дать путь создать вручную и технику тоже.

Допустимые варианты:
- переиспользовать текущий `CreateRecipeView`, сделав его generic по `content_kind`;
- или сделать обёртку/экран выбора типа перед созданием.

Важно:
- не городить тяжёлый новый editor;
- вручную созданная техника должна попадать в тот же список карточек и иметь тот же `content_kind`.

### 7. Mastery loop для техник
Техники должны идти по **тому же mastery loop**, что и рецепты.

Это значит:
- те же состояния mastery;
- тот же storage attempts;
- тот же list/detail read-model;
- те же возможности note + clarification.

Но user-facing wording для техники может и должен быть чуть более нейтральным, чем "готовка блюда".

Важно:
- не дублировать backend-логику attempts под отдельные `technique_attempts`;
- использовать общий механизм.

## Важные ограничения
- Не делать отдельные таблицы и отдельный второй lifecycle только для техник, если этого можно избежать.
- Не добавлять новую корневую вкладку в tab bar.
- Не делать отдельный web flow только под техники.
- Не делать в этом пакете seed library базовых техник.
- Не делать AI-generated catalog, рекомендации или taxonomy.
- Не превращать техники в "советы на полях" без полноценной карточки.
- Не ломать существующий recipe flow и текущие карточки рецептов.

## Acceptance criteria
- В модели данных появляется явный `content_kind` с минимум двумя значениями: `recipe`, `technique`.
- Существующие рецепты продолжают работать и читаются как `recipe`.
- Пользователь может создать request именно для техники.
- Donor web page корректно показывает copy для техники и сохраняет технику тем же submit flow.
- В приложении есть новый пользовательский блок/раздел `Техники` внутри первого app section.
- Пользователь может открыть карточку техники, увидеть её detail и пройти тот же mastery loop.
- Clarification flow работает и для техники.
- Manual create позволяет создать не только рецепт, но и технику.
- Recipe flow не ломается и не становится путаным из-за появления `technique`.

## Что не делаем в этом пакете
- Отдельный каталог предзаполненных техник.
- Отдельный продуктовый раздел с другой навигацией и архитектурой.
- Специальную taxonomy техник по уровням сложности.
- Structured cooking school / onboarding around techniques.
- Отдельные виды mastery status только для техник.
- Android parity, если это мешает быстро довести iOS + backend + donor flow до рабочего состояния.

## Рекомендуемый порядок реализации
1. Прочитать этот task pack и актуальные source-of-truth docs.
2. Зафиксировать минимальный контракт `content_kind`.
3. Сделать backend migration + read-model update.
4. Протянуть `content_kind` через Edge Functions и donor web flow.
5. Обновить iOS models/view models.
6. Собрать UI блока `Техники` и адаптировать create/request/detail copy.
7. Проверить clarification и mastery loop для обоих типов.
8. После реализации обновить:
   - `/Users/user/git-project/familyrecipes/docs/current_state.md`
   - `/Users/user/git-project/familyrecipes/docs/backlog.md`
   - `/Users/user/git-project/familyrecipes/docs/roadmap.md`
   - `/Users/user/git-project/familyrecipes/docs/decisions.md`

## Важные продуктовые ориентиры для Claude
- `Техники` должны ощущаться как естественное расширение FamilyRecipes, а не как side quest.
- Пользователь должен понимать: "я могу сохранить не только блюдо, но и способ научиться готовить".
- Надо сохранить человечность и семейную природу продукта: техника приходит от конкретного человека, а не от безличного справочника.
- UI должен помогать пользователю отличать блюдо от навыка, но не перегружать его лишним выбором.
- Лучше сделать один чистый общий loop с `content_kind`, чем два почти одинаковых независимых мира.

## Следующий шаг
Использовать этот файл как готовый task pack для Claude и попросить его реализовать пакет end-to-end: backend + donor web + iOS, без выноса техник в отдельный самостоятельный продуктовый модуль.

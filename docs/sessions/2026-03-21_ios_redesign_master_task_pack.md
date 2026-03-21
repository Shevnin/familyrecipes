# Сессия: iOS redesign from accepted Stitch style (master task pack)

Дата: 2026-03-21

## Контекст
- У FamilyRecipes уже есть рабочий iOS MVP на SwiftUI, но визуально он всё ещё в основном системный: `List`, `Form`, `borderedProminent`, `Capsule`, стандартный `TabView`.
- По дизайну принят новый baseline из Stitch:
  - `/Users/user/git-project/familyrecipes/DESIGN.md`
  - `/Users/user/git-project/familyrecipes/docs/stitch_design_package.md`
  - `/Users/user/git-project/familyrecipes/docs/stitch_exports/2026-03-21/list/screen.png`
  - `/Users/user/git-project/familyrecipes/docs/stitch_exports/2026-03-21/recipe_detail/screen.png`
- Принятый стиль называется `Warm Paper Notebook`.
- Уже зафиксированы ключевые продуктовые решения:
  - приложение text-first;
  - sans-only, без serif;
  - no-photo main flows;
  - маленькие скругления и плотное использование экрана;
  - donor reply target state в продуктовых docs = `recipe_text + donor_comment`, но текущий backend/app contract всё ещё `v1` и реально отдает `original_text`.

## Master Task Pack для Claude

### Цель
Переделать iOS-приложение визуально и структурно под принятый стиль `Warm Paper Notebook`, сохранив текущий функциональный объём MVP и не ломая рабочие backend/web контракты.

Нужен не новый продукт с нуля, а аккуратный redesign существующего SwiftUI app с переводом основных экранов на новый visual language.

### Главные референсы
- Product-wide style rules: `/Users/user/git-project/familyrecipes/DESIGN.md`
- Prompt/runbook and accepted design decisions: `/Users/user/git-project/familyrecipes/docs/stitch_design_package.md`
- Accepted Recipes List reference: `/Users/user/git-project/familyrecipes/docs/stitch_exports/2026-03-21/list/screen.png`
- Accepted Recipe Detail reference: `/Users/user/git-project/familyrecipes/docs/stitch_exports/2026-03-21/recipe_detail/screen.png`

### Что именно нужно получить
Приложение должно ощущаться как:
- warm paper notebook;
- text-first;
- practical and calm;
- compact on small iPhone screens;
- comfortable for long recipe reading and larger text sizes;
- visually more specific than стандартный SwiftUI, но без декоративной перегрузки.

### Важные ограничения
- Не менять рабочие backend endpoints и сетевые контракты без явной необходимости.
- Не ломать текущие flow:
  - login;
  - recipes list;
  - recipe detail;
  - create own recipe;
  - request recipe;
  - inline request history;
  - contacts CRUD;
  - logout;
  - share/copy request link.
- Не придумывать структуру рецепта, которой нет в данных.
  - На detail screen рецепт остаётся одним свободным текстовым блоком из `original_text`.
  - Не раскладывать его на ingredients / steps / stats / servings.
- На detail screen:
  - title = главный заголовок;
  - author = compact metadata row;
  - date не приоритетна и не должна доминировать;
  - donor recipe text + personal note должны ощущаться как один смысловой блок;
  - `Попросить уточнить` = маленькое вторичное действие.
- Пока не внедрять полноценную логику для отдельного `donor_comment` в iOS networking/model layer, если backend её ещё не отдаёт.
  - Можно сделать UI архитектурно готовым к этому, но без выдумывания данных.
- Не использовать serif в UI.
- Не делать bento, gallery, oversized cards, giant rounded search bars, floating dashboard UI.
- Не держать главный visual weight на фото.
- Не добавлять тяжёлые сторонние UI-библиотеки.
- Если подключение `Public Sans` как runtime font усложняет задачу, допустим очень близкий системный sans fallback, но без срыва направления.

### Текущие файлы/экраны, которые надо учитывать

Основные точки входа:
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/FamilyRecipesApp.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/MainTabView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/LaunchSplashView.swift`

Recipes:
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/RecipesView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/RecipeDetailView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/CreateRecipeView.swift`

Request:
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Request/CreateRequestView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Request/RequestHistorySection.swift`

Settings / Contacts:
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Settings/ContactsView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Settings/ContactEditView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Settings/CreditsView.swift`

Auth / shared UI:
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Auth/AuthView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/UI/ChipView.swift`

Если нужно, создай минимальный shared design layer в `Core/UI/` или рядом:
- color tokens;
- spacing/radius tokens;
- button/input/list row styles;
- shared section surfaces;
- tab bar treatment helpers.

### Порядок работы
1. `IOS-RD-01` Design foundation
   - Ввести минимальный shared design system для iOS implementation:
     - palette;
     - typography wrappers or font helpers;
     - spacing/radius constants;
     - reusable surfaces/dividers;
     - compact button/input styles.
   - Убрать зависимость экранов от случайных `Capsule`, default `.borderedProminent`, oversized rounded backgrounds.

2. `IOS-RD-02` Main navigation shell
   - Переделать `MainTabView` под compact text-first navigation.
   - Сохранить 3 вкладки: `Рецепты`, `Запросить`, `Ещё`.
   - Нижняя навигация должна получить больше графического характера, чем дефолтный iOS tab bar, но остаться компактной и не превратиться в жирную floating capsule.

3. `IOS-RD-03` Recipes List
   - Привести `RecipesView` к accepted Stitch list screen:
     - dense near-edge-to-edge rows;
     - thin dividers allowed;
     - quiet search / controls if needed;
     - readable title/author/date/note indicator;
     - compact top bar with plus action.
   - Экран должен быть text-first и не тратить экран на карточки.

4. `IOS-RD-04` Recipe Detail
   - Привести `RecipeDetailView` к accepted detail direction:
     - no photo;
     - no dashboard cards;
     - author only metadata emphasis;
     - one large readable donor recipe text surface;
     - very small `Попросить уточнить`;
     - near-seamless transition to personal note;
     - donor text + personal note = one working zone.
   - Снизить visual noise и радиусы.

5. `IOS-RD-05` Request Screen
   - Переделать `CreateRequestView` и `RequestHistorySection` под ту же систему.
   - Сохранить:
     - recipient field;
     - dish field;
     - repeat contact chips;
     - inline history;
     - success state with share/copy/history/new request.
   - Уйти от marketing-card look и больших pills.
   - История должна выглядеть как notebook context, а не admin dashboard.

6. `IOS-RD-06` Settings and Contacts
   - Перевести `Settings`, `ContactsView`, `ContactEditView`, `CreditsView` в тот же language:
     - compact list rhythm;
     - warm paper surfaces;
     - restrained accents;
     - low-chrome forms.
   - Контакты должны сохранить цветовые маркеры, но без лишней мультяшности.

7. `IOS-RD-07` Auth, Create Recipe, Splash polish
   - Привести `AuthView` и `CreateRecipeView` к той же системе.
   - `LaunchSplashView` отдельно пересмотреть:
     - текущий photo-led chef splash не совпадает с новым app direction;
     - либо сделать более спокойный notebook-like welcome,
     - либо явно упростить/свести visual weight splash к минимуму, если полный redesign за один проход слишком рискованный.
   - Не тянуть main product identity обратно в image-led territory.

8. `IOS-RD-08` Build and polish
   - Собрать приложение.
   - Проверить основные flow руками.
   - Проверить, что layout не разваливается при больших текстовых размерах.

### Детальные визуальные требования
- Основа экрана: warm paper background, а не холодный system gray.
- Большинство экранов: почти edge-to-edge content, компактные top/bottom bars.
- Dense list rows: примерно square-ish или very slightly softened, не карточки-визитки.
- Radius:
  - list rows: `0-6`;
  - text surfaces / grouped panels: `8-10`;
  - inputs: `6-8`;
  - buttons: `6-10`.
- Divider lines допустимы и полезны.
- Текст должен занимать экран, а не decorative whitespace.
- Typography:
  - sans only;
  - strong readable hierarchy;
  - Russian copy remains natural and legible.
- Цвет:
  - orange = primary action / active navigation;
  - green = secondary functional accent;
  - red = sparing emphasis only.
- Кнопки:
  - не giant pills;
  - не floating bubbles;
  - primary CTA на экране одна.
- Search/input containers:
  - компактные;
  - visually quiet;
  - без huge rounded hero search bars.

### Accessibility expectations
- Не ломать экран при Larger Text / Dynamic Type.
- Текст должен переноситься, а не схлопываться.
- Когда текст становится крупнее, вертикальный рост контента допустим.
- Приоритет у читаемости, а не у сохранения декоративной геометрии.
- Tap targets должны остаться удобными.

### Что можно менять смело
- SwiftUI layout structure;
- shared UI components;
- section wrappers;
- button styles;
- row styles;
- tab bar treatment;
- background/surface system;
- navigation bar presentation;
- note editor presentation;
- request success composition.

### Что менять осторожно
- Networking models and API mapping;
- auth/session behavior;
- request creation flow logic;
- local persistence contracts for notes/contacts/link cache.

### Acceptance criteria
- Визуально app больше не выглядит как смесь стандартных SwiftUI экранов.
- Recipes List близок к accepted Stitch list reference по плотности и характеру.
- Recipe Detail близок к accepted Stitch detail reference по reading comfort и структуре.
- Request screen логично вписан в тот же style system.
- Settings / Contacts / Auth / Create Recipe не выбиваются визуально.
- Bottom navigation получила характер, но осталась компактной и usable.
- Большие скругления и pill-overuse убраны.
- Нет serif typography.
- Нет image-led main flows.
- Основные flow по-прежнему работают end-to-end на текущем MVP.
- Сборка проходит.

### Формат финального отчёта от Claude
- Список changed files с кратким описанием.
- Какие shared UI primitives / theme tokens были добавлены.
- Какие экраны реально доведены до нового style baseline.
- Что проверено вручную.
- Был ли успешный build.
- Что осталось rough / какие остаточные риски есть.

## Следующий шаг
Передать этот pack в Claude и попросить выполнить redesign последовательно, начиная с design foundation и navigation shell, затем `Recipes List` и `Recipe Detail`, и только потом докручивать остальные экраны.

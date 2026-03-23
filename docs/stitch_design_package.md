# Stitch Design Package For FamilyRecipes

Updated: 2026-03-21

## Copy-paste quick start
Если цель: начать работу в Stitch прямо сейчас и не утонуть в опциях, используй только этот блок.

### Что выбрать сейчас
Use `Path A: fast parity-first run`.

Почему:
- он ближе всего к текущему iPhone MVP
- даёт быстрый результат на 4 основных экранах
- сохраняет возможность потом расшириться до donor flow, login, splash, contacts и full system

### Что делать в Stitch по шагам
1. Start a new Stitch project.
2. If Stitch supports context files, add `/Users/user/git-project/familyrecipes/DESIGN.md`.
3. If Stitch supports image context in your session, upload `/Users/user/git-project/familyrecipes/docs/mockups/request-detail-redesign.svg`; otherwise skip it.
4. Paste the master prompt below.
5. Ask Stitch to generate 4 current MVP screens first:
   - Recipes List
   - Recipe Detail
   - Request Screen
   - Settings
6. Run only 2 follow-up prompts after the first output:
   - `Prompt A: reading comfort`
   - `Prompt B: current MVP parity`
7. Export the strongest result to Figma.

### Master prompt to paste first
```text
Design a complete high-fidelity iPhone MVP for FamilyRecipes.

FamilyRecipes is not a recipe marketplace, not a social feed, and not a meal planner. It is a warm, modern, text-first mobile product for preserving and repeating family recipes across generations.

Primary users:
1. The "Master" user has the native app. They request recipes from relatives, receive recipes, read them, cook from them, save personal notes, and ask follow-up clarifications.
2. The "Donor" user exists in the product, but for this first pass focus only on the current iPhone app screens.

Core product promise:
- preserve the original family voice
- make recipes repeatable and practical
- feel trustworthy, calm, intimate, and premium

Visual direction:
- modern heritage
- warm paper-like backgrounds
- text-first notebook zoning
- clean sans-serif UI for both Latin and Cyrillic
- restrained corner radii
- low-chrome grouped sections
- soft depth only where necessary
- family warmth without kitsch

Avoid:
- generic productivity SaaS
- generic food delivery visuals
- neon gradients
- crowded dashboards
- social feed patterns
- bento layouts
- oversized floating cards
- image-led hero sections
- large pill buttons
- decorative serif typography in Russian

Use this color direction:
- background: warm off-white / paper beige
- surface: white or warm light surface
- text: charcoal / dark gray
- primary CTA: coral or terracotta
- success: soft olive-green
- contacts: stable color-coded chips

Use this typography direction:
- clean sans-serif for UI and body
- compact label style for metadata and chips
- no serif in Russian UI
- optimize for large accessibility text sizes

UI copy must stay in Russian.
Assume the core app works with no photos at all.

For this first pass, design only these 4 iPhone MVP screens:

1. Recipes List
- large navigation title: "Рецепты"
- top-right plus button
- states: loading, empty, error, data
- data state shows recipe list with title, author, date, and subtle note indicator
- bottom tab bar with 3 tabs: "Рецепты", "Запросить", "Ещё"

2. Recipe Detail
- navigation title is the recipe title
- metadata row with author chip and date
- highly readable recipe text card
- secondary CTA: "Попросить уточнить"
- personal note section: empty, existing, and edit states

3. Request Screen
- navigation title: "Запросить рецепт"
- recipient field
- dish field
- optional contact chips above the form
- primary CTA for creating request
- inline request history below the form
- success state with:
  - generated link card
  - "Поделиться ссылкой"
  - "Копировать"
  - "История"
  - "Новый запрос"

4. Settings
- navigation title: "Настройки"
- simple list with:
  - "Семья и друзья"
  - "Авторские права"
  - destructive sign-out action
- sign-out should imply a confirmation dialog

Behavioral expectations:
- one primary action per screen
- large tap targets
- comfortable reading of long recipe text
- request history stays inline on the same request screen
- request success must feel actionable, not like a dead end
- loading, empty, error, and success states should be clearly designed
- copy should imply clipboard feedback
- share should imply native iOS share sheet
- logout should imply native confirmation dialog
- assume some older users read with larger text enabled
- important text must wrap cleanly
- prioritize text area over decorative spacing
- use minimal but friendly corner radii
- use compact spacing and modern notebook zoning instead of showcase cards

Make the result feel specific, premium, warm, and memorable, but still realistic for a SwiftUI iPhone MVP.
```

### Prompt A: reading comfort
```text
Refine the recipe detail screen for long-form reading comfort. Increase hierarchy, text rhythm, and clarity of the original recipe block. Make the personal note feel private and lightweight. Keep the clarification CTA visible but secondary.
```

### Prompt B: current MVP parity
```text
Now tighten the design to stay closer to the current iPhone MVP information architecture. Keep the upgraded visual quality, but preserve:
- 3 tabs: Рецепты / Запросить / Ещё
- inline request history on the request screen
- request success with share, copy, history, and new request actions
- recipe detail with note section and clarification CTA
- settings as a simple list with contacts, credits, and sign out
```

### If the first result is too generic
Paste this extra prompt:

```text
Push the visual identity further toward "modern heritage editorial". Make it feel more premium and memorable, less like a default app template. Keep usability high. Increase typographic character, warmth, and emotional clarity without becoming decorative or old-fashioned.
```

### What not to do yet
- do not start with Android
- do not start with full donor web flow
- do not ask Stitch for all 20+ screens in the first pass
- do not export code before the 4-screen iPhone set feels coherent

### Text-first corrective prompt
Если Stitch продолжает рисовать слишком большие карточки, жирные скругления и “витринный” UI, вставь это отдельным сообщением:

```text
Course-correct the design direction.

This app is a text-first notebook for cooking, not a gallery and not a bento-card dashboard.
Assume there are no photos or decorative illustrations in the core app.
The design should feel like a modern mobile notebook for recipes.

Key changes:
- minimize decorative containers
- minimize empty padding that does not help reading
- use small modern corner radii, not big pill shapes
- use compact section spacing
- maximize useful text area on the phone screen
- rely on typography, alignment, dividers, and zoning instead of large cards
- keep the UI warm and premium, but quieter and denser

Typography:
- use sans-serif only for both Latin and Cyrillic
- no serif in Russian UI
- optimize for long-form reading and large accessibility text sizes
- assume older users may enable larger text to read without glasses

Layout behavior:
- important text must wrap cleanly
- decorative spacing should shrink before text readability does
- recipe text should get the most space on screen
- request history should look like compact list entries, not showcase cards
- buttons should have minimal but friendly rounding
- forms should look like notebook sections, not floating marketing blocks

Visual tone:
- modern
- text-oriented
- practical
- calm
- content-first
- premium through restraint, not through oversized UI
```

### Radius and spacing lock prompt
Если нужно прямо прибить стиль по геометрии, вставь это:

```text
Geometry correction:
- small corner radii only
- cards and grouped sections: 8-12 px radius
- inputs: 8-10 px radius
- buttons: 10-12 px radius
- avoid large pill buttons except where absolutely necessary
- avoid oversized floating cards
- keep horizontal padding tight but breathable
- reduce vertical whitespace
- prioritize text density and readability on a small phone screen
```

## Цель
Использовать Stitch для генерации полного high-fidelity дизайн-пакета для FamilyRecipes:
- native mobile flow для iOS и Android parity
- companion mobile web flow для донора
- переиспользуемая дизайн-система
- кликабельный прототип основного end-to-end сценария

## Почему Stitch подходит этому проекту
По официальным материалам Google, актуальным на 2026-03-21, Stitch умеет:
- turn prompts, wireframes, or images into high-quality UI and corresponding frontend code for desktop and mobile
- iterate conversationally and export to CSS/HTML or Figma
- generate higher-quality UI with Gemini 3
- stitch screens into working prototypes for interactions and user flows
- use an AI-native canvas that accepts text, images, and even code as project context
- extract a design system from a URL and import/export design rules through `DESIGN.md`

## Официальные источники
- Google Labs overview: <https://labs.google/about/>
- Stitch availability and base capabilities: <https://blog.google/innovation-and-ai/products/io-2025-tools-to-try-globally/>
- Gemini 3 and Prototypes update: <https://blog.google/innovation-and-ai/models-and-research/google-labs/stitch-gemini-3/>
- AI-native canvas, design agent, `DESIGN.md`, voice, and instant prototyping update: <https://blog.google/innovation-and-ai/models-and-research/google-labs/stitch-ai-ui-design/>
- Material 3 Expressive reference language for Android visual direction: <https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/>

## Best practices для нашего кейса
Ниже рекомендации, собранные из официальных возможностей Stitch и нашего продуктового контекста.

1. Start from intent, not screens.
Сначала описываем бизнес-цель, пользователя, нужную эмоцию и критерий успеха, а уже потом перечисляем экраны и компоненты.

2. Prompt in English, keep UI copy in Russian.
Это вывод из более ранней официальной формулировки Google про Stitch и English prompts. На сегодня это самый безопасный путь для качества.

3. Feed Stitch multiple context types.
В качестве контекста лучше подать сразу несколько типов материалов:
- `DESIGN.md` from the repo root
- the request-detail concept image at `/Users/user/git-project/familyrecipes/docs/mockups/request-detail-redesign.svg`
- the current donor web aesthetic as a URL reference when useful

4. Ask for a system, not isolated screens.
Просим не набор случайных экранов, а систему: компоненты, токены, типографику, отступы и состояния.

5. Generate the prototype early.
Раз Stitch поддерживает интерактивные flows, заказываем не только визуалы, но и связанный пользовательский маршрут.

6. Keep one emotional direction.
Для FamilyRecipes правильное направление: `modern heritage`, а не `modern productivity` и не playful cooking app.

7. Generate state coverage explicitly.
Явно просим loading, empty, error, success, expired и fulfilled states. Для нашего продукта это критично для доверия.

8. Keep donor friction near zero.
Donor web flow должен быть заметно проще установки приложения и проще длинной структурированной формы.

9. For the native app, prefer text-first notebook density over card-heavy layouts.
Для нашего основного мобильного приложения лучше text-first notebook approach, а не bento и не image-led card showcase.

## Продуктовый контекст для Stitch
### Product thesis
FamilyRecipes helps families turn "roughly how we cook it" into "we can reliably make it the family way."

### Who this is for
- families passing recipes across generations
- people who do not cook every day, but want to master 5-10 dependable recipes
- older relatives who may be uncomfortable with complex apps

### Anti-persona
- users looking for infinite recipe discovery
- users who want a social recipe feed

### Core value
- repeatability
- family context and origin
- low-friction transfer of knowledge

### Product roles
- Master: uses native app, requests recipes, reviews them, cooks from them
- Donor: uses zero-install mobile web link, submits recipe in free form

## Текущие продуктовые и визуальные референсы
### Product docs
- `/Users/user/git-project/familyrecipes/docs/product_brief.md`
- `/Users/user/git-project/familyrecipes/docs/current_state.md`
- `/Users/user/git-project/familyrecipes/docs/backlog.md`

### Existing visual references
- `/Users/user/git-project/familyrecipes/web-reply/index.html`
- `/Users/user/git-project/familyrecipes/web-mobile/index.html`
- `/Users/user/git-project/familyrecipes/docs/mockups/request-detail-redesign.svg`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/LaunchSplashView.swift`

## Список экранов, которые нужно заказать
### Core native app screens
1. Atmospheric splash / welcome screen
2. Login screen
3. Recipes empty state
4. Recipes list
5. Recipe detail
6. Recipe detail with personal note
7. Create own recipe modal
8. Request recipe form
9. Request success state
10. Request history row states: pending, fulfilled, expired
11. Settings
12. Contacts list
13. Create/edit contact

### Core donor mobile web screens
1. Request landing with short onboarding
2. Submission form
3. Success
4. Not found
5. Expired
6. Already fulfilled

### Near-term donor expansion screens
1. Short / detailed response mode switch
2. Draft restored banner
3. "Add another recipe" success continuation
4. Example of a good recipe answer

## Детализация для текущего iPhone MVP
Если цель не просто исследовать стиль, а быстро получить parity-friendly дизайн для текущего iOS приложения, держим в голове несколько жёстких ограничений текущего продукта.

### Текущий implementation context
- Stage: MVP R3
- Current native platform: iPhone / SwiftUI
- Current navigation model: 3 tabs — `Рецепты`, `Запросить`, `Ещё`
- Current interaction model: `NavigationStack`, list/detail navigation, sheets for some flows, inline history on request screen
- Copy language in UI: Russian

### Что важно сохранить при генерации
- one primary action per screen
- comfortable reading of long recipe text
- request history stays inline on the same request screen, not in a separate admin page
- request success is a full next-step state, not a tiny toast
- settings remain simple and list-based
- visual refinement is welcome, but information architecture should stay close to the current app unless we explicitly ask for divergence
- the native app should feel like a text notebook, not a card gallery
- minimize decorative spacing and oversized radii
- assume no photos in the core app flows
- support larger accessibility text sizes without the layout falling apart

## Screen-by-screen prompts for current MVP parity
Это не замена master prompt выше, а более точные follow-up prompts, если хочется отдельно дожать конкретные экраны для текущего iPhone MVP.

### 1. Recipes List
```text
Design an iPhone app screen for FamilyRecipes called "Рецепты".

This is a warm, editorial, modern-heritage recipe archive app, not a marketplace.
UI copy must stay in Russian.
Assume the core app uses no photos and is text-first.

Screen goals:
- show all recipes in a vertically scrolling list
- make title, author, and date easy to scan
- signal if a private note exists for a recipe
- include an add button for creating your own recipe

Required structure:
- small navigation title: "Рецепты"
- top-right plus button for creating a recipe
- main area supports these states: loading, empty, error, data
- in the data state, show recipe rows/cards with:
  - recipe title
  - author name if available
  - formatted date
  - subtle note indicator if a personal note exists
  - tap target opens recipe detail
- bottom tab bar with 3 tabs:
  - "Рецепты" selected
  - "Запросить"
  - "Ещё"

Visual direction:
- compact but breathable spacing, strong readability
- refined list rows or low-chrome grouped sections instead of oversized cards
- calm editorial hierarchy, not default productivity UI
- keep one-handed use in mind
- small radii, restrained surfaces, maximum text area

Behavioral expectations:
- pull to refresh in data state
- empty state should clearly explain that recipes appear after someone responds to a request
- error state should include a retry action
```

### 2. Recipe Detail
```text
Design an iPhone app screen for FamilyRecipes called recipe detail.

UI copy must stay in Russian.
This screen is for comfortable long-form reading of a family recipe.
Assume no photography or decorative image blocks.

Required structure:
- navigation title is the recipe title
- back navigation only; do not add an unnecessary overflow menu by default
- metadata row near the top:
  - author chip if author exists
  - date on the opposite side
- main recipe text inside a highly readable card or text surface
- secondary full-width CTA:
  - "Попросить уточнить"
  - only visible when author exists
  - clearly secondary, not louder than the recipe itself
- personal note section:
  - heading "Моя заметка"
  - empty state with "Добавить заметку"
  - existing note state with readable note card and "Редактировать"
  - edit state with text editor plus "Сохранить" and "Отмена"

Visual direction:
- prioritize reading comfort and text rhythm
- warm surfaces, subtle borders, almost no decorative depth
- strong spacing between metadata, recipe card, clarification CTA, and notes
- private, lightweight feeling for notes
- text-first notebook feeling with restrained radii and minimal chrome

Behavioral expectations:
- clarification CTA should feel like it prefills a request to the recipe author
- note controls should feel local and lightweight, not like heavy document editing
```

### 3. Request Screen
```text
Design an iPhone app screen for FamilyRecipes called "Запросить рецепт".

UI copy must stay in Russian.
This is the core action screen for requesting a recipe from a family member.
Assume no decorative images and no oversized floating cards.

Required structure:
- navigation title: "Запросить рецепт"
- form fields:
  - recipient name
  - dish name
- optional suggested contact chips above the form:
  - heading like "Уже просили у..."
  - warm, color-coded, repeatable contact chips
- primary CTA for creating the request

This screen has two major states:

State A: form state
- recipient and dish fields
- optional validation error area
- inline request history section below the form
- history rows should show:
  - dish name
  - recipient
  - date
  - request status chip
  - quick actions like share / copy when available

State B: success state
- clear success icon or signal
- title: request created successfully
- concise explanation of what happens next
- link card showing the generated URL
- next-step actions:
  - "Поделиться ссылкой"
  - "Копировать"
  - "История"
  - "Новый запрос"

Visual direction:
- this must not feel like a plain utilitarian form
- keep the FamilyRecipes modern-heritage tone
- make success feel complete and actionable, never like a dead end
- history should feel like living context, not admin data
- use compact notebook zoning
- prefer grouped sections and refined list rhythm over bloated rounded cards
- small radii, restrained spacing, text-first hierarchy

Behavioral expectations:
- create button disabled until fields are valid
- share action should feel like opening the native iOS share sheet
- copy action should feel like clipboard copy with lightweight confirmation
- history remains on this same screen, not a separate page
```

### 4. Settings
```text
Design an iPhone app screen for FamilyRecipes called settings.

UI copy must stay in Russian.
Keep the screen simple, native-feeling, and list-based.
Assume a text-first notebook product, not a dashboard.

Required structure:
- navigation title: "Настройки"
- plain list with:
  - "Семья и друзья"
  - "Авторские права"
  - destructive button "Выйти из аккаунта"
- logout should imply a confirmation dialog:
  - title asking if the user wants to sign out
  - cancel action
  - destructive confirm action

Visual direction:
- refined native iOS list feel
- warm palette, subtle separators, minimal noise
- do not overdesign settings into a dashboard
- small radii only where needed
- maximize information density without feeling cramped

Behavioral expectations:
- each list row is a clear navigation destination
- destructive sign-out action stands apart without dominating the whole screen
```

## Micro-interactions and behavior to insist on
Если Stitch начинает рисовать только “красивые карточки”, полезно отдельным сообщением добить interaction fidelity.

- minimum comfortable tap targets around 44-48pt
- disabled primary buttons should visibly dim
- recipe list should support loading, empty, error, and data states
- request creation should feel asynchronous and native, with loading feedback
- copy actions should imply clipboard feedback
- share actions should imply native iOS share sheet
- logout should imply a native confirmation dialog, not a full custom page
- recipe note editing should feel inline and lightweight
- request history status should combine color + label, not color alone
- layouts should remain usable at larger accessibility text sizes
- avoid clipping, truncation, and broken wrapping when text gets bigger

## Основной flow для прототипа
1. User opens app
2. User signs in
3. User lands on Recipes empty state or recipes list
4. User switches to Request
5. User requests a recipe from a family member
6. Request success surfaces share and copy actions
7. Donor opens link in mobile web
8. Donor reads short onboarding and submits recipe
9. User returns to app and sees recipe in list
10. User opens recipe detail
11. User adds a personal note or asks for clarification

## Главный промпт для Stitch
Вставь это как первый основной generation prompt после добавления `DESIGN.md` и image/URL reference.

```text
Design a complete high-fidelity mobile product called FamilyRecipes.

This is not a recipe discovery marketplace, not a social feed, and not a meal planner. It is a warm, modern, text-first mobile product for preserving and repeating family recipes across generations.

Primary users:
1. The "Master" user has the native app. They request recipes from relatives, receive recipes, read them, cook from them, save personal notes, and ask follow-up clarifications.
2. The "Donor" user does not install the app. They open a mobile web link from a messenger and submit a recipe in free form.

Core product promise:
- preserve the original family voice
- make recipes repeatable and practical
- keep donor friction near zero
- feel trustworthy, calm, intimate, and premium

Visual direction:
- modern heritage
- warm paper-like backgrounds
- text-first notebook zoning
- clean sans-serif UI for both Latin and Cyrillic
- restrained corner radii
- low-chrome grouped sections
- soft depth only where necessary
- family warmth without kitsch

Avoid:
- generic productivity SaaS
- generic food delivery visuals
- neon gradients
- crowded dashboards
- social feed patterns
- bento layouts
- oversized floating cards
- image-led hero sections
- large pill buttons
- decorative serif typography in Russian

Typography:
- clean sans-serif for UI and body
- compact label font for metadata and chips
- no serif in Russian UI
- optimize for large accessibility text sizes

Color direction:
- warm light palette
- off-white and paper beige surfaces
- charcoal text
- coral / terracotta primary accents
- olive-green success states
- stable color-coded chips for family contacts

Product structure:
- native app tabs: Recipes, Request, More
- donor mobile web flow linked from messenger

Design the following screens and components:
1. splash / welcome atmosphere screen
2. login screen
3. recipes empty state
4. recipes list with author, date, and note indicator
5. recipe detail with prominent title, author chip, date, original recipe text, personal note module, and a secondary CTA to ask for clarification
6. create own recipe modal
7. request form with recipient field, dish field, color-coded suggested contact chips, and inline request history below
8. request success state with clear next actions: share link, copy link, view history, new request
9. settings screen
10. contacts list
11. create/edit contact screen
12. donor mobile web request landing with one-glance onboarding
13. donor submission form
14. donor success state
15. donor error states: not found, expired, already fulfilled

Make UI copy Russian.
Make the layouts feel native on both iPhone and Android, while keeping one shared brand language.
Prioritize one-handed mobile use, readable long-form text, large tap targets, and clear next steps.
Assume the core app works with no photos at all.

Then generate:
- a reusable design system
- component variants for buttons, chips, cards, inputs, status pills, and empty states
- a clickable prototype for the end-to-end journey from request creation to donor submission to recipe review
```

## Follow-up prompts
Используй их после первого прохода, чтобы дожать качество.

### Prompt 1: tighten the visual identity
```text
Push the visual identity further toward "modern heritage editorial". Make it feel more premium and memorable, less like a default app template. Keep usability high. Increase typographic character, warmth, and emotional clarity without becoming decorative or old-fashioned.
```

### Prompt 2: improve the donor conversion flow
```text
Redesign the donor mobile web flow to maximize completion rate for an older, low-tech family member receiving a messenger link. Add a short onboarding block, a clearer explanation that no installation or registration is required, and a form that feels easier than sending a long chat message.
```

### Prompt 3: request state coverage
```text
Add full state coverage for the native and donor flows: loading, empty, error, pending, fulfilled, expired, success, and draft-restored states. Keep the tone calm and reassuring.
```

### Prompt 4: request future-ready donor variants
```text
Create future-ready donor variants for:
1. short vs detailed response modes
2. draft autosave restore banner
3. add another recipe after success
4. example of a good recipe answer

Keep these clearly compatible with the same design system.
```

### Prompt 5: request stronger recipe reading comfort
```text
Refine the recipe detail screen for long-form reading comfort. Increase hierarchy, text rhythm, and clarity of the original recipe block. Make the personal note feel private and lightweight. Keep the clarification CTA visible but secondary.
```

### Prompt 6: request platform parity
```text
Create iOS and Android variants of the same product language. Preserve shared brand DNA, but adapt navigation, spacing, and control styling to feel natively at home on each platform.
```

### Prompt 7: current iPhone MVP parity
```text
Now tighten the design to stay closer to the current iPhone MVP information architecture. Keep the upgraded visual quality, but preserve:
- 3 tabs: Рецепты / Запросить / Ещё
- inline request history on the request screen
- request success with share, copy, history, and new request actions
- recipe detail with note section and clarification CTA
- settings as a simple list with contacts, credits, and sign out
```

## Рекомендуемый workflow внутри Stitch
### Path A: fast parity-first run
1. Paste the master prompt.
2. Generate the 4 current MVP core screens first:
   - Recipes List
   - Recipe Detail
   - Request Screen
   - Settings
3. Use the screen-specific prompts above to refine each screen one by one.
4. Only after those 4 screens feel right, expand to login, contacts, create recipe, donor web, and future variants.

### Path B: full-system run
1. Start a new Stitch project.
2. Add `DESIGN.md` from `/Users/user/git-project/familyrecipes/DESIGN.md` if Stitch supports direct import in your session.
3. Upload `/Users/user/git-project/familyrecipes/docs/mockups/request-detail-redesign.svg` as visual context.
4. If useful, also provide the public donor web URL as a style seed so Stitch can extract existing warm rules.
5. Paste the master prompt.
6. Ask for 2-3 visual directions before locking one.
7. Pick the strongest direction and then run the follow-up prompts above.
8. Use Prototypes to connect the request flow, donor flow, and recipe review flow.
9. Export to Figma for review and refinement.
10. Export frontend code only after the prototype and system are coherent.

## Figma handoff expectations
- export the strongest screen set into one Figma file
- create component sets for buttons, chips, cards, inputs, status pills, and note states
- keep spacing, color, and type decisions inspectable for developer handoff
- if Stitch output drifts, normalize components in Figma before treating it as source of truth

## Как выглядит хороший результат
- The app feels like a family archive, not a content platform.
- The donor flow feels simpler than WhatsApp for a long recipe.
- Recipe detail feels calm and readable enough for actual cooking reference.
- The request flow makes the next step obvious after success.
- Both iOS and Android feel related, not duplicated blindly.
- The design system is reusable enough for the Android parity build and future donor improvements.

## Чеклист перед принятием Stitch-результата
- Is the main emotion warmth plus trust, not generic polish?
- Does every screen have one clear primary action?
- Are empty and error states useful, not ornamental?
- Can an older donor understand the task in under 5 seconds?
- Does the recipe detail screen prioritize readability over visual chrome?
- Is the request success state actionable, not a dead end?
- Are the contact chips fast, recognizable, and visually stable?
- Do iOS and Android variants feel native while still clearly one product?
- Is the donor web clearly zero-install and low-friction?
- Does the prototype cover the full loop, not just isolated screens?
- Do the current iPhone core screens still map cleanly to the existing app structure?
- Would a developer be able to infer share sheet, copy, loading, and confirmation behaviors from the design?

## Notes
- The current product copy is Russian, so keep generated UI copy Russian even if prompting in English.
- The current MVP is light-theme-first. Dark mode can wait until the core flow is solid.
- If Stitch offers too many ornamental ideas, pull it back toward clarity, trust, and repeatability.

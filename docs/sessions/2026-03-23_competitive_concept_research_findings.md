# Сессия: Competitive concept research — findings + backlog synthesis

Дата сохранения: 2026-03-23

## Контекст
- Исследование проводилось не как обзор "ещё одного recipe app", а как поиск похожих концепций вокруг:
  - личной кулинарной памяти;
  - передачи рецептов от близких людей;
  - zero-install donor flow;
  - сохранения не только инструкции, но и истории рецепта;
  - кулинарной культуры как формы общения между поколениями.
- Источники проверялись 2026-03-22 на официальных сайтах продуктов и в нескольких research / museum sources.

## Похожие концепции

### Direct / recipe-adjacent
- [Heritage Cookbook](https://heritagecookbook.com/family-cookbook)
  - Collaborative cookbook для семьи и друзей.
  - Сильная идея: provenance как first-class data (`submitted by`, `who passed this recipe down to you?`, `origin`, `story behind the recipe`) на уровне самого рецепта.
  - Что можно взять: явные сигналы авторства и происхождения в recipe detail.
  - Что не подходит: тяжёлый cookbook-builder / print workflow как основа MVP.

- [Vinst](https://www.vinst.me/)
  - Современный family-and-friends cookbook продукт: import из фото, старых карточек, заметок, совместный cookbook, shared digital recipes без app/account.
  - Сильная идея: shared artifact живёт и вне приложения, handwritten memory превращается в usable recipe.
  - Что можно взять: view-only web artifact, import фото блокнота позже.
  - Что не подходит: print commerce как центр продукта.

- [Recipe Keeper](https://recipekeeperonline.com/)
  - Утилитарный baseline recipe manager: scan handwritten recipes, share, meal planner, shopping list.
  - Сильная идея: repeat-use loop обязателен, иначе recipe app превращается в архив.
  - Что можно взять: cooking return loop как product layer после donor conversion.
  - Что не подходит: generic organizer framing, слабая emotional differentiation.

### Adjacent products
- [Storyworth](https://welcome.storyworth.com/what-is-storyworth)
  - Семейные истории по weekly prompts, ответы по email / телефону / web, получатели читают истории по мере появления, позже собирается keepsake book.
  - Сильная идея: capture идёт через знакомый канал, а не через сложную новую систему.
  - Что можно взять: prompt-driven capture, low-friction contribution, storytelling cadence.
  - Что не подходит: годовой cadence и print-first packaging.

- [Remento](https://www.remento.co/how-it-works)
  - Family story capture по email / text без app, download и login; можно отвечать голосом; семья добавляет фото и вопросы.
  - Сильная идея: для older/low-tech contributors input должен быть проще, чем длинное сообщение.
  - Что можно взять: no-app/no-login promise, voice-first direction, warm invitation framing.
  - Что не подходит: AI-heavy rewriting и book packaging как ближайший MVP-фокус.

- [No Story Lost](https://nostorylost.com/)
  - Премиальный сервис сохранения семейных историй через guided interviews, transcription и editing.
  - Сильная идея: люди часто лучше рассказывают, чем пишут.
  - Что можно взять: guided interviewing как future direction, если typing barrier останется высоким.
  - Что не подходит: service-heavy модель.

- [FamilySearch Memories](https://www.familysearch.org/en/memories/)
  - Архив семейных фото, историй, аудио и shared albums с topic tags и share-by-link.
  - Сильная идея: memory object должен быть linkable, attributable и discoverable по людям/темам.
  - Что можно взять: теги по людям / происхождению / occasion, shareable recipe memory objects.
  - Что не подходит: genealogy-account context как core оболочка.

### Concept analogies
- [StoryCorps](https://storycorps.org/participate/)
  - Продаёт разговор с важным человеком, а не заполнение формы.
  - Сильная идея: framing как conversation, а не data entry.
  - Что можно взять: copy и interaction style “напишите как рассказали бы это в сообщении”.
  - Что не подходит: отдельный interview ritual как обязательный сценарий.

- [Your Story, Our Story](https://www.tenement.org/explore/your-story-our-story/)
  - Публичный музейный формат: люди добавляют объект / традицию с фото и аудио, получают unique URL.
  - Сильная идея: бытовой артефакт становится носителем истории и идентичности.
  - Что можно взять: рецепт можно подавать как meaningful object / tradition, а не просто note.
  - Что не подходит: community/public gallery layer сейчас не нужен.

## Повторяющиеся паттерны
- Самые сильные продукты продают не storage, а relationship + memory + legacy.
- Для second-person contribution важнее familiar channel, чем богатство функций: email, text, simple link, no login.
- Guided prompts работают лучше blank form, особенно когда нужен контекст, а не только сухая инструкция.
- Provenance materially increases value: кто прислал, от кого узнал, откуда рецепт, почему он важен.
- Recipe artifact должен быть одновременно эмоциональным и практическим: сохранить память и позволить реально готовить снова.
- Group contribution вокруг одного человека / семьи / occasion работает лучше, чем безличное “добавьте контент”.

## Подтверждение рамки "кулинария как общение между поколениями"
- [Parenting review 2025](https://www.tandfonline.com/doi/abs/10.1080/15295192.2025.2450497) описывает family storytelling как важный developmental process для семьи и индивида.
- [Innovation in Aging 2018](https://academic.oup.com/innovateage/article/2/suppl_1/586/5170553) показывает storytelling между grandparents и grandchildren как способ передачи wisdom и intimacy.
- [Frontiers 2022](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2022.927795/full) связывает intergenerational family stories с отношениями, историей семьи, cultural belonging и wellbeing.
- [Fort Worth Museum 2025](https://www.fwmuseum.org/news/press-releases/explore-identity-place-and-culture-through-family-recipes-in-abuelitas-kitchen-mexican-food-stories-at-the-fort-worth-museum-of-science-and-history/) буквально оформляет семейные рецепты как истории identity, place и cuisine.
- Вывод: рамка "культура кулинарии — это культура общения между поколениями" выглядит не случайной метафорой, а сильным positioning lens.

## Что это значит для FamilyRecipes
- Самый живой framing: **"рецепты близких людей, которые хочется готовить снова"**.
- Второй сильный framing: **"не каталог рецептов, а живая передача рецепта от человека к человеку"**.
- Третий: **"личная кулинарная память: рецепт, история и от кого он"**.
- "Семейные рецепты" лучше оставить как тёплый вторичный слой бренда, но не как единственный first-touch language.
- Для первых объяснений шире и точнее звучит **"рецепты близких людей"**: сюда естественно входят семья, друзья, соседи, тёти, наставники, "хорошие люди", с кем не стыдно обменяться рецептом.

## Рекомендованный positioning language
- Первая фраза:
  - `FamilyRecipes помогает попросить рецепт у близкого человека, сохранить не только сам рецепт, но и его историю, а потом возвращаться к нему, чтобы готовить снова.`
- Product lens:
  - `Рецепт — это не только инструкция, но и форма передачи опыта, интонации, привычек, ритуалов и семейного языка.`

## Backlog synthesis
- Из исследования вытекают 3 immediate направления:
  - поднять donor understanding / conversion;
  - сделать provenance и story видимыми в самом продукте;
  - начать строить repeat-use loop, чтобы FamilyRecipes не остался только keepsake-архивом.
- Конкретные задачи сохранены в `docs/backlog.md`:
  - обновлены `DONOR-01` и `DONOR-02`;
  - добавлены `POSITION-01`, `DONOR-13`, `DETAIL-11`, `REQ-19`, `REPEAT-01`, `ARCHIVE-01`, `DONOR-16`, `SHARE-02`.

## Короткий synthesis
1. Самый сильный следующий продуктовый шаг — улучшить donor copy и first-glance onboarding.
2. Самое важное UX-отличие — сделать recipe provenance visible, а не прятать в тексте.
3. Самый сильный стратегический язык — не только "семейные рецепты", а "рецепты близких людей".
4. После donor conversion следующий реальный moat — repeat cooking loop, а не social/feed.

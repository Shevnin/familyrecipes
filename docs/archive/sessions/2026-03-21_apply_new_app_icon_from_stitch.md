# Сессия: Apply new app icon from Stitch export

Дата: 2026-03-21

## Контекст
- Пользователь принял новую иконку из Stitch.
- Источник иконки лежит в архиве:
  - `/Users/user/Downloads/stitch (2).zip`
- Внутри архива:
  - `screen.png` — готовая квадратная иконка `512x512`
  - `DESIGN.md` — сопроводительный Stitch design note
- Иконка визуально представляет bowl / steam mark на тёплом фоне.

Для удобства артефакты уже были просмотрены:
- extracted icon source: `/tmp/stitch-icon-task/screen.png`
- extracted design note: `/tmp/stitch-icon-task/DESIGN.md`

## Что нужно сделать
Применить новую иконку в iOS-проекте.

## Master Task для Claude

### Цель
Заменить текущую app icon в iOS на новую Stitch icon из `/Users/user/Downloads/stitch (2).zip`.

### Основные файлы
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Assets.xcassets/AppIcon.appiconset/`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/LaunchSplashView.swift`

### Что именно сделать
1. Взять новую иконку из Stitch source:
   - `/Users/user/Downloads/stitch (2).zip`
   - либо из уже извлечённого файла `/tmp/stitch-icon-task/screen.png`

2. Обновить `AppIcon.appiconset`:
   - заменить текущие icon PNG на новые версии, основанные на этой иконке;
   - сохранить совместимость с `Contents.json`;
   - убедиться, что все нужные размеры присутствуют для текущего asset catalog.

3. Если исходник только `512x512`:
   - аккуратно сгенерировать нужные размеры из него;
   - для `1024x1024` использовать best-effort upscale;
   - не менять саму графику без необходимости.

4. Проверить dark/tinted variants:
   - если текущий `Contents.json` ожидает `ios-1024-dark.png` и `ios-1024-tinted.png`, обеспечить, чтобы asset catalog не был сломан;
   - если специальных вариантов нет, допустимо временно использовать тот же базовый art, лишь бы билд и asset set были валидны.

5. Дополнительно:
   - если это просто и не ломает intro flow, заменить SF Symbol на первом intro/icon splash экране на ту же новую графику, чтобы splash и app icon совпадали по айдентике;
   - если это требует лишней перестройки flow, можно ограничиться только `AppIcon.appiconset`.

### Ограничения
- Не переделывать весь redesign.
- Не трогать recipes/request/settings flows.
- Не менять backend.
- Не изобретать новую иконку — использовать именно предоставленную Stitch art.
- Не ухудшать текущий build status.

### Acceptance criteria
- В `AppIcon.appiconset` реально применена новая иконка.
- `Contents.json` остаётся валидным.
- Xcode build проходит.
- Если обновлялся intro icon screen, он визуально использует ту же иконку.
- Не сломаны остальные экраны приложения.

### Что проверить
- Build проекта.
- Что asset catalog собирается без ошибок.
- Что `AppIcon.appiconset` содержит ожидаемые файлы.
- Что новая иконка видна в app asset set.

### Команда для сборки
```bash
xcodebuild -project apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes.xcodeproj -scheme FamilyRecipes -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/familyrecipes-dd build
```

### Формат финального отчёта от Claude
- changed files
- какие icon files были обновлены/сгенерированы
- обновлялся ли splash icon screen
- build status
- residual risks

## Следующий шаг
Передать этот task file в Claude и попросить его применить новую иконку end-to-end.

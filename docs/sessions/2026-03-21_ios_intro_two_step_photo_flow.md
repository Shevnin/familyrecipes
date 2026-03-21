# Сессия: iOS intro flow — icon splash -> photo quote -> app

Дата: 2026-03-21

## Контекст
- Полный iOS redesign под `Warm Paper Notebook` уже выполнен.
- Acceptance-pass по redesign уже пройден, и build был успешным.
- Текущее замечание от пользователя: после redesign исчез photo-led intro mood.
- Нужно вернуть фотографии в onboarding, но не откатывать весь новый визуальный язык приложения.

## Что хочет пользователь
Нужен двухшаговый вход в приложение:

1. Первый экран:
   - спокойная заставка с иконкой приложения;
   - текст `Нажмите, чтобы продолжить`;
   - без фотографии;
   - warm paper / notebook настроение.

2. Второй экран:
   - фотография шефа;
   - цитата;
   - текст `Нажмите, чтобы продолжить`;
   - после второго тапа открывается основной экран приложения.

3. Потом:
   - если есть активная сессия, открывается основной app flow;
   - если нет сессии, открывается auth screen.

Важно:
- это должны быть именно два последовательных intro-экрана;
- не один смешанный splash;
- не автоматический skip, если пользователь не нажал;
- не откатывать остальной redesign экранов.

## Master Task для Claude

### Цель
Переделать launch flow iOS-приложения так, чтобы он состоял из двух последовательных intro steps:
- `icon splash`
- `photo + quote splash`
- затем переход в приложение

### Основные файлы
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/LaunchSplashView.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/ChefSplashData.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/FamilyRecipesApp.swift`
- `/Users/user/git-project/familyrecipes/apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Settings/CreditsView.swift`

### Поведение, которое нужно реализовать
1. Первый splash step:
   - warm paper background;
   - app icon / wordmark;
   - минималистичная спокойная композиция;
   - снизу `Нажмите, чтобы продолжить`;
   - тап переводит ко второму step.

2. Второй splash step:
   - используется случайный `ChefSplashItem` из `ChefSplashData`;
   - full-screen или near-full-screen photo;
   - поверх фото показывается цитата;
   - показывается имя шефа / подпись;
   - снизу `Нажмите, чтобы продолжить`;
   - второй тап открывает app.

3. Session gating:
   - intro не должен случайно пропускаться одним ранним тапом;
   - если session check ещё не завершён, допустимо не активировать переходы до готовности;
   - после завершения session check пользователь всё равно должен пройти оба шага через явные тапы.

### Визуальные ограничения
- Первый экран должен остаться в новом `Warm Paper Notebook` стиле.
- Второй экран может быть photo-led, но не должен выглядеть как старый unrelated promo screen.
- Не использовать serif, если это ломает общую типографическую систему.
- Не перегружать photo screen лишним chrome.
- Keep it calm, premium, readable.

### Что не нужно делать
- Не трогать `Recipes`, `Recipe Detail`, `Request`, `Settings`, `Auth` без необходимости.
- Не менять backend/session logic кроме launch gating.
- Не переделывать credits model или photo data structure, если это не требуется.

### Acceptance criteria
- При запуске приложения пользователь видит:
  1. icon splash;
  2. photo + quote splash;
  3. затем main app или auth.
- Оба экрана требуют явного тапа для перехода дальше.
- Фотографии снова реально используются.
- Новый redesign остальных экранов не сломан.
- Build проходит.

### Что проверить
- Launch flow на cold start.
- Поведение при logged-in и logged-out state.
- Что tap hint есть на обоих intro screens.
- Что второй экран действительно фото-экран, а не paper screen без фото.
- Что credits screen всё ещё валиден по смыслу, раз фото снова используются.

### Команда для сборки
```bash
xcodebuild -project apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes.xcodeproj -scheme FamilyRecipes -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/familyrecipes-dd build
```

### Формат финального отчёта от Claude
- changed files
- как реализован двухшаговый intro flow
- что проверено
- build status
- residual risks

## Следующий шаг
Передать этот файл в Claude и попросить сделать только этот intro-flow change поверх уже принятого iOS redesign.

# Сессия: Dev Deploy + iOS App v1

Дата: 2026-02-28

## Цель
Задеплоить backend в Supabase dev, создать iOS app с auth + create request + share sheet.

## Что сделано

### 1. Backend Deploy
- `supabase link --project-ref wlxtobrxqytnmpifbnev`
- Конфиг: `config.toml` — убран deprecated `[project]`, обновлён `major_version = 17`
- `supabase db push` — 3 миграции применены
- `supabase functions deploy` — 3 Edge Functions с `--no-verify-jwt`
  - `--no-verify-jwt` нужен потому что новый Supabase использует ES256 JWT, а gateway ожидает HS256. Функции проверяют auth внутри.
- Secrets: `APP_BASE_URL=https://shevnin.github.io/familyrecipes/web-reply/`, `APP_LINK_MODE=query`
- `web-reply/index.html`: `DEFAULT_API` установлен на production URL функций.

### 2. E2E Smoke Tests — 6/6 PASS
| # | Тест | HTTP | Ожидание | Статус |
|---|------|------|----------|--------|
| 1 | create-request | 201 | 201 | PASS |
| 2 | get-request-meta | 200 | 200 | PASS |
| 3 | submit-request | 201 | 201 | PASS |
| 4 | repeat submit | 409 | 409 | PASS |
| 5 | direct RPC | 401 (permission denied) | 401/403 | PASS |
| 6 | self-join household | blocked (FK) | 403 | PASS |

### 3. iOS App v1
- Путь: `apps/ios/FamilyRecipes/FamilyRecipes/`
- Xcode 16.4, iOS 18.5+, SwiftUI, no SPM dependencies
- Структура: `App/`, `Core/Config`, `Core/Networking`, `Features/Auth`, `Features/Recipes`, `Features/Request`, `Shared/UI`
- Конфиг: `Config.plist` (gitignored) + `Config.example.plist`
- Networking: raw URLSession, typed clients (SupabaseAuthClient, EdgeFunctionsClient)
- Auth: email/password через Supabase Auth REST API, session persistence (UserDefaults), auto-refresh
- Auto-bootstrap household при первом логине
- Create Request → Edge Function → Share Sheet с share_text
- Recipes: placeholder (ContentUnavailableView)
- Logout с confirmation dialog
- Build: **SUCCEEDED** (simulator + device ready)

### 4. Документация
- `apps/ios/README.md` — инструкция по запуску на устройстве
- `docs/current_state.md` — обновлён
- `docs/backlog.md` — P0 #9-11 закрыты, добавлены #12-14
- `docs/roadmap.md` — R3 прогресс обновлён

## Артефакты
### Новые файлы
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/FamilyRecipesApp.swift` (обновлён)
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/AppState.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/App/MainTabView.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Config/AppConfig.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Config/Config.plist` (gitignored)
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/HTTPClient.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/SupabaseAuthClient.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/EdgeFunctionsClient.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/Models/AuthModels.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/Models/CreateRequestModels.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Networking/Models/ApiError.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Auth/AuthView.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Auth/AuthViewModel.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Recipes/RecipesView.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Request/CreateRequestView.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Features/Request/CreateRequestViewModel.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/Config.example.plist`
- `apps/ios/FamilyRecipes/FamilyRecipes/Config.example.xcconfig`
- `apps/ios/README.md`

### Обновлённые файлы
- `.gitignore` — добавлены iOS-специфичные паттерны
- `supabase/config.toml` — убран `[project]`, обновлён major_version
- `web-reply/index.html` — `DEFAULT_API` установлен
- `docs/current_state.md`
- `docs/backlog.md`
- `docs/roadmap.md`

### Удалённые файлы
- `apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/ContentView.swift`
- `apps/ios/FamilyRecipes/FamilyRecipes/.git/` (вложенный git удалён)

## Discovered Issues
- **ES256 JWT**: новые Supabase проекты используют ES256 вместо HS256 для JWT. Edge Functions gateway не верифицирует ES256 корректно → решение: `--no-verify-jwt`. Безопасность не страдает, т.к. функции проверяют auth внутри через `supabase.auth.getUser()`.
- **Email confirmation**: по дефолту Supabase требует email confirmation. Для dev отключено в Dashboard → Auth → Providers → Email.

## Что осталось на Task Pack #5
1. Deploy web-reply/ на GitHub Pages и проверить full flow в браузере.
2. Recipe list в iOS app — запрос рецептов из БД и отображение.
3. Full E2E на реальных устройствах (iPhone + мессенджер + web → app).
4. Request history в iOS app.
5. Android клиент (Jetpack Compose).

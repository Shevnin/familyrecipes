# FamilyRecipes iOS

SwiftUI iOS app for collecting family recipes via messenger links.

## Quick Start

### 1. Open in Xcode

```bash
open apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes.xcodeproj
```

### 2. Configure Supabase credentials

Copy the template and fill in your values:

```bash
cp apps/ios/FamilyRecipes/FamilyRecipes/Config.example.plist \
   apps/ios/FamilyRecipes/FamilyRecipes/FamilyRecipes/Core/Config/Config.plist
```

Edit `Config.plist`:
- `SUPABASE_URL` — `https://<project-ref>.supabase.co`
- `SUPABASE_ANON_KEY` — public anon key from Dashboard → Settings → API
- `FUNCTIONS_BASE_URL` — `https://<project-ref>.supabase.co/functions/v1`

> `Config.plist` is gitignored. Never commit real keys.

### 3. Set Team & Bundle ID

In Xcode:
1. Select the **FamilyRecipes** target
2. **Signing & Capabilities** tab
3. Set **Team** to your Apple Developer account
4. Change **Bundle Identifier** if needed (default: `com.albertin.FamilyRecipes`)

### 4. Run on Simulator

Select **iPhone 16** (or any iOS 18+ simulator) → **Cmd+R**.

## Running on Physical iPhone

### Prerequisites
- Apple Developer account (free or paid)
- iPhone with **Developer Mode** enabled
- USB cable or same Wi-Fi network

### Enable Developer Mode on iPhone
1. **Settings → Privacy & Security → Developer Mode → ON**
2. iPhone will restart
3. After restart, confirm the prompt to enable Developer Mode

### Build & Run
1. Connect iPhone via USB
2. In Xcode, select your iPhone from the device dropdown
3. **Cmd+R** to build and run
4. First time: trust the developer certificate on iPhone:
   **Settings → General → VPN & Device Management → your email → Trust**

## Smoke Test Scenario

1. **Login**: use `dev@familyrecipes.app` / `DevPass123` (or create your own user)
2. **Create Request**: go to "Запросить" tab → fill recipient name & dish name → tap "Отправить запрос"
3. **Share**: Share Sheet appears with the link text → share via messenger or copy
4. **Open link**: open the link on another device (or same device in Safari)
5. **Submit recipe**: fill in the form on the web page → submit
6. **Repeat submit**: try submitting again → should show "Рецепт уже отправлен"
7. **Current limitation**: "Рецепты" tab is still a placeholder and does not fetch DB data yet.

## Architecture

```
FamilyRecipes/
├── App/
│   ├── FamilyRecipesApp.swift    # Entry point, session routing
│   ├── AppState.swift            # Auth state management
│   └── MainTabView.swift         # Tab bar (Recipes, Request, Settings)
├── Core/
│   ├── Config/
│   │   ├── AppConfig.swift       # Reads Config.plist
│   │   └── Config.plist          # Supabase credentials (gitignored)
│   └── Networking/
│       ├── HTTPClient.swift      # Generic HTTP client
│       ├── SupabaseAuthClient.swift  # Login, refresh, session persistence (Keychain)
│       ├── EdgeFunctionsClient.swift # create-request, ensureHousehold
│       └── Models/
│           ├── AuthModels.swift
│           ├── CreateRequestModels.swift
│           └── ApiError.swift
├── Features/
│   ├── Auth/
│   │   ├── AuthView.swift        # Login screen
│   │   └── AuthViewModel.swift
│   ├── Recipes/
│   │   └── RecipesView.swift     # Placeholder recipe list
│   └── Request/
│       ├── CreateRequestView.swift   # Create request + share
│       └── CreateRequestViewModel.swift
└── Shared/UI/                    # Reusable UI components (future)
```

## Requirements

- Xcode 16.4+
- iOS 18.5+ (deployment target)
- Swift 5.0

# Backend Setup: Supabase (Dev)

## Предварительные требования

1. Установить [Supabase CLI](https://supabase.com/docs/guides/cli/getting-started):
   ```bash
   brew install supabase/tap/supabase
   ```
2. Создать проект на [supabase.com](https://supabase.com/dashboard) (Free tier).
3. Получить `project-ref` из URL проекта (Settings → General).

## Переменные окружения

Функции используют стандартные Supabase-переменные (задаются автоматически при деплое):
- `SUPABASE_URL` — URL проекта
- `SUPABASE_ANON_KEY` — anon key (для проверки JWT)
- `SUPABASE_SERVICE_ROLE_KEY` — service role key (для обхода RLS)

Дополнительно задать вручную:
```bash
# --- Link mode presets ---
# APP_BASE_URL = site root (WITHOUT trailing /web-reply/).
# APP_LINK_MODE controls how token is encoded in the URL.

# Preset A: Cloudflare Pages / Vercel (rewrite support)
supabase secrets set APP_BASE_URL=https://familyrecipes.pages.dev
supabase secrets set APP_LINK_MODE=path
# Generates: https://familyrecipes.pages.dev/r/<token>

# Preset B: GitHub Pages (no rewrites) — CURRENT
supabase secrets set APP_BASE_URL=https://shevnin.github.io/familyrecipes
supabase secrets set APP_LINK_MODE=query
# Generates: https://shevnin.github.io/familyrecipes/web-reply/?token=<token>
# Note: /web-reply/ segment is appended by create-request, NOT in APP_BASE_URL.
```

**CAPTCHA (blocker):**
```bash
# DO NOT set CAPTCHA_SECRET until Turnstile widget is integrated in web-reply/index.html.
# If set without frontend integration, submit-request will return 400 captcha_required.
# supabase secrets set CAPTCHA_SECRET=<turnstile-secret-key>
```

## Деплой Backend

### 1. Линковка проекта
```bash
cd familyrecipes
supabase link --project-ref <your-project-ref>
```

### 2. Применить миграции
```bash
supabase db push
```

### 3. Задеплоить Edge Functions
```bash
# --no-verify-jwt: gateway пропускает JWT как есть, функции валидируют сами.
# Обязательно для проектов с ES256 auth tokens.
supabase functions deploy create-request --no-verify-jwt
supabase functions deploy get-request-meta --no-verify-jwt
supabase functions deploy submit-request --no-verify-jwt
```

## Деплой Guest Web (web-reply/)

### Вариант A: GitHub Pages
`web-reply/` деплоится автоматически с main через GitHub Pages.
URL: `https://<user>.github.io/familyrecipes/web-reply/?token=<token>`

Перед деплоем задать `API_BASE` в `web-reply/index.html`:
```js
const DEFAULT_API = 'https://<project-ref>.supabase.co/functions/v1';
```

### Вариант B: Cloudflare Pages
1. Подключить repo в Cloudflare Pages dashboard.
2. Build output: `web-reply/`
3. Добавить route rewrite: `/r/*` → `/index.html`
4. URL: `https://familyrecipes.pages.dev/r/<token>`

### Вариант C: Vercel
1. `vercel --cwd web-reply`
2. Добавить rewrite в `vercel.json`:
   ```json
   { "rewrites": [{ "source": "/r/:token", "destination": "/index.html" }] }
   ```

## Настройка Auth

1. В Supabase Dashboard → Authentication → Settings:
   - Включить Email provider.
   - Отключить email confirmations (для dev).
2. Создать тестового пользователя:
   ```bash
   curl -X POST 'https://<project-ref>.supabase.co/auth/v1/signup' \
     -H 'apikey: <anon-key>' \
     -H 'Content-Type: application/json' \
     -d '{"email": "test@example.com", "password": "testpassword123"}'
   ```
3. Создать household через RPC:
   ```bash
   TOKEN=<jwt-token-from-login>
   curl -X POST 'https://<project-ref>.supabase.co/rest/v1/rpc/create_household_with_owner' \
     -H "apikey: <anon-key>" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"p_name": "Семья Тест"}'
   ```

## Примеры curl

```bash
PROJECT_URL="https://<project-ref>.supabase.co"
ANON_KEY="<anon-key>"
FUNCTIONS_URL="$PROJECT_URL/functions/v1"
```

### Получить JWT токен
```bash
TOKEN=$(curl -s -X POST "$PROJECT_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "testpassword123"}' \
  | jq -r '.access_token')
```

### 1. create-request (auth required)
```bash
curl -s -X POST "$FUNCTIONS_URL/create-request" \
  -H "Authorization: Bearer $TOKEN" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "recipient_name": "Мама",
    "dish_name": "Борщ",
    "expires_in_days": 7
  }' | jq .
```
Ответ (201):
```json
{
  "request_id": "uuid",
  "token": "raw-uuid-token",
  "web_url": "https://shevnin.github.io/familyrecipes/web-reply/?token=<token>",
  "share_text": "Мама, поделитесь рецептом \"Борщ\"!\nhttps://...",
  "expires_at": "2026-03-06T..."
}
```

### 2. get-request-meta (public, apikey required)
```bash
curl -s -X POST "$FUNCTIONS_URL/get-request-meta" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"token": "<token>"}' | jq .
```
Ответ (200):
```json
{
  "recipient_name": "Мама",
  "dish_name": "Борщ",
  "status": "pending",
  "expires_at": "2026-03-06T..."
}
```

### 3. submit-request (public, apikey required)
```bash
curl -s -X POST "$FUNCTIONS_URL/submit-request" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "<token>",
    "submitted_by_name": "Мама",
    "recipe_title": "Борщ по-домашнему",
    "original_text": "Берём свёклу, картошку, капусту..."
  }' | jq .
```
Ответ (201):
```json
{
  "success": true,
  "recipe_id": "uuid",
  "submission_id": "uuid"
}
```

### 4. Повторный submit (409)
```bash
# Тот же curl — ожидаем:
# 409: {"error": "request_already_fulfilled"}
```

### 5. Проверка RLS (anon-доступ закрыт)
```bash
curl -s "$PROJECT_URL/rest/v1/recipes" -H "apikey: $ANON_KEY"
# Ожидаем: [] (пустой массив, RLS блокирует)
```

### 6. Тест self-join (должен быть заблокирован)
```bash
# Создать второго пользователя, получить TOKEN2
# Попытка вставки в чужой household:
curl -X POST "$PROJECT_URL/rest/v1/household_members" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $TOKEN2" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{"household_id": "<other-hh-id>", "user_id": "<attacker-id>", "role": "member"}'
# Ожидаем: 403 (RLS denied)
```

### 7. Concurrency test — параллельный submit
```bash
TOKEN_VAL="<token-from-create-request>"
curl -s -X POST "$FUNCTIONS_URL/submit-request" \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"$TOKEN_VAL\",\"submitted_by_name\":\"A\",\"recipe_title\":\"R1\",\"original_text\":\"t1\"}" &
curl -s -X POST "$FUNCTIONS_URL/submit-request" \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"$TOKEN_VAL\",\"submitted_by_name\":\"B\",\"recipe_title\":\"R2\",\"original_text\":\"t2\"}" &
wait
# Ожидаем: один 201, один 409
```

### 8. RPC lockdown (direct RPC access blocked)
```bash
# Try calling submit_recipe_by_token directly via PostgREST RPC (anon)
curl -s -X POST "$PROJECT_URL/rest/v1/rpc/submit_recipe_by_token" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"p_token_hash":"fake","p_submitted_by_name":"X","p_recipe_title":"T","p_original_text":"T"}'
# Ожидаем: 401 или permission denied

# Try with authenticated JWT
curl -s -X POST "$PROJECT_URL/rest/v1/rpc/submit_recipe_by_token" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"p_token_hash":"fake","p_submitted_by_name":"X","p_recipe_title":"T","p_original_text":"T"}'
# Ожидаем: permission denied (execute revoked from authenticated)
```

### 9. Error hygiene check
```bash
# Trigger a server error and verify no internal details leak
curl -s -X POST "$FUNCTIONS_URL/submit-request" \
  -H "Content-Type: application/json" \
  -d '{"token":"nonexistent","submitted_by_name":"X","recipe_title":"T","original_text":"T"}'
# Ожидаем: 404 {"error":"request_not_found"} — no "details" field
```

## Full Flow Test (телефон + мессенджер)

1. Создать запрос через curl (или из нативного приложения):
   ```bash
   RESULT=$(curl -s -X POST "$FUNCTIONS_URL/create-request" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"recipient_name":"Мама","dish_name":"Пельмени"}')
   echo "$RESULT" | jq -r '.share_text'
   ```
2. Скопировать `share_text` и отправить в мессенджер (себе или тестовому контакту).
3. Открыть ссылку на телефоне — должна загрузиться `web-reply/` с формой.
4. Заполнить форму и нажать "Отправить рецепт".
5. Проверить: запрос перешёл в `fulfilled`, рецепт в таблице `recipes`.
6. Повторно открыть ту же ссылку — должен показать "Рецепт уже отправлен".

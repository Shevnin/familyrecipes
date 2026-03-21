# 2026-02-28: Deploy web-reply + fix auth + fix submit flow

## Задачи
1. Задеплоить `web-reply/` на GitHub Pages
2. Починить 401 на `create-request` из iOS
3. Починить зависание `submit-request` на web-reply форме

---

## 1. Deploy web-reply на GitHub Pages

**Что сделано:**
- Закоммичен `web-reply/index.html` — гостевая страница для отправки рецепта по ссылке
- Закоммичены все Supabase Edge Functions (`create-request`, `get-request-meta`, `submit-request`) + shared модули (`cors.ts`, `supabase.ts`)
- Запушено на `main` → GitHub Pages автодеплой

**URL:** `https://shevnin.github.io/familyrecipes/web-reply/?token=...`

**Коммит:** `129df20`

---

## 2. Fix 401 на create-request

**Симптом:** iOS приложение получало `{"code":401,"message":"Invalid JWT"}` при вызове `create-request`.

**Диагностика (iOS debug logs):**
```
[CR-DEBUG] pre-flight tokenExists=true exp=... isExpired=false
[CR-DEBUG] got 401, body={"code":401,"message":"Invalid JWT"}
```

**Причина:** Supabase API Gateway проверяет JWT в `Authorization` header **до** передачи в Edge Function. Новые проекты выдают ES256 токены, а gateway ожидает HS256. Ответ `{"code":401,"message":"Invalid JWT"}` — от gateway, не от нашего кода.

**Решение:** Деплой всех функций с флагом `--no-verify-jwt`. Функции сами валидируют auth через `getUser()`.

```bash
supabase functions deploy create-request --no-verify-jwt
supabase functions deploy get-request-meta --no-verify-jwt
supabase functions deploy submit-request --no-verify-jwt
```

**Попутный баг:** URL содержал `/web-reply/web-reply/` — дублирование, т.к. `APP_BASE_URL` уже включал `/web-reply`. Исправлено: `${baseUrl}/?token=${token}`.

**Коммиты:** `dfcb023`, `b247b90`

---

## 3. Fix зависание submit-request

**Симптом:** Web-reply форма виснет на "Отправляем..." бесконечно. curl к `submit-request` таймаутит.

**Диагностика:**
- `submit-request` с пустым body `{}` → мгновенный ответ 400 ОК
- `submit-request` с валидным body (без `apikey` header) → вечный hang
- `submit-request` с валидным body + `apikey` header → мгновенный ответ

**Причина:** Supabase Edge Functions **требуют `apikey` header** для внутренних запросов к PostgREST. Без него `serviceClient.from(...)` виснет бесконечно (не ошибка, а hang). Web-reply форма не отправляла `apikey`.

**Сопутствующая проблема:** Исходная версия `submit-request` вызывала PostgreSQL RPC `submit_recipe_by_token()`. Миграция `00003` отозвала execute у `public` role, что заблокировало и `service_role` (наследовал через `public`).

**Решение (3 части):**

1. **web-reply/index.html** — добавлен `ANON_KEY` и `apikey` header во все fetch-вызовы:
```js
const ANON_KEY = 'eyJ...';
headers: { 'Content-Type': 'application/json', 'apikey': ANON_KEY }
```

2. **submit-request/index.ts** — переписан без RPC. Вместо `serviceClient.rpc("submit_recipe_by_token", ...)` теперь последовательные запросы через Supabase client:
   - `serviceClient.from("recipe_requests").select(...)` — найти запрос
   - Проверки статуса (fulfilled/expired/not pending)
   - `serviceClient.from("recipes").insert(...)` — создать рецепт
   - `serviceClient.from("recipe_submissions").insert(...)` — создать submission
   - `serviceClient.from("recipe_requests").update({ status: "fulfilled" })` — закрыть запрос

3. **Миграция 00004** — `GRANT EXECUTE ... TO service_role` (на будущее, если RPC понадобится):
```sql
grant execute on function public.submit_recipe_by_token(text, text, text, text) to service_role;
```

**Коммит:** `0503f0c`

---

## 4. Диагностический инструментарий (остался в коде)

**iOS (`EdgeFunctionsClient.swift`):**
- Pre-flight JWT decode: проверяет `exp`, auto-refresh если <60s
- Логи `[CR-DEBUG]`: tokenExists, exp, isExpired, masked token
- На 401: логирует body, refresh + retry

**iOS (`SupabaseAuthClient.swift`):**
- Логи `[AUTH-DEBUG]`: oldMasked, newMasked, tokenChanged при refresh

**Backend (`create-request/index.ts`):**
- Логи `[AUTH-DIAG]`: hasAuth, startsBearer, tokenLen, getUser result

---

## 5. E2E тест (curl, все 201)

```
1) create-request  → 201, token=ae7c065c-...
2) get-request-meta → 200, {recipient_name, dish_name, status: "pending"}
3) submit-request  → 201, {recipe_id, submission_id}
```

---

## 6. Прочее

- **Supabase CLI** установлен: `brew install supabase/tap/supabase` (v2.75.0)
- **Проект слинкован:** `supabase link --project-ref wlxtobrxqytnmpifbnev`
- **Dev-логин проверен:** `shevnin@tut.by` / `12345678` — auth OK, household membership OK (role=owner)
- **iOS пересборка не нужна** для fix #3 (все серверные изменения)

---

## Коммиты на main (хронологически)

| Коммит | Описание |
|---|---|
| `129df20` | feat: deploy web-reply + supabase edge functions |
| `42557cc` | fix: add apikey header and 401 retry to createRequest (iOS) |
| `dfcb023` | fix: auth diagnostics в iOS + backend |
| `b247b90` | fix: --no-verify-jwt + убрать дубль /web-reply/ |
| `0503f0c` | fix: apikey в web-reply + переписан submit-request без RPC |

---

## Ключевые уроки (Supabase Edge Functions)

1. **`--no-verify-jwt`** обязателен если auth tokens используют ES256 (новые проекты Supabase). Gateway не валидирует ES256, только HS256.
2. **`apikey` header** обязателен для всех вызовов Edge Functions — без него внутренние запросы к PostgREST виснут бесконечно.
3. **`REVOKE FROM public`** в PostgreSQL снимает доступ и у `service_role`, т.к. он наследует через `public`. Нужен явный `GRANT ... TO service_role`.

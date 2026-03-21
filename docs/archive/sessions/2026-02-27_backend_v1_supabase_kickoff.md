# Сессия: Backend v1 Supabase Kickoff

Дата: 2026-02-27

## Цель
Создать backend foundation на Supabase для перехода от discovery (localStorage) к delivery (серверное хранение).

## Что сделано

### Решения
- Delivery идет нативно: iOS (SwiftUI) + Android (Jetpack Compose), не Flutter.
- Backend: Supabase (PostgreSQL + Edge Functions + Auth).
- Публичные endpoints только через Edge Functions (service_role key), не через anon RLS.
- Токены ссылок: UUID → SHA-256 hash в БД.

### Артефакты

**Supabase структура:**
- `supabase/config.toml` — конфиг проекта
- `supabase/migrations/00001_init.sql` — 6 таблиц, индексы, RLS, триггер
- `supabase/functions/create-request/index.ts` — создание запроса (auth)
- `supabase/functions/get-request-meta/index.ts` — метаданные запроса (public)
- `supabase/functions/submit-request/index.ts` — отправка рецепта (public)
- `supabase/functions/_shared/cors.ts` — CORS helper
- `supabase/functions/_shared/supabase.ts` — Supabase client helper

**Таблицы:**
- `profiles` — профили пользователей (auto-create по триггеру)
- `households` — семьи
- `household_members` — участники семьи (owner/member)
- `recipes` — рецепты
- `recipe_requests` — запросы рецептов (pending/fulfilled/expired/cancelled)
- `recipe_submissions` — ответы на запросы

**RLS:**
- Default deny на всех таблицах.
- Доступ через membership check (`is_household_member` function).
- Нет anon-политик — публичные операции только через Edge Functions.

**Документация:**
- `docs/workflow.md` — обновлено: Flutter → Native Mobile
- `docs/decisions.md` — добавлены решения 2026-02-27
- `docs/current_state.md` — зафиксирован переход к delivery
- `docs/backend_setup_supabase.md` — runbook с curl-примерами

## Что осталось на следующий шаг
1. Создать Supabase dev project (supabase.com dashboard).
2. `supabase link --project-ref <ref>` + `supabase db push` + `supabase functions deploy`.
3. E2E тест через curl (create-request → get-request-meta → submit-request).
4. Начать iOS/Android клиенты или API gateway.

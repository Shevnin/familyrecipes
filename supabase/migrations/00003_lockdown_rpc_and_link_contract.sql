-- Fix Pack #2: Lockdown direct RPC access to submit_recipe_by_token
--
-- This function is security definer and must only be called server-side
-- via Edge Functions using the service_role key.
-- Revoking from all client roles prevents direct PostgREST RPC access,
-- which would bypass Edge Function logic (CAPTCHA, rate limits, etc.).

revoke execute on function public.submit_recipe_by_token(text, text, text, text) from public;
revoke execute on function public.submit_recipe_by_token(text, text, text, text) from anon;
revoke execute on function public.submit_recipe_by_token(text, text, text, text) from authenticated;

comment on function public.submit_recipe_by_token(text, text, text, text) is
  'Server-only: called by submit-request Edge Function via service_role key. '
  'Direct client access is revoked.';

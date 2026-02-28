-- Grant execute on submit_recipe_by_token to service_role.
-- Migration 00003 revoked from public/anon/authenticated, which also
-- removed access for service_role (inherited via public).
-- Edge Functions use service_role key to call this RPC.

grant execute on function public.submit_recipe_by_token(text, text, text, text) to service_role;

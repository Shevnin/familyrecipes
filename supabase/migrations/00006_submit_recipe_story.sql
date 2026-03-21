-- Add recipe_story parameter to submit_recipe_by_token.
-- Donor fills it in on the web-reply page; stored on the recipe row.

-- Drop old signature first (4 text args)
drop function if exists public.submit_recipe_by_token(text, text, text, text);

create or replace function public.submit_recipe_by_token(
  p_token_hash text,
  p_submitted_by_name text,
  p_recipe_title text,
  p_original_text text,
  p_recipe_story text default null
)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_request record;
  v_recipe_id uuid;
  v_submission_id uuid;
begin
  select id, household_id, status, expires_at
  into v_request
  from public.recipe_requests
  where token_hash = p_token_hash
  for update;

  if v_request is null then
    raise exception 'request_not_found'
      using hint = 'No request matches this token';
  end if;

  if v_request.status = 'fulfilled' then
    raise exception 'request_already_fulfilled'
      using hint = 'This request has already been fulfilled';
  end if;

  if v_request.status <> 'pending' then
    raise exception 'request_not_pending'
      using hint = 'Request status is: ' || v_request.status;
  end if;

  if v_request.expires_at < now() then
    raise exception 'request_expired'
      using hint = 'This request has expired';
  end if;

  insert into public.recipes (household_id, title, author_name, original_text, recipe_story)
  values (v_request.household_id, p_recipe_title, p_submitted_by_name, p_original_text, p_recipe_story)
  returning id into v_recipe_id;

  insert into public.recipe_submissions (
    request_id, household_id, submitted_by_name,
    recipe_title, original_text, created_recipe_id
  )
  values (
    v_request.id, v_request.household_id, p_submitted_by_name,
    p_recipe_title, p_original_text, v_recipe_id
  )
  returning id into v_submission_id;

  update public.recipe_requests
  set status = 'fulfilled', fulfilled_at = now()
  where id = v_request.id;

  return jsonb_build_object(
    'recipe_id', v_recipe_id,
    'submission_id', v_submission_id
  );
end;
$$;

-- Restore grants (same as 00003 + 00004 pattern)
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text) from public;
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text) from anon;
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text) from authenticated;
grant execute on function public.submit_recipe_by_token(text, text, text, text, text) to service_role;

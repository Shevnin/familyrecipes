-- DONOR-07: Post-submit edit flow for donor.
-- Adds edit_token_hash + edit_expires_at to recipe_submissions,
-- extends submit RPC to generate edit token metadata,
-- creates update_recipe_by_edit_token RPC.

-- 1. Add columns to recipe_submissions
alter table public.recipe_submissions
  add column edit_token_hash text unique,
  add column edit_expires_at timestamptz;

create index idx_recipe_submissions_edit_token_hash
  on public.recipe_submissions (edit_token_hash);

-- 2. Drop old 5-arg submit_recipe_by_token, create 7-arg version
drop function if exists public.submit_recipe_by_token(text, text, text, text, text);

create or replace function public.submit_recipe_by_token(
  p_token_hash text,
  p_submitted_by_name text,
  p_recipe_title text,
  p_original_text text,
  p_recipe_story text default null,
  p_edit_token_hash text default null,
  p_edit_expires_at timestamptz default null
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
    recipe_title, original_text, created_recipe_id,
    edit_token_hash, edit_expires_at
  )
  values (
    v_request.id, v_request.household_id, p_submitted_by_name,
    p_recipe_title, p_original_text, v_recipe_id,
    p_edit_token_hash, p_edit_expires_at
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

-- Restore grants
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) from public;
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) from anon;
revoke execute on function public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) from authenticated;
grant execute on function public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) to service_role;

-- 3. Create update_recipe_by_edit_token RPC
create or replace function public.update_recipe_by_edit_token(
  p_edit_token_hash text,
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
  v_sub record;
begin
  select id, created_recipe_id, edit_expires_at
  into v_sub
  from public.recipe_submissions
  where edit_token_hash = p_edit_token_hash
  for update;

  if v_sub is null then
    raise exception 'edit_not_found'
      using hint = 'No submission matches this edit token';
  end if;

  if v_sub.edit_expires_at < now() then
    raise exception 'edit_window_expired'
      using hint = 'The editing window has closed';
  end if;

  -- Update the recipe record
  update public.recipes
  set title = p_recipe_title,
      author_name = p_submitted_by_name,
      original_text = p_original_text,
      recipe_story = p_recipe_story
  where id = v_sub.created_recipe_id;

  -- Update submission record to keep it in sync
  update public.recipe_submissions
  set submitted_by_name = p_submitted_by_name,
      recipe_title = p_recipe_title,
      original_text = p_original_text
  where id = v_sub.id;

  return jsonb_build_object(
    'recipe_id', v_sub.created_recipe_id,
    'updated', true
  );
end;
$$;

-- Grants for update RPC
revoke execute on function public.update_recipe_by_edit_token(text, text, text, text, text) from public;
revoke execute on function public.update_recipe_by_edit_token(text, text, text, text, text) from anon;
revoke execute on function public.update_recipe_by_edit_token(text, text, text, text, text) from authenticated;
grant execute on function public.update_recipe_by_edit_token(text, text, text, text, text) to service_role;

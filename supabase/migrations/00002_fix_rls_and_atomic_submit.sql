-- FamilyRecipes Backend v1: Fix Pack #1
-- 1. Close self-insert vulnerability in household_members RLS
-- 2. Add atomic bootstrap: create_household_with_owner()
-- 3. Add atomic submit: submit_recipe_by_token()

-- ============================================================
-- 1. FIX household_members INSERT POLICY
-- ============================================================

-- Drop the vulnerable policy that allowed self-insert
drop policy if exists "Owners can add household members" on public.household_members;

-- New policy: only existing owners can add members
create policy "Owners can add household members"
  on public.household_members for insert
  with check (
    exists (
      select 1 from public.household_members existing
      where existing.household_id = household_members.household_id
        and existing.user_id = auth.uid()
        and existing.role = 'owner'
    )
  );

-- Also drop the direct household insert policy (bootstrap goes through function now)
drop policy if exists "Authenticated users can create households" on public.households;

-- ============================================================
-- 2. BOOTSTRAP: create_household_with_owner()
-- ============================================================

create or replace function public.create_household_with_owner(p_name text)
returns uuid
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid uuid;
  v_household_id uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated'
      using hint = 'User must be authenticated';
  end if;

  if p_name is null or trim(p_name) = '' then
    raise exception 'invalid_name'
      using hint = 'Household name must not be empty';
  end if;

  insert into public.households (name)
  values (trim(p_name))
  returning id into v_household_id;

  insert into public.household_members (household_id, user_id, role)
  values (v_household_id, v_uid, 'owner');

  return v_household_id;
end;
$$;

-- Only authenticated users can call this function
revoke execute on function public.create_household_with_owner(text) from public;
revoke execute on function public.create_household_with_owner(text) from anon;
grant execute on function public.create_household_with_owner(text) to authenticated;

-- ============================================================
-- 3. ATOMIC SUBMIT: submit_recipe_by_token()
-- ============================================================

create or replace function public.submit_recipe_by_token(
  p_token_hash text,
  p_submitted_by_name text,
  p_recipe_title text,
  p_original_text text
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
  -- Lock the request row to prevent race conditions
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

  -- Create recipe
  insert into public.recipes (household_id, title, author_name, original_text)
  values (v_request.household_id, p_recipe_title, p_submitted_by_name, p_original_text)
  returning id into v_recipe_id;

  -- Create submission
  insert into public.recipe_submissions (
    request_id, household_id, submitted_by_name,
    recipe_title, original_text, created_recipe_id
  )
  values (
    v_request.id, v_request.household_id, p_submitted_by_name,
    p_recipe_title, p_original_text, v_recipe_id
  )
  returning id into v_submission_id;

  -- Mark request as fulfilled
  update public.recipe_requests
  set status = 'fulfilled', fulfilled_at = now()
  where id = v_request.id;

  return jsonb_build_object(
    'recipe_id', v_recipe_id,
    'submission_id', v_submission_id
  );
end;
$$;

-- Public access (called from Edge Function with service_role key)
-- No need to restrict — function is called server-side only

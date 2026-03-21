-- FamilyRecipes Backend v1: Schema, Indexes, RLS
-- Supabase migration

-- ============================================================
-- 1. TABLES
-- ============================================================

-- Profiles: mirrors auth.users, auto-created via trigger
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now()
);

-- Households: family group
create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

-- Household members: links users to households
create table public.household_members (
  household_id uuid not null references public.households (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'member')),
  created_at timestamptz not null default now(),
  primary key (household_id, user_id)
);

-- Recipes: family recipes stored per household
create table public.recipes (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  title text not null,
  author_name text not null default '',
  original_text text not null,
  structured_json jsonb,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

-- Recipe requests: outgoing link-based requests
create table public.recipe_requests (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  requested_by uuid not null references auth.users (id) on delete cascade,
  recipient_name text not null,
  dish_name text not null,
  token_hash text not null unique,
  status text not null default 'pending'
    check (status in ('pending', 'fulfilled', 'expired', 'cancelled')),
  expires_at timestamptz not null,
  fulfilled_at timestamptz,
  created_at timestamptz not null default now()
);

-- Recipe submissions: responses to recipe requests (via public link)
create table public.recipe_submissions (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null unique references public.recipe_requests (id) on delete cascade,
  household_id uuid not null references public.households (id) on delete cascade,
  submitted_by_name text not null,
  recipe_title text not null,
  original_text text not null,
  created_recipe_id uuid not null references public.recipes (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 2. INDEXES
-- ============================================================

create index idx_recipe_requests_token_hash
  on public.recipe_requests (token_hash);

create index idx_recipe_requests_household_created
  on public.recipe_requests (household_id, created_at desc);

create index idx_recipes_household_created
  on public.recipes (household_id, created_at desc);

-- ============================================================
-- 3. AUTO-CREATE PROFILE ON SIGNUP (trigger)
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- ============================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.recipes enable row level security;
alter table public.recipe_requests enable row level security;
alter table public.recipe_submissions enable row level security;

-- Helper: check if current user is a member of a household
create or replace function public.is_household_member(h_id uuid)
returns boolean
language sql
security definer set search_path = ''
stable
as $$
  select exists (
    select 1
    from public.household_members
    where household_id = h_id
      and user_id = auth.uid()
  );
$$;

-- --- profiles ---
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- --- households ---
create policy "Members can view their households"
  on public.households for select
  using (public.is_household_member(id));

create policy "Authenticated users can create households"
  on public.households for insert
  with check (auth.uid() is not null);

create policy "Members can update their households"
  on public.households for update
  using (public.is_household_member(id));

-- --- household_members ---
create policy "Members can view household members"
  on public.household_members for select
  using (public.is_household_member(household_id));

create policy "Owners can add household members"
  on public.household_members for insert
  with check (
    -- allow self-insert (creating household) or existing owner adding members
    (auth.uid() = user_id)
    or
    (exists (
      select 1 from public.household_members
      where household_id = household_members.household_id
        and user_id = auth.uid()
        and role = 'owner'
    ))
  );

create policy "Owners can remove household members"
  on public.household_members for delete
  using (
    exists (
      select 1 from public.household_members hm
      where hm.household_id = household_members.household_id
        and hm.user_id = auth.uid()
        and hm.role = 'owner'
    )
  );

-- --- recipes ---
create policy "Members can view household recipes"
  on public.recipes for select
  using (public.is_household_member(household_id));

create policy "Members can create household recipes"
  on public.recipes for insert
  with check (public.is_household_member(household_id));

-- --- recipe_requests ---
create policy "Members can view household requests"
  on public.recipe_requests for select
  using (public.is_household_member(household_id));

create policy "Members can create household requests"
  on public.recipe_requests for insert
  with check (public.is_household_member(household_id));

-- --- recipe_submissions ---
create policy "Members can view household submissions"
  on public.recipe_submissions for select
  using (public.is_household_member(household_id));

-- BE-IMPL-04: Unified Family Recipe Card Model
-- Adds recipe_story, soft delete (hidden_at), clarification link,
-- unified view, and UPDATE RLS policies.

-- ============================================================
-- 1. NEW COLUMNS
-- ============================================================

-- recipe_story: family context / origin of the dish
ALTER TABLE public.recipe_requests ADD COLUMN recipe_story text;
ALTER TABLE public.recipes ADD COLUMN recipe_story text;

-- soft delete
ALTER TABLE public.recipes ADD COLUMN hidden_at timestamptz;
ALTER TABLE public.recipe_requests ADD COLUMN hidden_at timestamptz;

-- clarification link: follow-up request → parent recipe
ALTER TABLE public.recipe_requests ADD COLUMN parent_recipe_id uuid
  REFERENCES public.recipes(id) ON DELETE SET NULL;

-- ============================================================
-- 2. INDEXES
-- ============================================================

CREATE INDEX idx_recipe_requests_parent_recipe
  ON public.recipe_requests (parent_recipe_id)
  WHERE parent_recipe_id IS NOT NULL;

CREATE INDEX idx_recipes_hidden
  ON public.recipes (household_id, created_at DESC)
  WHERE hidden_at IS NULL;

CREATE INDEX idx_recipe_requests_hidden
  ON public.recipe_requests (household_id, created_at DESC)
  WHERE hidden_at IS NULL;

-- ============================================================
-- 3. UNIFIED VIEW: family_recipe_cards
-- ============================================================

CREATE VIEW public.family_recipe_cards
WITH (security_invoker = true)
AS

-- Unfulfilled requests → cards without recipe text
SELECT
  rr.id              AS card_id,
  rr.household_id,
  rr.dish_name       AS title,
  rr.recipient_name  AS author_name,
  NULL::text          AS original_text,
  CASE
    WHEN rr.status = 'pending' AND rr.expires_at < now() THEN 'expired'
    ELSE rr.status
  END                 AS card_status,
  rr.recipe_story,
  NULL::uuid          AS recipe_id,
  rr.id               AS request_id,
  rr.created_at
FROM public.recipe_requests rr
WHERE rr.status IN ('pending', 'expired')
  AND rr.hidden_at IS NULL

UNION ALL

-- Recipes (from fulfilled requests or manual creation)
SELECT
  r.id                AS card_id,
  r.household_id,
  r.title,
  r.author_name,
  r.original_text,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM public.recipe_requests cr
      WHERE cr.parent_recipe_id = r.id
        AND cr.status = 'pending'
        AND cr.hidden_at IS NULL
    ) THEN 'clarification'
    ELSE 'received'
  END                  AS card_status,
  COALESCE(r.recipe_story, rr.recipe_story) AS recipe_story,
  r.id                 AS recipe_id,
  rs.request_id        AS request_id,
  r.created_at
FROM public.recipes r
LEFT JOIN public.recipe_submissions rs ON rs.created_recipe_id = r.id
LEFT JOIN public.recipe_requests rr ON rr.id = rs.request_id
WHERE r.hidden_at IS NULL;

-- ============================================================
-- 4. UPDATE RLS POLICIES (for soft delete)
-- ============================================================

CREATE POLICY "Members can update household recipes"
  ON public.recipes FOR UPDATE
  USING (public.is_household_member(household_id))
  WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "Members can update household requests"
  ON public.recipe_requests FOR UPDATE
  USING (public.is_household_member(household_id))
  WITH CHECK (public.is_household_member(household_id));

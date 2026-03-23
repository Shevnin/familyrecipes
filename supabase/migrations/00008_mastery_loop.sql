-- REPEAT-LOOP-01: Mastery Loop (BE-SPEC-05 + BE-IMPL-05)
-- Adds recipe_attempts table, mastery read-model fields to family_recipe_cards VIEW.
--
-- Design contract:
--   mastery_status  ≠  card_status
--   mastery_status: per-user cooking progress (получил / пробовал / почти получилось / замастерил)
--   card_status:    lifecycle of the request/recipe card (pending / received / clarification / expired)
--
-- Attempt result mapping:
--   failed  → mastery_status = 'пробовал'
--   partial → mastery_status = 'почти получилось'
--   success → mastery_status = 'замастерил'
--   (no attempts) → mastery_status = 'получил'

-- ============================================================
-- 1. recipe_attempts TABLE
-- ============================================================

CREATE TABLE public.recipe_attempts (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id    uuid        NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
  household_id uuid        NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  created_by   uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  result       text        NOT NULL CHECK (result IN ('failed', 'partial', 'success')),
  note_text    text,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. INDEXES
-- ============================================================

-- Primary lookup: all attempts for a given recipe + user (for mastery aggregation)
CREATE INDEX idx_recipe_attempts_recipe_user
  ON public.recipe_attempts (recipe_id, created_by, created_at DESC);

-- Household-level index (for RLS + future metrics)
CREATE INDEX idx_recipe_attempts_household
  ON public.recipe_attempts (household_id, created_at DESC);

-- ============================================================
-- 3. RLS
-- ============================================================

ALTER TABLE public.recipe_attempts ENABLE ROW LEVEL SECURITY;

-- Members can view attempts in their household (covers own + future co-household)
CREATE POLICY "Members can view household attempts"
  ON public.recipe_attempts FOR SELECT
  USING (public.is_household_member(household_id));

-- Members can insert their own attempts only (created_by must match auth.uid())
CREATE POLICY "Members can insert own attempts"
  ON public.recipe_attempts FOR INSERT
  WITH CHECK (
    public.is_household_member(household_id)
    AND created_by = auth.uid()
  );

-- ============================================================
-- 4. UPDATE family_recipe_cards VIEW (add mastery read-model)
-- ============================================================

DROP VIEW IF EXISTS public.family_recipe_cards;

CREATE VIEW public.family_recipe_cards
WITH (security_invoker = true)
AS

-- ── Unfulfilled requests → pending/expired cards (no mastery)
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
  rr.created_at,
  -- mastery fields: not applicable for pending cards
  0::bigint           AS cook_count,
  'получил'::text     AS mastery_status,
  NULL::text          AS latest_attempt_result,
  NULL::text          AS latest_attempt_note,
  NULL::timestamptz   AS latest_cooked_at

FROM public.recipe_requests rr
WHERE rr.status IN ('pending', 'expired')
  AND rr.hidden_at IS NULL

UNION ALL

-- ── Recipes (from fulfilled requests or manual creation)
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
  r.created_at,
  -- mastery fields: aggregated from recipe_attempts for current user
  COALESCE(ma.cook_count, 0)::bigint AS cook_count,
  CASE
    WHEN ma.latest_result = 'success' THEN 'замастерил'
    WHEN ma.latest_result = 'partial' THEN 'почти получилось'
    WHEN ma.latest_result = 'failed'  THEN 'пробовал'
    ELSE 'получил'
  END                  AS mastery_status,
  ma.latest_result     AS latest_attempt_result,
  ma.latest_note       AS latest_attempt_note,
  ma.latest_cooked_at

FROM public.recipes r
LEFT JOIN public.recipe_submissions rs ON rs.created_recipe_id = r.id
LEFT JOIN public.recipe_requests rr ON rr.id = rs.request_id

-- Lateral join: latest attempt + count for current user for this recipe
LEFT JOIN LATERAL (
  SELECT
    result                                                    AS latest_result,
    note_text                                                 AS latest_note,
    created_at                                                AS latest_cooked_at,
    COUNT(*) OVER (PARTITION BY recipe_id, created_by)::bigint AS cook_count
  FROM public.recipe_attempts
  WHERE recipe_id = r.id
    AND created_by = auth.uid()
  ORDER BY created_at DESC
  LIMIT 1
) ma ON true

WHERE r.hidden_at IS NULL;

-- TECHNIQUES-01: Introduce content_kind ('recipe' | 'technique')
-- Adds content_kind to recipes and recipe_requests.
-- Propagates through VIEW (family_recipe_cards) and submit RPC.
-- Existing rows default to 'recipe'.

-- ============================================================
-- 1. ADD content_kind COLUMNS
-- ============================================================

ALTER TABLE public.recipes
  ADD COLUMN content_kind TEXT NOT NULL DEFAULT 'recipe'
  CHECK (content_kind IN ('recipe', 'technique'));

ALTER TABLE public.recipe_requests
  ADD COLUMN content_kind TEXT NOT NULL DEFAULT 'recipe'
  CHECK (content_kind IN ('recipe', 'technique'));

-- ============================================================
-- 2. UPDATE family_recipe_cards VIEW (add content_kind)
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
  rr.content_kind,
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
  r.content_kind,
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

-- ============================================================
-- 3. UPDATE submit_recipe_by_token RPC
--    Propagates content_kind from request row to new recipe.
--    Same 7-arg signature as 00007 — no Edge Function changes needed.
-- ============================================================

DROP FUNCTION IF EXISTS public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz);

CREATE OR REPLACE FUNCTION public.submit_recipe_by_token(
  p_token_hash     text,
  p_submitted_by_name text,
  p_recipe_title   text,
  p_original_text  text,
  p_recipe_story   text          DEFAULT NULL,
  p_edit_token_hash text         DEFAULT NULL,
  p_edit_expires_at timestamptz  DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_request      record;
  v_recipe_id    uuid;
  v_submission_id uuid;
BEGIN
  -- Lock request row to prevent race conditions
  SELECT id, household_id, status, expires_at, content_kind
  INTO v_request
  FROM public.recipe_requests
  WHERE token_hash = p_token_hash
  FOR UPDATE;

  IF v_request IS NULL THEN
    RAISE EXCEPTION 'request_not_found'
      USING hint = 'No request matches this token';
  END IF;

  IF v_request.status = 'fulfilled' THEN
    RAISE EXCEPTION 'request_already_fulfilled'
      USING hint = 'This request has already been fulfilled';
  END IF;

  IF v_request.status <> 'pending' THEN
    RAISE EXCEPTION 'request_not_pending'
      USING hint = 'Request status is: ' || v_request.status;
  END IF;

  IF v_request.expires_at < now() THEN
    RAISE EXCEPTION 'request_expired'
      USING hint = 'This request has expired';
  END IF;

  -- Create recipe, propagating content_kind from the request
  INSERT INTO public.recipes (
    household_id, title, author_name, original_text, recipe_story, content_kind
  )
  VALUES (
    v_request.household_id,
    p_recipe_title,
    p_submitted_by_name,
    p_original_text,
    p_recipe_story,
    v_request.content_kind
  )
  RETURNING id INTO v_recipe_id;

  INSERT INTO public.recipe_submissions (
    request_id, household_id, submitted_by_name,
    recipe_title, original_text, created_recipe_id,
    edit_token_hash, edit_expires_at
  )
  VALUES (
    v_request.id, v_request.household_id, p_submitted_by_name,
    p_recipe_title, p_original_text, v_recipe_id,
    p_edit_token_hash, p_edit_expires_at
  )
  RETURNING id INTO v_submission_id;

  UPDATE public.recipe_requests
  SET status = 'fulfilled', fulfilled_at = now()
  WHERE id = v_request.id;

  RETURN jsonb_build_object(
    'recipe_id', v_recipe_id,
    'submission_id', v_submission_id
  );
END;
$$;

-- Restore grants (same as 00007)
REVOKE EXECUTE ON FUNCTION public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) FROM public;
REVOKE EXECUTE ON FUNCTION public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) FROM anon;
REVOKE EXECUTE ON FUNCTION public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) FROM authenticated;
GRANT  EXECUTE ON FUNCTION public.submit_recipe_by_token(text, text, text, text, text, text, timestamptz) TO service_role;

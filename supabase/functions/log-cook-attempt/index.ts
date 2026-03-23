import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createServiceClient, createUserClient } from "../_shared/supabase.ts";

// result → mastery_status mapping (mirrors SQL VIEW logic)
function toMasteryStatus(result: string | null): string {
  switch (result) {
    case "success": return "замастерил";
    case "partial": return "почти получилось";
    case "failed":  return "пробовал";
    default:        return "получил";
  }
}

Deno.serve(async (req) => {
  const corsResp = handleCors(req);
  if (corsResp) return corsResp;

  try {
    // --- Auth check ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const userClient = createUserClient(authHeader);
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Parse input ---
    const body = await req.json();
    const { recipe_id, result, note_text = null } = body;

    if (!recipe_id || !result) {
      return new Response(
        JSON.stringify({ error: "recipe_id and result are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (!["failed", "partial", "success"].includes(result)) {
      return new Response(
        JSON.stringify({ error: "result must be one of: failed, partial, success" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const serviceClient = createServiceClient();

    // --- Validate recipe exists and user is in its household ---
    const { data: recipe, error: recipeError } = await serviceClient
      .from("recipes")
      .select("id, household_id")
      .eq("id", recipe_id)
      .is("hidden_at", null)
      .single();

    if (recipeError || !recipe) {
      return new Response(
        JSON.stringify({ error: "recipe_not_found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: member } = await serviceClient
      .from("household_members")
      .select("household_id")
      .eq("user_id", user.id)
      .eq("household_id", recipe.household_id)
      .single();

    if (!member) {
      return new Response(
        JSON.stringify({ error: "Forbidden" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Insert attempt ---
    const { data: attempt, error: insertError } = await serviceClient
      .from("recipe_attempts")
      .insert({
        recipe_id,
        household_id: recipe.household_id,
        created_by: user.id,
        result,
        note_text: note_text || null,
      })
      .select("id, created_at")
      .single();

    if (insertError || !attempt) {
      console.error("log-cook-attempt insert failed:", insertError?.message);
      return new Response(
        JSON.stringify({ error: "log_attempt_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Compute updated mastery read-model ---
    const { data: attempts } = await serviceClient
      .from("recipe_attempts")
      .select("result, note_text, created_at")
      .eq("recipe_id", recipe_id)
      .eq("created_by", user.id)
      .order("created_at", { ascending: false });

    const cookCount = attempts?.length ?? 1;
    const latest = attempts?.[0];

    return new Response(
      JSON.stringify({
        attempt_id: attempt.id,
        cook_count: cookCount,
        mastery_status: toMasteryStatus(latest?.result ?? null),
        latest_attempt_result: latest?.result ?? null,
        latest_attempt_note: latest?.note_text ?? null,
        latest_cooked_at: latest?.created_at ?? attempt.created_at,
      }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("log-cook-attempt unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

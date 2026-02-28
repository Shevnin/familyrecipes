import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createServiceClient } from "../_shared/supabase.ts";

async function sha256(message: string): Promise<string> {
  const data = new TextEncoder().encode(message);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

Deno.serve(async (req) => {
  const corsResp = handleCors(req);
  if (corsResp) return corsResp;

  try {
    const body = await req.json();
    const { token, submitted_by_name, recipe_title, original_text, captcha_token } = body;

    if (!token || !submitted_by_name || !recipe_title || !original_text) {
      return new Response(
        JSON.stringify({
          error: "token, submitted_by_name, recipe_title, and original_text are required",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Optional CAPTCHA verification (Cloudflare Turnstile) ---
    const captchaSecret = Deno.env.get("CAPTCHA_SECRET");
    if (captchaSecret) {
      if (!captcha_token) {
        return new Response(
          JSON.stringify({ error: "captcha_required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      const captchaResp = await fetch(
        "https://challenges.cloudflare.com/turnstile/v0/siteverify",
        {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: new URLSearchParams({
            secret: captchaSecret,
            response: captcha_token,
          }),
        },
      );
      const captchaResult = await captchaResp.json();
      if (!captchaResult.success) {
        return new Response(
          JSON.stringify({ error: "captcha_failed" }),
          { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    const tokenHash = await sha256(token);
    const serviceClient = createServiceClient();

    // --- Find request by token hash ---
    const { data: request, error: findError } = await serviceClient
      .from("recipe_requests")
      .select("id, household_id, status, expires_at")
      .eq("token_hash", tokenHash)
      .single();

    if (findError || !request) {
      return new Response(
        JSON.stringify({ error: "request_not_found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (request.status === "fulfilled") {
      return new Response(
        JSON.stringify({ error: "request_already_fulfilled" }),
        { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (request.status !== "pending") {
      return new Response(
        JSON.stringify({ error: "request_not_pending" }),
        { status: 410, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (new Date(request.expires_at) < new Date()) {
      return new Response(
        JSON.stringify({ error: "request_expired" }),
        { status: 410, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Create recipe ---
    const { data: recipe, error: recipeError } = await serviceClient
      .from("recipes")
      .insert({
        household_id: request.household_id,
        title: recipe_title,
        author_name: submitted_by_name,
        original_text,
      })
      .select("id")
      .single();

    if (recipeError || !recipe) {
      console.error("submit-request: recipe insert failed:", recipeError?.message);
      return new Response(
        JSON.stringify({ error: "submit_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Create submission record ---
    const { data: submission, error: subError } = await serviceClient
      .from("recipe_submissions")
      .insert({
        request_id: request.id,
        household_id: request.household_id,
        submitted_by_name,
        recipe_title,
        original_text,
        created_recipe_id: recipe.id,
      })
      .select("id")
      .single();

    if (subError || !submission) {
      console.error("submit-request: submission insert failed:", subError?.message);
      return new Response(
        JSON.stringify({ error: "submit_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Mark request as fulfilled ---
    await serviceClient
      .from("recipe_requests")
      .update({ status: "fulfilled", fulfilled_at: new Date().toISOString() })
      .eq("id", request.id);

    return new Response(
      JSON.stringify({
        success: true,
        recipe_id: recipe.id,
        submission_id: submission.id,
      }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("submit-request unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

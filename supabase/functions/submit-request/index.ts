import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createServiceClient } from "../_shared/supabase.ts";

async function sha256(message: string): Promise<string> {
  const data = new TextEncoder().encode(message);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

const ERROR_HTTP_MAP: Record<string, number> = {
  request_not_found: 404,
  request_already_fulfilled: 409,
  request_expired: 410,
  request_not_pending: 410,
};

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

    const { data, error } = await serviceClient.rpc("submit_recipe_by_token", {
      p_token_hash: tokenHash,
      p_submitted_by_name: submitted_by_name,
      p_recipe_title: recipe_title,
      p_original_text: original_text,
    });

    if (error) {
      // Extract error code from PostgreSQL exception message
      const pgError = error.message ?? "";
      for (const [code, status] of Object.entries(ERROR_HTTP_MAP)) {
        if (pgError.includes(code)) {
          return new Response(
            JSON.stringify({ error: code }),
            { status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
          );
        }
      }
      console.error("submit-request rpc failed:", pgError);
      return new Response(
        JSON.stringify({ error: "submit_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        recipe_id: data.recipe_id,
        submission_id: data.submission_id,
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

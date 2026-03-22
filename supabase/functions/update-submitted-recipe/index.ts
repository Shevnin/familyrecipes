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
  edit_not_found: 404,
  edit_window_expired: 410,
};

Deno.serve(async (req) => {
  const corsResp = handleCors(req);
  if (corsResp) return corsResp;

  try {
    const body = await req.json();
    const { edit_token, submitted_by_name, recipe_title, original_text, recipe_story } = body;

    if (!edit_token || !submitted_by_name || !recipe_title || !original_text) {
      return new Response(
        JSON.stringify({
          error: "edit_token, submitted_by_name, recipe_title, and original_text are required",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const editTokenHash = await sha256(edit_token);
    const serviceClient = createServiceClient();

    const rpcParams: Record<string, unknown> = {
      p_edit_token_hash: editTokenHash,
      p_submitted_by_name: submitted_by_name,
      p_recipe_title: recipe_title,
      p_original_text: original_text,
    };
    // Always pass recipe_story (null clears it, string updates it)
    rpcParams.p_recipe_story = recipe_story || null;

    const { data, error } = await serviceClient.rpc("update_recipe_by_edit_token", rpcParams);

    if (error) {
      const pgError = error.message ?? "";
      for (const [code, status] of Object.entries(ERROR_HTTP_MAP)) {
        if (pgError.includes(code)) {
          return new Response(
            JSON.stringify({ error: code }),
            { status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
          );
        }
      }
      console.error("update-submitted-recipe rpc failed:", pgError);
      return new Response(
        JSON.stringify({ error: "update_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        recipe_id: data.recipe_id,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("update-submitted-recipe unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

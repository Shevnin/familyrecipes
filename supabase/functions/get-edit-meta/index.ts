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
    let editToken: string | null = null;

    if (req.method === "POST") {
      const body = await req.json();
      editToken = body.edit_token ?? null;
    } else {
      const url = new URL(req.url);
      editToken = url.searchParams.get("edit_token");
    }

    if (!editToken) {
      return new Response(
        JSON.stringify({ error: "edit_token is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const editTokenHash = await sha256(editToken);
    const serviceClient = createServiceClient();

    // Look up submission by edit_token_hash
    const { data: sub, error } = await serviceClient
      .from("recipe_submissions")
      .select("id, submitted_by_name, recipe_title, original_text, created_recipe_id, edit_expires_at")
      .eq("edit_token_hash", editTokenHash)
      .single();

    if (error || !sub) {
      return new Response(
        JSON.stringify({ error: "edit_not_found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Check if edit window expired
    if (new Date(sub.edit_expires_at) < new Date()) {
      return new Response(
        JSON.stringify({ error: "edit_window_expired" }),
        { status: 410, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Fetch recipe_story and content_kind from the recipe record
    const { data: recipe } = await serviceClient
      .from("recipes")
      .select("recipe_story, content_kind")
      .eq("id", sub.created_recipe_id)
      .single();

    return new Response(
      JSON.stringify({
        submitted_by_name: sub.submitted_by_name,
        recipe_title: sub.recipe_title,
        original_text: sub.original_text,
        recipe_story: recipe?.recipe_story ?? null,
        content_kind: recipe?.content_kind ?? "recipe",
        edit_expires_at: sub.edit_expires_at,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("get-edit-meta unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

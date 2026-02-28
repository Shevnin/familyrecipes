import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createServiceClient, createUserClient } from "../_shared/supabase.ts";

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
      console.error(`create-request auth failed: ${authError?.message ?? "no user"}`);
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Parse input ---
    const body = await req.json();
    const { recipient_name, dish_name, expires_in_days = 7, household_id } = body;

    if (!recipient_name || !dish_name) {
      return new Response(
        JSON.stringify({ error: "recipient_name and dish_name are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Resolve household ---
    const serviceClient = createServiceClient();
    let resolvedHouseholdId: string;

    if (household_id) {
      // Validate that user is a member of the specified household
      const { data: member } = await serviceClient
        .from("household_members")
        .select("household_id")
        .eq("user_id", user.id)
        .eq("household_id", household_id)
        .single();

      if (!member) {
        return new Response(
          JSON.stringify({ error: "User is not a member of this household" }),
          { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      resolvedHouseholdId = member.household_id;
    } else {
      // Auto-resolve: must have exactly one household
      const { data: memberships } = await serviceClient
        .from("household_members")
        .select("household_id")
        .eq("user_id", user.id);

      if (!memberships || memberships.length === 0) {
        return new Response(
          JSON.stringify({ error: "User is not a member of any household" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      if (memberships.length > 1) {
        return new Response(
          JSON.stringify({
            error: "household_id_required",
            household_ids: memberships.map((m: { household_id: string }) => m.household_id),
          }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      resolvedHouseholdId = memberships[0].household_id;
    }

    // --- Generate token ---
    const token = crypto.randomUUID();
    const tokenHash = await sha256(token);
    const expiresAt = new Date(
      Date.now() + expires_in_days * 24 * 60 * 60 * 1000,
    ).toISOString();

    // --- Create request ---
    const { data: request, error: insertError } = await serviceClient
      .from("recipe_requests")
      .insert({
        household_id: resolvedHouseholdId,
        requested_by: user.id,
        recipient_name,
        dish_name,
        token_hash: tokenHash,
        status: "pending",
        expires_at: expiresAt,
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("create-request insert failed:", insertError.message);
      return new Response(
        JSON.stringify({ error: "create_request_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // URL contract:
    //   APP_BASE_URL = site root, e.g. https://shevnin.github.io/familyrecipes
    //   APP_LINK_MODE = "query" → /web-reply/?token=<token>  (GitHub Pages, no rewrites)
    //   APP_LINK_MODE = "path"  → /r/<token>                 (Cloudflare/Vercel with rewrites)
    const baseUrl = (Deno.env.get("APP_BASE_URL") || "https://familyrecipes.app").replace(/\/$/, "");
    const linkMode = Deno.env.get("APP_LINK_MODE") || "path";
    const webUrl = linkMode === "query"
      ? `${baseUrl}/web-reply/?token=${token}`
      : `${baseUrl}/r/${token}`;
    const shareText =
      `${recipient_name}, поделитесь рецептом "${dish_name}"!\n${webUrl}`;

    return new Response(
      JSON.stringify({
        request_id: request.id,
        token,
        web_url: webUrl,
        share_text: shareText,
        expires_at: expiresAt,
      }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("create-request unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

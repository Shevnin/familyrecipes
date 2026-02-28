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
    // Accept token from JSON body or query param
    let token: string | null = null;

    if (req.method === "POST") {
      const body = await req.json();
      token = body.token ?? null;
    } else {
      const url = new URL(req.url);
      token = url.searchParams.get("token");
    }

    if (!token) {
      return new Response(
        JSON.stringify({ error: "token is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const tokenHash = await sha256(token);
    const serviceClient = createServiceClient();

    const { data: request, error } = await serviceClient
      .from("recipe_requests")
      .select("recipient_name, dish_name, status, expires_at")
      .eq("token_hash", tokenHash)
      .single();

    if (error || !request) {
      return new Response(
        JSON.stringify({ error: "request_not_found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Check if expired (but not yet marked)
    const isExpired = new Date(request.expires_at) < new Date();
    const effectiveStatus = (request.status === "pending" && isExpired)
      ? "expired"
      : request.status;

    return new Response(
      JSON.stringify({
        recipient_name: request.recipient_name,
        dish_name: request.dish_name,
        status: effectiveStatus,
        expires_at: request.expires_at,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("get-request-meta unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

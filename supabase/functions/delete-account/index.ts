import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function unauthorizedUnlessProjectKey(req: Request): Response | null {
  const expected = Deno.env.get("SUPABASE_ANON_KEY")?.trim();
  if (!expected) {
    return json(500, { error: "Server misconfigured" });
  }
  const apikey = req.headers.get("apikey")?.trim() ?? "";
  const auth = req.headers.get("Authorization")?.trim() ?? "";
  const bearer = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  const ok = apikey === expected || bearer === expected;
  if (ok) return null;
  return json(401, { error: "Unauthorized" });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json(405, { error: "Method not allowed" });
  }

  const authFail = unauthorizedUnlessProjectKey(req);
  if (authFail) return authFail;

  const url = Deno.env.get("SUPABASE_URL")?.trim();
  const anon = Deno.env.get("SUPABASE_ANON_KEY")?.trim();
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();
  const authHeader = req.headers.get("Authorization")?.trim() ?? "";

  if (!url || !anon || !service || !authHeader.startsWith("Bearer ")) {
    return json(500, { error: "Server misconfigured" });
  }

  const userClient = createClient(url, anon, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user?.id) {
    return json(401, { error: "invalid_session" });
  }

  const uid = userData.user.id;

  let confirm = false;
  try {
    const b = await req.json();
    confirm = Boolean((b as { confirm?: boolean }).confirm);
  } catch {
    /* body optional */
  }
  if (!confirm) {
    return json(400, { error: "confirm_required", hint: "POST {\"confirm\":true}" });
  }

  const admin = createClient(url, service, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { error: delErr } = await admin.auth.admin.deleteUser(uid);
  if (delErr) {
    console.error("delete-account", delErr);
    return json(503, { error: "delete_failed", detail: delErr.message });
  }

  return json(200, { ok: true });
});

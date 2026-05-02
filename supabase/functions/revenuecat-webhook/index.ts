import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-revenuecat-signature",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const DEFAULT_ENTITLEMENT = "Glu Gold";

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function verifyAuth(req: Request): boolean {
  const expected = Deno.env.get("REVENUECAT_WEBHOOK_AUTH")?.trim();
  if (!expected) {
    console.error("revenuecat-webhook: REVENUECAT_WEBHOOK_AUTH not set");
    return false;
  }
  const got = req.headers.get("Authorization")?.trim() ?? "";
  return got === expected;
}

type RCEvent = {
  id?: string;
  type?: string;
  app_user_id?: string;
  entitlement_ids?: string[];
  expiration_at_ms?: number;
  product_id?: string;
};

type RCPayload = {
  event?: RCEvent;
  api_version?: string;
};

function parseUuid(s: string): string | null {
  const u = s.trim();
  if (
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      .test(u)
  ) {
    return u.toLowerCase();
  }
  return null;
}

function deriveActiveAndExpiry(
  eventType: string,
  expirationAtMs?: number,
): { is_active: boolean; expires_at: string | null } {
  const t = (eventType || "").toUpperCase();
  if (t === "EXPIRATION" || t === "BILLING_ISSUE") {
    return { is_active: false, expires_at: null };
  }
  if (expirationAtMs && Number.isFinite(expirationAtMs)) {
    const d = new Date(expirationAtMs);
    const iso = d.toISOString();
    if (t === "CANCELLATION") {
      return { is_active: true, expires_at: iso };
    }
    return { is_active: true, expires_at: iso };
  }
  if (
    t === "INITIAL_PURCHASE" || t === "RENEWAL" || t === "UNCANCELLATION" ||
    t === "NON_RENEWING_PURCHASE" || t === "PRODUCT_CHANGE" || t === "TEST"
  ) {
    return { is_active: true, expires_at: null };
  }
  return { is_active: false, expires_at: null };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json(405, { error: "Method not allowed" });
  }

  if (!verifyAuth(req)) {
    return json(401, { error: "Unauthorized" });
  }

  let body: RCPayload;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "Invalid JSON" });
  }

  const ev = body.event;
  if (!ev?.app_user_id) {
    return json(200, { ok: true, skipped: "no_app_user_id" });
  }

  const userId = parseUuid(ev.app_user_id);
  if (!userId) {
    console.warn("revenuecat-webhook: non-uuid app_user_id", ev.app_user_id);
    return json(200, { ok: true, skipped: "non_uuid_app_user_id" });
  }

  const entitlementIds = ev.entitlement_ids ?? [];
  const entitlementId = entitlementIds.includes(DEFAULT_ENTITLEMENT)
    ? DEFAULT_ENTITLEMENT
    : (entitlementIds[0] ?? DEFAULT_ENTITLEMENT);

  const { is_active, expires_at } = deriveActiveAndExpiry(
    ev.type ?? "",
    ev.expiration_at_ms,
  );

  const url = Deno.env.get("SUPABASE_URL")?.trim();
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();
  if (!url || !serviceKey) {
    console.error("revenuecat-webhook: missing Supabase env");
    return json(500, { error: "Server misconfigured" });
  }

  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { error } = await admin.from("revenuecat_entitlements").upsert(
    {
      user_id: userId,
      rc_app_user_id: ev.app_user_id,
      entitlement_id: entitlementId,
      is_active,
      expires_at,
      last_event_id: ev.id ?? null,
      payload: body as unknown as Record<string, unknown>,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  if (error) {
    console.error("revenuecat upsert", error);
    return json(500, { error: "persist_failed" });
  }

  // Optional: refresh canonical subscriber from RevenueCat REST (stronger consistency).
  const rcSecret = Deno.env.get("REVENUECAT_SECRET_API_KEY")?.trim();
  if (rcSecret && ev.app_user_id) {
    try {
      const subRes = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(ev.app_user_id)}`,
        { headers: { Authorization: `Bearer ${rcSecret}` } },
      );
      if (subRes.ok) {
        const sub = await subRes.json() as {
          subscriber?: {
            entitlements?: Record<
              string,
              { expires_date?: string; will_renew?: boolean }
            >;
          };
        };
        const ent = sub.subscriber?.entitlements?.[entitlementId];
        if (ent?.expires_date) {
          const expires = new Date(ent.expires_date);
          const stillActive = expires.getTime() > Date.now();
          await admin.from("revenuecat_entitlements").upsert(
            {
              user_id: userId,
              rc_app_user_id: ev.app_user_id,
              entitlement_id: entitlementId,
              is_active: stillActive,
              expires_at: expires.toISOString(),
              last_event_id: ev.id ?? null,
              payload: sub as unknown as Record<string, unknown>,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "user_id" },
          );
        }
      }
    } catch (e) {
      console.warn("revenuecat REST refresh failed", e);
    }
  }

  return json(200, { ok: true });
});

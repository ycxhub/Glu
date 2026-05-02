import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import {
  type AnalysisState,
  buildEnvelope,
  deriveAnalysisState,
  JSON_INSTRUCTION,
  type MealAIOutput,
  type MealEnvelope,
  mockOutput,
  parseOpenAIContent,
  sanitizeMealOutput,
  shouldCharge,
} from "./lib.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const MAX_IMAGE_BYTES = 2_500_000; // after base64 decode
const MAX_BASE64_CHARS = 3_600_000;

function jsonError(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Reject if `apikey` / Bearer publishable key does not match project anon key. */
function unauthorizedUnlessProjectKey(req: Request): Response | null {
  const expected = Deno.env.get("SUPABASE_ANON_KEY")?.trim();
  if (!expected) {
    console.error("analyze-meal: SUPABASE_ANON_KEY missing in Edge env");
    return jsonError(500, { error: "Server misconfigured" });
  }
  const apikey = req.headers.get("apikey")?.trim() ?? "";
  const auth = req.headers.get("Authorization")?.trim() ?? "";
  const bearer = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  const ok = apikey === expected || bearer === expected;
  if (ok) return null;
  return jsonError(401, {
    error: "Unauthorized",
    hint: "Send apikey header matching project publishable key",
  });
}

function userSupabase(req: Request): SupabaseClient | null {
  const url = Deno.env.get("SUPABASE_URL")?.trim();
  const anon = Deno.env.get("SUPABASE_ANON_KEY")?.trim();
  const auth = req.headers.get("Authorization")?.trim() ?? "";
  if (!url || !anon || !auth.startsWith("Bearer ")) return null;
  return createClient(url, anon, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

type ReserveResult = Record<string, unknown>;

async function callReserve(
  sb: SupabaseClient,
  idempotencyKey: string,
  installId: string,
): Promise<ReserveResult> {
  const { data, error } = await sb.rpc("reserve_meal_analysis", {
    p_idempotency_key: idempotencyKey,
    p_install_id: installId,
  });
  if (error) {
    console.error("reserve_meal_analysis", error);
    return { ok: false, error: "reserve_rpc_failed", detail: error.message };
  }
  return (data ?? {}) as ReserveResult;
}

async function callRelease(
  sb: SupabaseClient,
  attemptId: string,
  message: string,
  analysisState?: AnalysisState,
): Promise<void> {
  const { error } = await sb.rpc("release_meal_analysis", {
    p_attempt_id: attemptId,
    p_error_message: message,
    p_analysis_state: analysisState ?? null,
  });
  if (error) console.error("release_meal_analysis", error);
}

async function callFinalize(
  sb: SupabaseClient,
  attemptId: string,
  envelope: MealEnvelope,
  state: AnalysisState,
  charge: boolean,
): Promise<Record<string, unknown>> {
  const { data, error } = await sb.rpc("finalize_meal_analysis", {
    p_attempt_id: attemptId,
    p_envelope: envelope as unknown as Record<string, unknown>,
    p_analysis_state: state,
    p_should_charge: charge,
  });
  if (error) {
    console.error("finalize_meal_analysis", error);
    return { ok: false, error: error.message };
  }
  return (data ?? {}) as Record<string, unknown>;
}

async function fetchQuota(
  sb: SupabaseClient,
  installId: string,
): Promise<Record<string, unknown> | null> {
  const { data, error } = await sb.rpc("meal_analysis_quota_status", {
    p_install_id: installId,
  });
  if (error) {
    console.warn("meal_analysis_quota_status", error);
    return null;
  }
  return (data ?? null) as Record<string, unknown> | null;
}

async function jsonWithQuota(
  sb: SupabaseClient,
  installId: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const quota = await fetchQuota(sb, installId);
  return new Response(JSON.stringify({ ...body, quota }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function analyzeWithOpenAIOrThrow(
  imageBase64: string,
  apiKey: string,
): Promise<MealAIOutput> {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_VISION_MODEL") ?? "gpt-4o-mini",
      temperature: 0.3,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: JSON_INSTRUCTION },
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "Estimate this meal from the photo. JSON only.",
            },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${imageBase64}`,
                detail: "low",
              },
            },
          ],
        },
      ],
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    console.error("openai error", res.status, errText.slice(0, 2000));
    const status = res.status >= 500 ? 503 : 502;
    throw { httpStatus: status, message: "Meal analysis service unavailable" };
  }

  const body = await res.json() as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = body.choices?.[0]?.message?.content;
  if (!content?.trim()) {
    throw { httpStatus: 502, message: "Empty model response" };
  }

  const parsed = parseOpenAIContent(content);
  if (!parsed) {
    throw { httpStatus: 502, message: "Could not parse model JSON" };
  }
  return sanitizeMealOutput(parsed);
}

function decodeImageSize(imageBase64: string): number {
  try {
    const bin = atob(imageBase64);
    return bin.length;
  } catch {
    return Number.MAX_SAFE_INTEGER;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonError(405, { error: "Method not allowed" });
  }

  const authFail = unauthorizedUnlessProjectKey(req);
  if (authFail) return authFail;

  const sb = userSupabase(req);
  if (!sb) {
    return jsonError(401, { error: "Missing Authorization Bearer session JWT" });
  }

  let payload: {
    image_base64?: string;
    idempotency_key?: string;
    install_id?: string;
  };
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, { error: "Invalid JSON body" });
  }

  const imageBase64 = payload.image_base64?.trim();
  const idempotencyKey = payload.idempotency_key?.trim();
  const installId = (payload.install_id ?? "").trim();

  if (!imageBase64) {
    return jsonError(400, { error: "image_base64 required" });
  }
  if (!idempotencyKey) {
    return jsonError(400, { error: "idempotency_key required" });
  }
  if (imageBase64.length > MAX_BASE64_CHARS) {
    return jsonError(413, { error: "image_too_large" });
  }
  const decodedBytes = decodeImageSize(imageBase64);
  if (decodedBytes > MAX_IMAGE_BYTES) {
    return jsonError(413, { error: "image_too_large" });
  }

  const reserve = await callReserve(sb, idempotencyKey, installId);
  if (reserve.ok === false) {
    if (reserve.error === "quota_exhausted") {
      return jsonError(402, {
        error: "quota_exhausted",
        charged: reserve.charged,
      });
    }
    if (reserve.error === "not_authenticated") {
      return jsonError(401, { error: "not_authenticated" });
    }
    return jsonError(400, { error: String(reserve.error ?? "reserve_failed") });
  }

  // Idempotent replay: completed meal
  if (reserve.duplicate === true && reserve.meal_id) {
    const mealId = String(reserve.meal_id);
    const { data: row, error } = await sb.from("meal_logs").select("id, output, envelope").eq(
      "id",
      mealId,
    ).maybeSingle();
    if (error || !row) {
      return jsonError(500, { error: "meal_lookup_failed" });
    }
    const envelope = (row.envelope ?? buildEnvelope(
      (reserve.analysis_state as AnalysisState) ?? "ready",
      row.output as MealAIOutput,
    )) as MealEnvelope;
    return await jsonWithQuota(sb, installId, {
      meal_id: mealId,
      analysis_state: envelope.analysis_state ?? reserve.analysis_state,
      charged: reserve.charged ?? false,
      envelope,
      user_estimate: envelope.user_estimate ?? row.output,
    });
  }

  const attemptId = String(reserve.attempt_id ?? "");
  if (!attemptId) {
    return jsonError(500, { error: "missing_attempt_id" });
  }

  const openaiKey = Deno.env.get("OPENAI_API_KEY")?.trim() ?? "";

  const finishSuccess = async (estimate: MealAIOutput) => {
    const state = deriveAnalysisState(estimate);
    const envelope = buildEnvelope(state, estimate);
    const fin = await callFinalize(sb, attemptId, envelope, state, shouldCharge(state));
    if (fin.ok !== true) {
      await callRelease(sb, attemptId, String(fin.error ?? "finalize_failed"), "analysis_failed");
      return jsonError(503, { error: "persist_failed" });
    }
    return await jsonWithQuota(sb, installId, {
      meal_id: fin.meal_id,
      analysis_state: state,
      charged: fin.charged ?? false,
      envelope,
      user_estimate: estimate,
    });
  };

  try {
    if (!openaiKey) {
      const output = sanitizeMealOutput(mockOutput());
      return await finishSuccess(output);
    }

    let output: MealAIOutput;
    try {
      output = await analyzeWithOpenAIOrThrow(imageBase64, openaiKey);
    } catch (err: unknown) {
      const typed = err as { httpStatus?: number; message?: string };
      await callRelease(
        sb,
        attemptId,
        typed.message ?? "openai_failed",
        "analysis_failed",
      );
      const status = typeof typed.httpStatus === "number" ? typed.httpStatus : 503;
      return jsonError(status, { error: typed.message ?? "Meal analysis failed" });
    }

    if (output.items.length === 0) {
      await callRelease(sb, attemptId, "no_food", "no_food");
      const envelope = buildEnvelope("no_food", {
        items: [],
        totals: output.totals,
        spike_risk: output.spike_risk,
        rationale: output.rationale,
        disclaimer: output.disclaimer,
        confidence: output.confidence,
      });
      return await jsonWithQuota(sb, installId, {
        meal_id: null,
        analysis_state: "no_food" as const,
        charged: false,
        envelope,
        user_estimate: envelope.user_estimate,
      });
    }

    return await finishSuccess(output);
  } catch (err) {
    console.error("analyze-meal unexpected", err);
    await callRelease(sb, attemptId, "unexpected", "analysis_failed");
    return jsonError(500, { error: "internal_error" });
  }
});

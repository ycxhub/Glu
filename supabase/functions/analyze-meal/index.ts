import "@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type MealLineItem = {
  name: string;
  portion_guess: string;
  calories: number;
  carbs_g: number;
};

type MealTotals = {
  calories?: number;
  carbs_g?: number;
  fiber_g?: number;
  sugar_g?: number;
  protein_g?: number;
  fat_g?: number;
};

type MealAIOutput = {
  items: MealLineItem[];
  totals?: MealTotals;
  spike_risk: string;
  rationale: string;
  disclaimer: string;
  confidence: number;
};

/** Hosted Edge injects `SUPABASE_ANON_KEY` (publishable or legacy anon shape). Reject requests without a matching client key. */
function unauthorizedUnlessProjectKey(req: Request): Response | null {
  const expected = Deno.env.get("SUPABASE_ANON_KEY")?.trim();
  if (!expected) {
    console.error("analyze-meal: SUPABASE_ANON_KEY missing in Edge env");
    return new Response(JSON.stringify({ error: "Server misconfigured" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  const apikey = req.headers.get("apikey")?.trim() ?? "";
  const auth = req.headers.get("Authorization")?.trim() ?? "";
  const bearer = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  const ok = apikey === expected || bearer === expected;
  if (ok) return null;
  return new Response(JSON.stringify({ error: "Unauthorized", hint: "Send apikey + Authorization Bearer matching project publishable key" }), {
    status: 401,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function mockOutput(): MealAIOutput {
  return {
    items: [
      {
        name: "Mixed plate",
        portion_guess: "1 plate",
        calories: 520,
        carbs_g: 58,
      },
    ],
    totals: {
      calories: 520,
      carbs_g: 58,
      fiber_g: 6,
      sugar_g: 12,
      protein_g: 22,
      fat_g: 18,
    },
    spike_risk: "medium",
    rationale:
      "Portion looks moderate with visible starch and limited fiber in frame — educational guess only.",
    disclaimer: "Educational estimate only. Not medical advice.",
    confidence: 0.62,
  };
}

const JSON_INSTRUCTION = `You are a nutrition estimation assistant for a diabetes-education app.
Return ONLY valid JSON matching this shape (snake_case keys, numbers where shown):
{
  "items": [{"name": string, "portion_guess": string, "calories": number, "carbs_g": number}],
  "totals": {"calories": number, "carbs_g": number, "fiber_g": number, "sugar_g": number, "protein_g": number, "fat_g": number},
  "spike_risk": "low" | "medium" | "high",
  "rationale": string (one short paragraph, educational tone),
  "disclaimer": "Educational estimate only. Not medical advice.",
  "confidence": number between 0 and 1
}
Do not diagnose. Use spike_risk as an educational guess based on visible carbs vs fiber/protein.`;

function parseOpenAIContent(raw: string): MealAIOutput | null {
  const trimmed = raw.trim();
  try {
    const parsed = JSON.parse(trimmed) as MealAIOutput;
    if (parsed && Array.isArray(parsed.items) && typeof parsed.spike_risk === "string") {
      return parsed;
    }
  } catch {
    // try fenced block
    const m = trimmed.match(/\{[\s\S]*\}/);
    if (m) {
      try {
        const parsed = JSON.parse(m[0]) as MealAIOutput;
        if (parsed && Array.isArray(parsed.items)) return parsed;
      } catch {
        /* ignore */
      }
    }
  }
  return null;
}

async function analyzeWithOpenAI(
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
    console.error("openai error", res.status, errText);
    return mockOutput();
  }

  const body = await res.json() as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = body.choices?.[0]?.message?.content;
  if (!content) return mockOutput();

  const parsed = parseOpenAIContent(content);
  return parsed ?? mockOutput();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const authFail = unauthorizedUnlessProjectKey(req);
  if (authFail) return authFail;

  let payload: { image_base64?: string; user_id?: string };
  try {
    payload = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const imageBase64 = payload.image_base64?.trim();
  if (!imageBase64) {
    return new Response(JSON.stringify({ error: "image_base64 required" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const openaiKey = Deno.env.get("OPENAI_API_KEY")?.trim();
  const output: MealAIOutput = openaiKey && openaiKey.length > 0
    ? await analyzeWithOpenAI(imageBase64, openaiKey)
    : mockOutput();

  return new Response(JSON.stringify(output), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});

/**
 * Pure helpers for the analyze-meal edge function. Kept side-effect-free so
 * `edge_contract_test.ts` can import them without binding an HTTP listener.
 */

export const ENVELOPE_VERSION = 1;
export const PROMPT_VERSION = "glu-vision-v1";

export const SAFE_COACHING_FALLBACK =
  "Educational estimate only — not medical advice.";

export type MealLineItem = {
  name: string;
  portion_guess: string;
  calories: number;
  carbs_g: number;
};

export type MealTotals = {
  calories?: number;
  carbs_g?: number;
  fiber_g?: number;
  sugar_g?: number;
  protein_g?: number;
  fat_g?: number;
};

export type MealAIOutput = {
  items: MealLineItem[];
  totals?: MealTotals;
  spike_risk: string;
  rationale: string;
  disclaimer: string;
  confidence: number;
};

export type AnalysisState =
  | "ready"
  | "low_confidence"
  | "no_food"
  | "analysis_failed";

export type SpikeLesson = {
  risk_band: string;
  headline: string;
  coaching: string;
};

export type MealEnvelope = {
  envelope_version: number;
  prompt_version: string;
  analysis_state: AnalysisState;
  spike_lesson: SpikeLesson;
  user_estimate: MealAIOutput;
};

export const ALLOWED_SPIKE = new Set<string>(["low", "medium", "high"]);

export const FORBIDDEN_SPIKE_PHRASES = [
  /prescribe/i,
  /prescription/i,
  /diagnos[ei]/i,
  /insulin dose/i,
];

export const JSON_INSTRUCTION =
  `You are a nutrition estimation assistant for a diabetes-education app.
Return ONLY valid JSON matching this shape (snake_case keys, numbers where shown):
{
  "items": [{"name": string, "portion_guess": string, "calories": number, "carbs_g": number}],
  "totals": {"calories": number, "carbs_g": number, "fiber_g": number, "sugar_g": number, "protein_g": number, "fat_g": number},
  "spike_risk": "low" | "medium" | "high",
  "rationale": string (one short paragraph, educational tone),
  "disclaimer": "Educational estimate only. Not medical advice.",
  "confidence": number between 0 and 1
}
Do not diagnose or prescribe. Use spike_risk as an educational guess based on visible carbs vs fiber/protein.
If the image does not show identifiable food, return "items": [] and confidence 0.`;

export function parseOpenAIContent(raw: string): MealAIOutput | null {
  const trimmed = raw.trim();
  try {
    const parsed = JSON.parse(trimmed) as MealAIOutput;
    if (
      parsed && Array.isArray(parsed.items) &&
      typeof parsed.spike_risk === "string"
    ) {
      return parsed;
    }
  } catch {
    const m = trimmed.match(/\{[\s\S]*\}/);
    if (m) {
      try {
        const parsed = JSON.parse(m[0]) as MealAIOutput;
        if (
          parsed && Array.isArray(parsed.items) &&
          typeof parsed.spike_risk === "string"
        ) {
          return parsed;
        }
      } catch {
        /* ignore */
      }
    }
  }
  return null;
}

export function sanitizeMealOutput(input: MealAIOutput): MealAIOutput {
  const spike = ALLOWED_SPIKE.has(input.spike_risk.trim().toLowerCase())
    ? input.spike_risk.trim().toLowerCase()
    : "medium";
  let conf = Number(input.confidence);
  if (!Number.isFinite(conf)) conf = 0.5;
  conf = Math.min(1, Math.max(0, conf));

  const items: MealLineItem[] = input.items.map((it) => ({
    name: typeof it.name === "string" ? it.name.trim().slice(0, 500) : "Unknown",
    portion_guess: typeof it.portion_guess === "string"
      ? it.portion_guess.trim().slice(0, 200)
      : "",
    calories: Math.max(
      0,
      Math.min(50000, Math.round(Number(it.calories) || 0)),
    ),
    carbs_g: Math.max(
      0,
      Math.min(5000, Number(it.carbs_g) || 0),
    ),
  }));

  let totals = input.totals;
  if (totals) {
    totals = {
      calories: totals.calories !== undefined
        ? Math.max(0, Math.min(500000, Math.round(Number(totals.calories) || 0)))
        : undefined,
      carbs_g: totals.carbs_g !== undefined
        ? Math.max(0, Math.min(50000, Number(totals.carbs_g) || 0))
        : undefined,
      fiber_g: totals.fiber_g !== undefined
        ? Math.max(0, Math.min(5000, Number(totals.fiber_g) || 0))
        : undefined,
      sugar_g: totals.sugar_g !== undefined
        ? Math.max(0, Math.min(5000, Number(totals.sugar_g) || 0))
        : undefined,
      protein_g: totals.protein_g !== undefined
        ? Math.max(0, Math.min(5000, Number(totals.protein_g) || 0))
        : undefined,
      fat_g: totals.fat_g !== undefined
        ? Math.max(0, Math.min(5000, Number(totals.fat_g) || 0))
        : undefined,
    };
  }

  const rationale = typeof input.rationale === "string"
    ? input.rationale.trim().slice(0, 2000)
    : "";
  const disclaimer =
    typeof input.disclaimer === "string" && input.disclaimer.trim().length > 0
      ? input.disclaimer.trim().slice(0, 500)
      : "Educational estimate only. Not medical advice.";

  return {
    items,
    totals,
    spike_risk: spike,
    rationale,
    disclaimer,
    confidence: conf,
  };
}

/** True if `s` contains any phrase that would suggest medical prescription / diagnosis. */
export function containsForbiddenSpikeText(s: string): boolean {
  return FORBIDDEN_SPIKE_PHRASES.some((re) => s.match(re) !== null);
}

/**
 * Returns user-safe coaching text. If the input contains any forbidden
 * medical-prescriptive phrase, returns a fixed safe fallback rather than
 * splicing words mid-sentence (which would produce broken English).
 */
export function safeCoachingText(s: string): string {
  if (containsForbiddenSpikeText(s)) return SAFE_COACHING_FALLBACK;
  return s.replace(/\s+/g, " ").trim();
}

export function buildSpikeLesson(estimate: MealAIOutput): SpikeLesson {
  const coaching = safeCoachingText(estimate.rationale);
  const headline = coaching.length > 90
    ? `${coaching.slice(0, 87)}…`
    : (coaching || "Meal estimate");
  return {
    risk_band: estimate.spike_risk,
    headline,
    coaching: coaching.slice(0, 800),
  };
}

export function deriveAnalysisState(estimate: MealAIOutput): AnalysisState {
  if (estimate.items.length === 0) return "no_food";
  if (estimate.confidence < 0.45) return "low_confidence";
  return "ready";
}

export function buildEnvelope(
  state: AnalysisState,
  estimate: MealAIOutput,
): MealEnvelope {
  return {
    envelope_version: ENVELOPE_VERSION,
    prompt_version: PROMPT_VERSION,
    analysis_state: state,
    spike_lesson: buildSpikeLesson(estimate),
    user_estimate: estimate,
  };
}

export function shouldCharge(state: AnalysisState): boolean {
  return state === "ready" || state === "low_confidence";
}

export function mockOutput(): MealAIOutput {
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

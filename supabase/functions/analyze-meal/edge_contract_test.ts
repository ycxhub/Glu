/**
 * Contract tests for the analyze-meal edge function. These import production
 * code from `./lib.ts` so changing the implementation surfaces here.
 *
 * Run: `cd supabase/functions/analyze-meal && deno test edge_contract_test.ts`
 */
import {
  assertEquals,
  assertFalse,
  assertNotEquals,
  assertStringIncludes,
} from "jsr:@std/assert@1";
import {
  buildEnvelope,
  buildSpikeLesson,
  containsForbiddenSpikeText,
  deriveAnalysisState,
  ENVELOPE_VERSION,
  parseOpenAIContent,
  PROMPT_VERSION,
  safeCoachingText,
  SAFE_COACHING_FALLBACK,
  sanitizeMealOutput,
  shouldCharge,
} from "./lib.ts";

Deno.test("containsForbiddenSpikeText flags prescription wording", () => {
  assertEquals(
    containsForbiddenSpikeText("We prescribe changes to your insulin dose."),
    true,
  );
});

Deno.test("containsForbiddenSpikeText flags diagnosis wording", () => {
  assertEquals(
    containsForbiddenSpikeText("This image diagnoses diabetes progression."),
    true,
  );
});

Deno.test("containsForbiddenSpikeText leaves benign rationale alone", () => {
  assertFalse(
    containsForbiddenSpikeText(
      "Refined carbs with limited fiber tend to spike faster.",
    ),
  );
});

Deno.test("safeCoachingText replaces forbidden text with safe fallback (no broken sentences)", () => {
  const bad = "We prescribe changes to your insulin dose.";
  const out = safeCoachingText(bad);
  assertEquals(out, SAFE_COACHING_FALLBACK);
  // Must NOT leak any forbidden keyword back to the user.
  assertFalse(/prescribe|insulin dose|diagnos[ei]/i.test(out));
  // Must NOT produce the broken-sentence output the old splice approach made.
  assertNotEquals(out, "We changes to your .");
});

Deno.test("safeCoachingText preserves benign coaching verbatim (modulo whitespace collapse)", () => {
  const ok = "Big bowl of rice with light fiber — likely faster spike risk.";
  assertEquals(safeCoachingText(ok), ok);
});

Deno.test("buildSpikeLesson uses safe fallback when rationale contains forbidden text", () => {
  const lesson = buildSpikeLesson({
    items: [],
    spike_risk: "high",
    rationale: "We prescribe insulin dose changes after this.",
    disclaimer: "Educational estimate only. Not medical advice.",
    confidence: 0.7,
  });
  assertEquals(lesson.coaching, SAFE_COACHING_FALLBACK);
  assertStringIncludes(lesson.headline, "Educational estimate only");
});

Deno.test("buildSpikeLesson preserves rationale and truncates headline at 90 chars", () => {
  const long =
    "This plate has rice and bread with no visible fiber, so the carb load is meaningfully higher than a balanced meal.";
  const lesson = buildSpikeLesson({
    items: [],
    spike_risk: "medium",
    rationale: long,
    disclaimer: "Educational estimate only. Not medical advice.",
    confidence: 0.6,
  });
  assertEquals(lesson.coaching, long);
  // Headline is truncated to 87 chars + ellipsis when source > 90.
  assertEquals(lesson.headline.length <= 90, true);
  assertStringIncludes(lesson.headline, "…");
});

Deno.test("deriveAnalysisState classifies empty items as no_food", () => {
  assertEquals(
    deriveAnalysisState({
      items: [],
      spike_risk: "medium",
      rationale: "r",
      disclaimer: "d",
      confidence: 0.9,
    }),
    "no_food",
  );
});

Deno.test("deriveAnalysisState classifies low confidence", () => {
  assertEquals(
    deriveAnalysisState({
      items: [{ name: "x", portion_guess: "1", calories: 1, carbs_g: 1 }],
      spike_risk: "medium",
      rationale: "r",
      disclaimer: "d",
      confidence: 0.3,
    }),
    "low_confidence",
  );
});

Deno.test("deriveAnalysisState classifies ready", () => {
  assertEquals(
    deriveAnalysisState({
      items: [{ name: "x", portion_guess: "1", calories: 1, carbs_g: 1 }],
      spike_risk: "medium",
      rationale: "r",
      disclaimer: "d",
      confidence: 0.8,
    }),
    "ready",
  );
});

Deno.test("shouldCharge: only ready and low_confidence are billable", () => {
  assertEquals(shouldCharge("ready"), true);
  assertEquals(shouldCharge("low_confidence"), true);
  assertEquals(shouldCharge("no_food"), false);
  assertEquals(shouldCharge("analysis_failed"), false);
});

Deno.test("sanitizeMealOutput clamps confidence into [0,1] and falls back on NaN", () => {
  const out = sanitizeMealOutput({
    items: [],
    spike_risk: "medium",
    rationale: "r",
    disclaimer: "d",
    confidence: 5,
  });
  assertEquals(out.confidence, 1);

  const nanOut = sanitizeMealOutput({
    items: [],
    spike_risk: "medium",
    rationale: "r",
    disclaimer: "d",
    // deno-lint-ignore no-explicit-any
    confidence: "not-a-number" as any,
  });
  assertEquals(nanOut.confidence, 0.5);
});

Deno.test("sanitizeMealOutput coerces invalid spike_risk to medium", () => {
  const out = sanitizeMealOutput({
    items: [],
    spike_risk: "EXTREME",
    rationale: "r",
    disclaimer: "d",
    confidence: 0.5,
  });
  assertEquals(out.spike_risk, "medium");
});

Deno.test("parseOpenAIContent extracts JSON from prose-wrapped responses", () => {
  const wrapped = 'Here is the JSON: {"items":[],"spike_risk":"low","rationale":"r","disclaimer":"d","confidence":0.5}';
  const parsed = parseOpenAIContent(wrapped);
  assertNotEquals(parsed, null);
  assertEquals(parsed?.spike_risk, "low");
});

Deno.test("parseOpenAIContent returns null on non-JSON garbage", () => {
  assertEquals(parseOpenAIContent("totally not json"), null);
});

Deno.test("buildEnvelope stamps version and prompt", () => {
  const env = buildEnvelope("ready", {
    items: [{ name: "x", portion_guess: "1", calories: 1, carbs_g: 1 }],
    spike_risk: "medium",
    rationale: "Light carb load with visible fiber.",
    disclaimer: "Educational estimate only. Not medical advice.",
    confidence: 0.7,
  });
  assertEquals(env.envelope_version, ENVELOPE_VERSION);
  assertEquals(env.prompt_version, PROMPT_VERSION);
  assertEquals(env.analysis_state, "ready");
  assertEquals(env.user_estimate.spike_risk, "medium");
});

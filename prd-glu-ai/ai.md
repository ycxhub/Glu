# AI Models — Glu AI

## Capabilities matrix

| Capability | Model (initial) | Provider | Cost / call (order-of-magnitude) | Target latency | Critical? |
|---|---|---|---|---|---|
| Meal photo → structured estimate | GPT-4o (multimodal) or equivalent | OpenAI via Edge proxy | ~$0.02–$0.06 per image analysis | p50 < 6s, p95 < 15s | Yes |
| Output sanity / policy wrap | Same call or lightweight text pass | OpenAI | folded into above | +0–1s | Yes |
| Weekly summary (V1.1+) | Claude 3.5 Haiku or GPT-4o-mini | Anthropic or OpenAI | <$0.005 per summary | async OK | No |

**Important:** Costs fluctuate with model list pricing and image resolution. Recompute monthly from provider dashboards. All calls **server-side only** through Supabase Edge Functions.

## Per-capability detail

### Capability 1: Meal photo → calories, macros, spike risk

**Model:** `gpt-4o` or newer OpenAI multimodal snapshot pinned in server config (e.g., `gpt-4o-2024-11-20` successor as updated). **Fallback:** second provider (e.g., Gemini Flash via separate secret) only if OpenAI errors — same JSON schema.

**Why this model:** Strong multimodal food understanding, JSON mode / structured outputs, reasonable latency tradeoff versus smaller models that hallucinate portions on mixed plates.

**Prompt structure (conceptual — live prompts in repo `supabase/functions/_shared/prompts/`):**

```
System: You are a nutrition estimation assistant for a consumer wellness app for adults thinking about diabetes and carbs.
You are NOT a medical professional. Never diagnose. Never prescribe insulin or medication changes.
Always return STRICT JSON matching the schema. Use ranges where uncertainty is high.
Label spike_risk as low | medium | high based on estimated total carbs, likely added sugars, fiber, and simple portion heuristics — this is an EDUCATIONAL label, not a blood glucose prediction.
Include a short user-facing rationale (max 3 sentences) and a machine confidence 0–1.

User: [high-level meal context flags from profile if any] + image
```

**Expected output JSON (v1 schema):**

```json
{
  "schema_version": 1,
  "items": [
    {
      "name": "string",
      "portion_guess": "string",
      "calories": 0,
      "carbs_g": 0,
      "fiber_g": 0,
      "sugar_g": 0,
      "protein_g": 0,
      "fat_g": 0,
      "confidence": 0.0
    }
  ],
  "totals": {
    "calories": 0,
    "carbs_g": 0,
    "fiber_g": 0,
    "sugar_g": 0,
    "protein_g": 0,
    "fat_g": 0
  },
  "spike_risk": "low | medium | high",
  "rationale": "string",
  "confidence": 0.0,
  "disclaimer": "Educational estimate only. Not medical advice. Confirm with your clinician or meter as appropriate."
}
```

**Cost model:** Dominated by image tokens + ~300–600 output tokens. At ~$0.03 average, 800 paying users × 3 meals/day ≈ $72/day ≈ $2,160/month — **must** be monitored against ARPU.

**Latency:** Show progress states at 3s and 6s thresholds; server timeout before client hard fails.

**Fallback:** Retry once on 5xx / timeout; then user message: “We couldn’t analyze this photo — try brighter light or a simpler angle.” Offer “Save photo only” for later retry (optional V1.1).

**Caching:** SHA-256 of downscaled image bytes + model id; 24h TTL cache table to collapse duplicate submits.

### Capability 2: Weekly summary (optional V1.1)

**Model:** `claude-3-5-haiku-latest` or `gpt-4o-mini` for cheap aggregation of user’s saved meals JSON aggregates only (no new vision).

**Why:** Narrative habit feedback without re-sending photos.

## Provider strategy

| Provider | Use for | Notes |
|---|---|---|
| OpenAI | Primary vision + JSON | Pin versions; log `model` field per response |
| Google Gemini | Optional fallback | Cost leader; unify schema in proxy |
| Anthropic | Text-only coaching later | Good for conservative tone |

**Abstraction:** Edge Function `analyze-meal` selects provider via env flag; app only knows `POST /functions/v1/analyze-meal`.

## Cost projection (illustrative)

**Assumptions:** 10K MAU, 8% trial/paid path similar to archetype docs, active subscribers average **2** new meal analyses / day (conservative if habit sticks).

- 800 subscribers × 2 calls/day × $0.03 ≈ $48/day → **~$1,440/month** vision only
- Compare to ~$4K MRR if ARPU ~$5 net — **margin OK if** conversion holds and cache hits ~15–25%

If inference >30% of net ARPU: reduce image resolution, shorten output schema, move fallback traffic to Flash-class model, tighten per-day caps with transparent in-app messaging.

## Latency strategy

| Pattern | Use |
|---|---|
| Skeleton + rotating status | Vision path |
| No token streaming to client V1 | Simplifies parsing |
| Background weekly job | summaries |

## Reliability & fallback

| Failure | Action |
|---|---|
| 5xx / timeout | Retry once; then friendly error |
| JSON parse error | Server-side repair attempt with “return valid JSON only” once |
| Low confidence (<0.45) | Downgrade UI: widen numeric ranges; prepend “Rough estimate” chip |
| Moderation flag on image | Block with generic message |

## Safety & content moderation

- Run provider moderation or vision safety classifiers where available.
- Reject disallowed imagery without describing why in user-facing copy.
- Never generate insulin dosing or medication change instructions — regex guard on server; reject and log if violated.

## Quality monitoring

- Dashboards: success %, p50/p95 latency, $/successful call, user thumbs-down rate on meals.
- Log `prompt_version` + `model` on each row (in `ai_output` metadata object).

## Prompts as code

- Version prompts in git; tag releases with prompt semver.
- Golden-set of ~30 labeled plates for regression when changing models.

## Open questions

1. When to add **on-device barcode** for packaged foods to reduce vision tokens.
2. Whether to allow **user correction** UI to feed a lightweight fine-tuning dataset (privacy + consent gate).
3. EU data residency requirement for model provider routing.

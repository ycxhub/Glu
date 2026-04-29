# AI Models — [App Name]

> GUIDANCE: This file documents every AI capability in the app: which model, what it does, what it costs per call, what the latency is, and what happens when it fails. Cal AI–archetype apps live and die by inference cost — a 5× cost overrun on inference can kill margin. If your app has no AI, write "N/A — this app does not use AI" and skip the file.

## Capabilities matrix

| Capability | Model | Provider | Cost / call | Target latency | Critical? |
|---|---|---|---|---|---|
| [e.g., Food recognition from photo] | [GPT-4o / Claude 3.5 Sonnet / Gemini 2.5 Flash] | [OpenAI / Anthropic / Google] | [$0.01] | [< 3s] | Yes (core) |
| [e.g., Voice journaling transcription] | [Whisper / Deepgram] | [OpenAI / Deepgram] | [$0.006/min] | [< 2s] | No (optional) |
| [e.g., Goal coaching chat] | [Claude 3.5 Haiku] | [Anthropic] | [$0.003] | [< 4s] | No |
| [e.g., Weekly summary generation] | [Claude 3.5 Sonnet] | [Anthropic] | [$0.015] | [Async, < 30s] | No |

## Per-capability detail

### Capability 1: [Core action — e.g., Photo → calorie estimate]

**Model:** [Specific model name + version, e.g., `gpt-4o-2024-11-20`]

**Why this model:** [Reasoning — accuracy benchmarks, multimodal support, cost, latency. Specific to this use case.]

**Prompt structure:**
```
System: [System prompt — defines role, output format, constraints]

User: [What the app sends — image + structured prompt]
```

**Expected output:** [Structured JSON schema — define the exact shape so the iOS client can decode it deterministically]
```json
{
  "items": [
    { "name": "string", "quantity": "string", "calories": "number", "confidence": "number" }
  ],
  "total_calories": "number",
  "warnings": ["string"]
}
```

**Cost model:** [Per-call breakdown. Image input + output tokens. Estimate at ~$0.01/call for GPT-4o vision; verify with current pricing.]

**Latency target:** [< 3 seconds end-to-end. If above, user perceives the app as broken.]

**Fallback:** [What if the model returns garbage or 5xx? Default fallback: retry once, then show "Couldn't analyze, try again" with a manual entry option. Never crash.]

**Caching:** [Cache outputs by image content hash. ~30% of meals are repeats (oatmeal, salads). Saves real money at scale.]

### Capability 2: [Next AI feature]

[Same structure as above]

## Provider strategy

| Provider | Use for | Notes |
|---|---|---|
| **OpenAI** | Vision, general LLM | GPT-4o is the workhorse for vision tasks. Strong ecosystem, best tooling. |
| **Anthropic (Claude)** | Long-context, nuanced reasoning, safety-sensitive output | Claude 3.5 Sonnet for quality; Haiku for cheap chat. Best for content moderation. |
| **Google (Gemini)** | Cheap inference at scale, video understanding | Gemini 2.5 Flash is the cost leader; Flash-Lite even cheaper. Good fallback. |
| **Replicate / Fal** | Image / video generation, voice cloning, custom models | Use for diffusion models (SDXL, Flux), voice clones, video gen. Pay per call. |
| **OpenAI Whisper** (or Deepgram) | Voice transcription | Whisper API is good and cheap; Deepgram has lower latency for streaming. |

**Multi-provider abstraction:** All AI calls go through a server-side proxy (`/api/ai/[capability]`) that can swap providers without an app update. This is critical for:
- Provider-side outages (rotate to fallback in seconds)
- Cost optimization (move workloads to cheaper provider as pricing changes)
- A/B testing model quality

## Cost projection

> GUIDANCE: Compute expected inference cost at 10K MAU and 100K MAU. If your unit economics don't work at 10K MAU, the app dies. Be honest.

### Assumptions
- 10K MAU
- Average user does [N] AI calls per day
- Premium-only access (so AI cost is bounded by paying users)

### Math
- 10K users × 8% paying = 800 paying users
- 800 paying users × [N] calls/day × $[X]/call = $[Y]/day
- Monthly: $[Y × 30]
- Per paying user: $[monthly cost / 800] (compare to $[ARPU])

If inference cost > 30% of ARPU, you have a margin problem. Solutions:
- Cache aggressively
- Move to cheaper model (Gemini Flash, Haiku)
- Rate limit by tier (Premium = 50/day, Pro = unlimited)
- Pre-process on device (e.g., crop photo to subject before sending to vision model)

## Latency strategy

| Pattern | Use when | Implementation |
|---|---|---|
| **Streaming (SSE)** | LLM text generation, chat | Show tokens as they arrive; perceived latency drops to ~500ms |
| **Optimistic UI** | Confidence-bounded outputs | Show predicted result immediately, refine when AI returns |
| **Skeleton + spinner** | Image / video gen (5–60s) | Show progress, status text, estimated time |
| **Background queue** | Async tasks (weekly summaries) | Schedule on-device, run server-side, push notification when done |
| **On-device** | Latency-critical, privacy-sensitive | Apple Intelligence (iOS 18.1+) for simple text tasks; Core ML for image classification |

**On-device prompt:** Apple Intelligence (Foundation Models framework, iOS 18.1+) gives you a ~3B parameter model for free, runs offline. Worth using for:
- Tone / classification of user-typed text
- Local summarization (no PII leaves device)
- Simple Q&A on personal data

Don't expect frontier-quality output — but it's free and instant.

## Reliability & fallback

Every AI call must have a defined failure mode. The Cal AI archetype can't show users a stack trace.

| Failure | Detection | Fallback |
|---|---|---|
| Provider 5xx | HTTP status | Retry once with exponential backoff (1s) |
| Provider 5xx persistent | 2 retries failed | Switch to fallback provider for this call |
| Both providers down | Both fail | Cache last-good response if applicable; otherwise show "We're having trouble. Try again in a moment." |
| Slow response (> 8s) | Timeout | Show "Taking longer than usual..." after 4s; cancel + retry at 8s |
| Garbled JSON | Parse failure | Retry with stricter prompt; if 2nd retry fails, show "Couldn't read this image, try again with better lighting" |
| Hallucinated values | Confidence score < threshold | If structured output includes confidence, hide low-confidence rows or surface with warning icon |
| Inappropriate content | Moderation API flags | Block, log, show "We can't process this image" — don't explain why |

## Safety & content moderation

> GUIDANCE: Required if your app accepts user-generated content (photos, voice, text). App Store will reject apps without basic moderation.

- **Photos:** Run through OpenAI moderation endpoint (free) or Cloud Vision SafeSearch before AI inference
- **Text inputs:** Same — moderation pass first
- **Output filtering:** If using LLMs for user-facing content, post-filter outputs for prohibited content (Apple won't approve apps that can output adult content even via LLM)
- **User reporting:** In-app "Report" button on AI-generated content; queue for human review

## Quality monitoring

Set up dashboards for:
- **Per-capability success rate** (AI returned valid, parseable output)
- **Per-capability latency p50, p95, p99**
- **Per-capability cost per call (rolling 7-day average)**
- **User-reported "wrong answer" rate** (in-app feedback)

When success rate < 95% or p95 latency > 2× target, alert on-call.

## Prompts as code

> GUIDANCE: Prompts are software. Version-control them, test them, monitor them.

- Store all prompts in `/backend/prompts/[capability].md` — not embedded in code
- Use a prompt eval framework (Promptfoo, LangSmith, Langfuse) to run regression tests on every prompt change
- Tag every AI response with the prompt version + model version in your analytics for triage when quality regresses

## Open questions

1. [e.g., "Should we fine-tune a smaller model for our specific use case once we have data, or stay with frontier models?"]
2. [e.g., "Apple Intelligence vs. server-side for the privacy-sensitive voice journaling capability?"]
3. [e.g., "How do we handle image inputs that aren't of [expected subject]? Reject? Run anyway and let confidence score handle it?"]

# About — Glu AI

## Elevator pitch

Glu AI is the meal companion for adults managing diabetes who want photo-based logging and spike-aware guidance without heavy manual entry — snap a meal, get rough calories and macros plus a clear spike-risk signal and short rationale, then build habits over time with education and history (informational only; not a medical device).

## The problem

Manual food logging for diabetes is slow: weighing, searching databases, and guessing portions often takes several minutes per meal, so people stop within weeks. Photo-first tools that only count calories miss what people with diabetes actually worry about — how a meal might affect glucose — while clinical apps can feel clinical and overwhelming. There is room for a consumer iOS experience that combines a fast photo workflow with carb-, fiber-, and sugar-aware **education-oriented** signals, without claiming to diagnose or treat.

## The solution

Glu AI uses the phone camera as the primary input. After capture, a **server-side AI proxy** (no provider keys in the app) estimates calories and macronutrients (rough ranges), identifies visible foods where possible, and returns a **spike-risk label** (low / medium / high) with a short, plain-language rationale tied to estimated carbs, fiber, added sugars, and portion cues. Users save meals to a timeline, see trends, and get bite-sized education on patterns that tend to support steadier self-reported energy — all framed as wellness information with clear disclaimers, not medical advice.

## Who is this for

**Primary user:** Adults 25–55 with type 1, type 2, or prediabetes who already think about carbs at least some of the time, have tried generic calorie apps or paper logs, and want faster logging plus habit-friendly nudges. They are comfortable using AI-assisted estimates as a **starting point** for their own judgment and care team conversations.

**Secondary user:** Recently diagnosed adults who want a gentler on-ramp to meal awareness and logging before committing to heavier tools.

**Not for:** Children without caregiver oversight; anyone seeking a substitute for professional medical care, insulin dosing, or CGM-driven decisions; or users who need regulated clinical decision support. The app does not replace meters, pumps, or clinicians.

## What makes us different

1. **Photo-first diabetes-aware loop** — One capture drives calories, rough macros, and a spike-risk signal with rationale, reducing taps versus traditional diabetes diaries.
2. **Spike-risk framing without diagnosis** — Outputs are educational labels and explanations, not prescriptions or glucose predictions, aligned with App Store-safe positioning.
3. **Long Cal AI–style onboarding** — Collects diabetes type, goals, carb awareness, and optional context the user chooses to share, then delivers a personalized plan reveal before auth and a hard paywall, maximizing commitment and clarity of value.
4. **Habit + education layer** — History, streaks, and short tips connect repeated logs to patterns (e.g., fiber-forward swaps), not one-off scans only.
5. **Premium-only AI** — Inference runs only for subscribers after the hard paywall, protecting unit economics and aligning cost with revenue.

## Why now

Multimodal frontier models made **reasonable** food-and-plate understanding cheap enough for consumer subscription apps, while Apple’s camera stack and SwiftUI make polished capture flows the default. Culturally, more people are managing glucose with apps and wearables and expect **instant** feedback — but they still hate typing. Glu AI sits at that intersection: fast vision + structured, disclaimer-forward outputs + subscription-backed infrastructure.

## Vision

If Glu AI works, logging a meal feels as light as taking a photo, and users build a personal archive of meals with **actionable context** they can discuss with their care team — without the app pretending to be their doctor.

## Success metrics (V1)

| Metric | Target | Why it matters |
|---|---|---|
| Onboarding completion rate | ≥ 60% | Funnel health before paywall |
| Paywall conversion (trial start) | ≥ 8% | Revenue gate for hard-paywall archetype |
| Trial-to-paid conversion | ≥ 50% | Validates pricing and product stickiness |
| Day 7 retention (paid) | ≥ 40% | Predicts LTV and habit formation |
| App Store rating | ≥ 4.5 stars | ASO and trust for a health-adjacent app |

## Distribution hypothesis

**Primary channel:** TikTok and Instagram short-form — before/after style “photo → breakdown + spike risk in seconds” clips, creator scripts emphasizing **informational** use and “ask your clinician.” Cal AI–style proof loops convert in feed.

**Secondary channel:** Apple Search Ads on high-intent keywords (diabetes food log, carb tracker, meal photo) plus diabetes creator whitelists.

**Viral mechanism:** Optional share of anonymized “meal card” graphic (photo + summary) to stories; refer-a-friend after month 2 if data supports it.

## Risks & open questions

1. **Medical / regulatory perception** — Mitigation: strict copy discipline (no treatment claims), prominent disclaimers, no insulin dosing UI, legal review of onboarding and paywall strings.
2. **AI accuracy on mixed plates and hidden ingredients** — Mitigation: confidence cues, user edit of items, education that estimates are rough; fallback messaging on low confidence.
3. **Unit economics on vision calls** — Mitigation: server-side proxy, caching by image hash, rate limits per plan, model tier monitoring in `ai.md` / architecture.

---
name: mobile-app-prd
description: Generate a complete 9-file Product Requirements Document for a simple consumer iOS app from a one-paragraph description. Produces opinionated, Cal AI–inspired specs (pitch, design system, App Store, architecture, onboarding, paywall, AI, app screens, OAuth) using templates in templates/prd/ and Cal AI references in references/cal-ai/. Triggers on mobile app ideas, “spec/PRD/scope/requirements” for a consumer iOS app, or Cal AI / viral subscription–app style builds.
---

# Mobile App PRD Generator

Take a short description of a consumer mobile app and produce a complete **9-file** PRD at repo root: `prd-{app-name-slug}/`, ready to hand to a build step or [oneshot-ios-implement](./oneshot-ios-implement/SKILL.md). The PRD is opinionated toward the **Cal AI archetype**: iOS-first, often AI-powered, with quiz-style onboarding and a hard subscription paywall.

## When to use

- “I want to build an app that [does X]” — generate a full PRD
- “PRD / spec / scope this idea: [description]”
- “Cal AI–style app for [domain]”
- User describes a consumer iOS app; trigger even if they do not say “PRD”

If the user is only brainstorming (no app concept), help them clarify first, then run this skill.

## Workflow

### Step 1: Extract from the user’s description

- **App name** (or propose 2–3 options)
- **Core action** (the one thing the user does — e.g. photo of meal, scan, generate)
- **Target user** (specific, not “everyone”)
- **Why now** (AI / platform / moment)
- **Monetization** (default: hard paywall after onboarding; freemium only if stated)

Ask 1–2 questions if needed. **Do not** output placeholder PRDs full of `[FILL IN]`.

### Step 2: Read templates and write `prd-<slug>/`

1. For each of the nine scaffolds below, read the template from **[`templates/prd/`](../../../templates/prd/)** at the repository root (not only `files/`; those may be legacy copies).
2. For **onboarding** and **paywall**, also read the Cal AI deconstructions (required):
   - [`references/cal-ai/cal-ai-onboarding-deconstruction.md`](../../../references/cal-ai/cal-ai-onboarding-deconstruction.md)
   - [`references/cal-ai/cal-ai-paywall-deconstruction.md`](../../../references/cal-ai/cal-ai-paywall-deconstruction.md)
3. Write filled outputs to **`prd-<app-name-slug>/`** at the **repository root** (e.g. `prd-meal-snap/about.md`).

| # | File | Source template |
|---|------|-----------------|
| 1 | about.md | templates/prd/about.md |
| 2 | design.md | templates/prd/design.md |
| 3 | appstore.md | templates/prd/appstore.md |
| 4 | architecture.md | templates/prd/architecture.md |
| 5 | onboarding.md | templates/prd/onboarding.md |
| 6 | paywall.md | templates/prd/paywall.md |
| 7 | ai.md | templates/prd/ai.md |
| 8 | app.md | templates/prd/app.md |
| 9 | auth.md | templates/prd/auth.md |

Target **80–250 lines** per file where applicable; **no GUIDANCE** blockquotes in the final output (see below).

### Step 3: Opinionated defaults (Cal AI archetype)

| Decision | Default |
|----------|---------|
| Platform | iOS (SwiftUI); Android later |
| Auth | Apple + Google; magic link fallback |
| Backend | Supabase |
| Subscriptions | RevenueCat |
| Paywall A/B | Superwall |
| Analytics | Mixpanel + RC events; PostHog optional |
| Crash | Sentry |
| Push | OneSignal or APNs |
| Onboarding | 18–25 screens (~22) |
| Paywall | Hard after onboarding |
| Pricing | Annual default ~$49.99–$79.99/yr; monthly ~$9.99–$14.99/mo; 3-day trial typical |

Override when the app clearly differs (B2B, Android-first, no AI) and state why in the relevant file.

### Step 4: N/A sections

If there is no AI, set `ai.md` to a short `N/A —` explanation. **Do not** invent models or costs.

### Step 5: Consistency pass

- `app.md` ↔ `architecture.md` (features and stack)
- `ai.md` ↔ `architecture.md` (costs and providers)
- `auth.md` ↔ `architecture.md` (OAuth and deletion)
- Onboarding answers in `onboarding.md` map to data in `app.md` / DB sketch in `architecture.md`

## How to fill templates

1. Open each file from **`templates/prd/<name>.md`**
2. Use `> GUIDANCE:` only as **your** instructions; **remove** all `> GUIDANCE:` lines from the **delivered** `prd-*/` files
3. Replace `[BRACKETS]` with real content; **keep** headings/section structure
4. **Never** generate onboarding or paywall without reading the two **references/cal-ai/** deconstruction files first

## Output

- **Path:** `prd-<kebab-app-name>/` at repository root
- **Entry point:** present `about.md` first, then the rest
- **Next step:** [oneshot-ios-implement](../oneshot-ios-implement/SKILL.md) to materialize a SwiftUI app from `prd-*/` + [`templates/ios-oneshot/`](../../../templates/ios-oneshot/)

## Philosophy

Compress “what to build” into a **one-shot artifact** so execution can stack Cal AI–style levers (onboarding length, hard paywall, OAuth, minimal native UI) without re-deriving them unless the user diverges on purpose.

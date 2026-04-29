---
name: mobile-app-prd
description: Generate a complete 8-file Product Requirements Document for a simple consumer mobile app from a one-paragraph description. Produces opinionated, Cal AI-inspired specs covering pitch, design system, App Store assets, technical architecture, conversion-optimized onboarding, conversion-optimized paywall, AI model choices, app screens, and OAuth. Use this skill whenever the user describes a mobile app idea they want to build, asks to "spec out" / "PRD" / "scope" / "write requirements for" a mobile app, mentions building a consumer iOS app, or wants documentation for an app inspired by Cal AI, Lapse, BeReal, Fasty, Umax, RealShort, AllTrails, Calm, or similar viral consumer mobile apps. Trigger this proactively when the user describes a mobile app idea — even if they don't say the word "PRD" — so they get a real spec instead of a brainstorm.
---

# Mobile App PRD Generator

Take a short description of a consumer mobile app and produce a complete 8-file PRD that's ready to hand to a small team to build. The PRDs are opinionated toward the **Cal AI archetype**: iOS-first, AI-powered, viral consumer app with quiz-style onboarding and a hard subscription paywall.

## When to use this skill

Trigger when the user wants to scope or specify a consumer mobile app. Examples:

- "I want to build an app that [does X]" — generate a full PRD
- "Help me PRD this idea: [description]"
- "Write the spec for a Cal AI–style app for [domain]"
- "Scope out an app that [description]"

If the user is just brainstorming (no clear app concept yet), do not run the skill — help them clarify the concept first, then run the skill once they're committed.

## Workflow

### Step 1: Read the user's description and extract the core fields

From the user's description, extract:

- **App name** (if given; otherwise propose 2–3 options and ask)
- **Core action** (the one thing the user does in the app — "take photo of meal", "generate a roast video", "scan face for skincare advice")
- **Target user** (who this is for — be specific, not "everyone")
- **Why now** (what AI model unlock or cultural moment makes this possible/timely)
- **Monetization** (default: hard paywall after onboarding; freemium only if explicitly stated)

If any of these aren't clear from the description, ask 1–2 sharp questions to nail them down before generating files. Do not generate placeholder PRDs with `[FILL IN]` — that defeats the purpose.

### Step 2: Generate all 9 files

Read the templates in **[`templates/prd/`](../templates/prd/)** and produce one filled-in version of each, written to `prd-{app-name-slug}/` in the **repository root**. The 9 files are:

1. **about.md** — Elevator pitch, target user, problem, solution, differentiation, why now, vision
2. **design.md** — Design system: colors, typography, spacing, components, motion, dark mode, iconography
3. **appstore.md** — All assets and copy needed for App Store submission (icon, screenshots, ASO, privacy)
4. **architecture.md** — Tech stack, data flow, services, infrastructure, costs at scale
5. **onboarding.md** — Conversion-optimized onboarding flow, screen-by-screen, modeled on Cal AI
6. **paywall.md** — Conversion-optimized paywall, modeled on Cal AI's hard paywall
7. **ai.md** — LLMs, vision/image, voice, video models in use — with cost, latency, fallback strategy
8. **app.md** — Main app screens after onboarding (the actual product)
9. **auth.md** — OAuth providers, flows, edge cases, account deletion (App Store requirement)

**References (required for onboarding + paywall):** [`../references/cal-ai/cal-ai-onboarding-deconstruction.md`](../references/cal-ai/cal-ai-onboarding-deconstruction.md), [`../references/cal-ai/cal-ai-paywall-deconstruction.md`](../references/cal-ai/cal-ai-paywall-deconstruction.md)

Each file should be 80–250 lines. Substantive, not bloated. **The deployed skill** is at [`.cursor/skills/mobile-app-prd/SKILL.md`](../.cursor/skills/mobile-app-prd/SKILL.md); prefer that path for correct links.

### Step 3: Apply opinionated defaults — don't ask the user to decide everything

For consumer iOS apps in the Cal AI archetype, these defaults are nearly always correct. Apply them unless the user's description explicitly says otherwise:

| Decision | Default |
|---|---|
| Platform | iOS native (SwiftUI) — Android comes later |
| Auth | Apple Sign In + Google Sign In; email magic link as fallback |
| Backend | Supabase (Postgres + Auth + Storage) |
| Subscriptions | RevenueCat (industry standard for iOS) |
| Paywall A/B testing | Superwall |
| Analytics | Mixpanel + RevenueCat events; PostHog for product analytics |
| Crash reporting | Sentry |
| Push notifications | OneSignal or APNs direct |
| Onboarding length | 18–25 screens (Cal AI uses ~22) |
| Paywall placement | Hard paywall after onboarding, before any value delivered |
| Pricing | Annual default ($49.99–$79.99/yr), monthly ($9.99–$14.99/mo), 3-day free trial |
| App Store category | Health & Fitness / Lifestyle / Photo & Video / Productivity (depending on domain) |

If any of these conflict with the app's reality (e.g., it's a B2B app, or the user said "Android first"), override and explain why in `architecture.md`.

### Step 4: Be ruthless about sections that don't apply

If the app genuinely doesn't need a section (e.g., no AI involved → `ai.md`), write "N/A — [one-sentence reason]" instead of fabricating content. Do not pad. The user will notice fluff and lose trust in the skill.

### Step 5: Cross-reference between files

The files should be consistent with each other:
- The screens listed in `app.md` should match what the architecture supports
- The AI models in `ai.md` should match the cost assumptions in `architecture.md`
- The OAuth providers in `auth.md` should match what's set up in `architecture.md`
- The onboarding personalization questions should map to data the app actually uses

After writing all files, do a quick consistency pass. Inconsistencies = bad PRD.

## How to fill the templates

The templates in **`templates/prd/`** are **scaffolds with section structure and inline guidance**. To use one:

1. Read the template
2. Read the inline `> GUIDANCE:` blockquotes — they tell you how to fill that section
3. Replace placeholder text (in `[BRACKETS]`) with concrete content drawn from the user's app description
4. Keep the section structure and headings unchanged
5. Strip the `> GUIDANCE:` blockquotes from the final output (they're directions for you, not the user)

For onboarding and paywall specifically, also read:
- `references/cal-ai/cal-ai-onboarding-deconstruction.md` — screen-by-screen breakdown of why each screen exists
- `references/cal-ai/cal-ai-paywall-deconstruction.md` — anatomy of the Cal AI paywall

These are the "secret sauce" of the skill. Don't generate onboarding or paywall docs without reading these references first.

## Output format

Save all files to `prd-{app-name-slug}/`, where the slug is the app name lowercased and hyphenated. Example: `prd-meal-snap/about.md`, `prd-meal-snap/design.md`, etc.

If running in an environment with `present_files`, present all 8 files so the user can review them. The `about.md` should be presented first as the entry point.

## A note on the philosophy

The point of this skill is to **compress the "what should I build" decisions into a one-shot artifact** that a small team can act on. The Cal AI archetype works because every component (onboarding length, paywall hardness, OAuth choices, design minimalism) is independently optimized and stacked. Don't second-guess the archetype unless the user explicitly diverges from it. If they say "I want a Cal AI for skin", just do the Cal AI playbook adapted for skin. Most "simple" mobile apps are won on execution, not novelty.

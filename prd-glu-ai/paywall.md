# Paywall — Glu AI

## Paywall philosophy

1. **Hard paywall** — After onboarding + auth, users cannot run meal analysis or access full meal history without an active trial or subscription. This protects inference cost and matches Cal AI–style monetization.
2. **Annual default** — Pre-select annual; monthly is visible but visually secondary.
3. **Trial-forward copy** — Lead with “Start your 3-day free trial”; price stays clear in tier cards and fine print (App Store rule 3.1.2).
4. **Per-day framing on annual** — Show cents-per-day under annual price.
5. **Superwall from day one** — One shipped layout; remote variants for headlines and hero without resubmitting static screenshots where policy allows.

**Medical-framing guardrails:** Headlines promise **habits and clarity**, not glucose outcomes. Avoid “control your A1c” claims. Use “Understand meals faster” / “Build a logging habit you’ll keep.”

## Screen anatomy (top to bottom)

```
┌─────────────────────────────────────┐
│  Hero: animated meal scan motif     │
│  (photo → abstract breakdown wave) │
│                                     │
│  Understand meals in seconds        │
│  AI-assisted estimates + spike risk  │
│  Educational only — not medical care │
│                                     │
│  ★★★★★ 4.8 · early ratings          │
│  “Logging finally feels doable.”    │
│                                     │
│  ┌─ ANNUAL ─────── BEST VALUE ──┐   │
│  │ $59.99/year                  │   │
│  │ ~$0.16/day · Save vs monthly │   │
│  └──────────────────────────────┘   │
│  ┌─ Monthly ────────────────────┐  │
│  │ $12.99/month                 │  │
│  └──────────────────────────────┘  │
│                                     │
│  [✓] Start with 3-day free trial    │
│                                     │
│  ┌──────────────────────────────┐  │
│  │     Start Free Trial         │  │
│  └──────────────────────────────┘  │
│                                     │
│  Cancel anytime · Restore Purchases │
│                                     │
│  Fine print + Terms + Privacy links │
└─────────────────────────────────────┘
```

## Section-by-section

### Hero visual

- Animated illustration: camera shutter → plate → three abstract “signal” bars (carb / fiber / sugar) morphing into the spike-risk pill colors — **no** fake CGM graph.

### Headline

- **Pattern:** Personalized but non-diagnostic, e.g. “**{first_name},** keep meals clear without the spreadsheet” or, if name unavailable, “Keep meals clear without the spreadsheet.”
- **Optional insert:** Reference chosen tone from onboarding (“Gentle nudges” vs “Balanced”) in subcopy only.

### Sub-headline

- “Photo logging with rough calories, macros, and a spike-risk label — always informational, not a diagnosis.”

### Social proof

- Stars + numeric rating + count (update with real post-launch data).
- One short quote attributed (“— Maya, beta”).

### Pricing tiers

| Tier | Price | Trial | Default selected |
|---|---|---|---|
| Annual | $59.99/yr (~$0.16/day) | 3-day introductory offer via StoreKit | Yes |
| Monthly | $12.99/mo | None | No |

Badges: “BEST VALUE” on annual; optional “Save vs paying monthly” computed from monthly ×12 vs annual.

### Trial toggle

- Default ON. Label: “Start with 3-day free trial”
- OFF state CTA text: “Subscribe Now”
- Maps to distinct RC/StoreKit package identifiers as required.

### Primary CTA

- “Start Free Trial” / “Subscribe Now” — 56pt height, brand teal, white text.

### Reassurance

- “Cancel anytime in Settings · **Restore Purchases**” (tappable link on Restore).

### Fine print (must ship on-screen)

```
Subscription automatically renews at $59.99/year (annual) or $12.99/month (monthly)
unless canceled at least 24 hours before the end of the trial or current period.
Payment charged to Apple ID. Manage or cancel in Apple ID account settings.
By subscribing you agree to the Terms of Service and Privacy Policy.
Glu AI provides educational information only and is not a medical device.
```

URLs must be tappable.

## Close behavior

- **0–10s:** No visible close control (Superwall default pattern) — ensure swipe-dismiss still works if presented as sheet per Apple guidelines.
- **After 10s:** Low-contrast × or “Not now” that exits to a **limited shell**: settings + restore + static education snippet only — **no** meal analysis. Track `paywall_dismissed`.
- Dismiss must never trap the user; no false close buttons.

## Variant ideas (Superwall)

1. Headline A: habit/outcome framing vs B: method framing (“Photo-first diabetes meal context”).
2. Annual price $49.99 vs $59.99 vs $69.99 elasticity.
3. Hero A: generic animation vs B: stylized recap of user’s selected diabetes type + tone (no numbers that imply glucose prediction).
4. Toggle: 3-day vs 7-day trial (monitor refund rate).
5. Social proof: single quote vs lightweight carousel.

## Conversion benchmarks

Track against ranges in Cal AI paywall doc: paywall view → trial start target ≥8% early, ≥12% at maturity; tune onboarding + headline first if underperforming.

## Re-engagement paywalls

| Trigger | Placement | Notes |
|---|---|---|
| Returned after dismiss | `returning_soft` | Softer copy; same SKUs |
| Tap locked feature | `feature_gate` | “Unlock unlimited meal analyses” |
| Trial ending (day −1) | Push + in-app | RC trial listener |
| Incomplete onboarding resume | `resume_offer` | If implemented, respect data minimization |

Each placement is its own Superwall event + Mixpanel property.

## Open questions

1. Reverse trial vs opt-in trial — start opt-in for clarity with health positioning; A/B reverse only after legal review.
2. Whether to show **weekly** SKU at all in diabetes segment (often lower LTV); default off.

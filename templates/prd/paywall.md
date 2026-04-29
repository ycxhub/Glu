# Paywall — [App Name]

> GUIDANCE: The paywall is where 90% of revenue happens. Cal AI–archetype apps use a **hard paywall** immediately after onboarding, before the user has used the core product. This sounds aggressive — it works because the onboarding has already delivered perceived value (the personalized plan). Read `references/cal-ai-paywall-deconstruction.md` before filling out this file.

## Paywall philosophy

1. **Hard, not soft** — No free tier. No "use it 3 times then pay". The user pays now or churns now. This sounds extreme; consumer-app data shows it generates 3–5× the revenue of soft paywalls because trial-starters are committed.
2. **Annual default, monthly fallback** — Annual subscription is pre-selected with the biggest visual weight. Monthly exists for those who balk at annual but is presented as the "weak" option.
3. **Trial framing > price framing** — Lead with "Start your 3-day free trial" not "$59.99/year". Price is fine print until they commit to the trial.
4. **Per-day pricing** — "$0.27/day" feels cheaper than "$99/year" even though they're identical. Use the smaller frame.
5. **Reverse trial (optional but powerful)** — Charge the trial card immediately at $0.00 with auto-renew at full price after 3 days. iOS handles this natively. Industry data: ~50% trial-to-paid for reverse trial vs. ~25% for opt-in trial after the fact.

## Screen anatomy (top to bottom)

```
┌─────────────────────────────────────┐
│  [Hero visual or animation]         │  <- Emotional hook
│                                     │
│  Bold headline                      │  <- Outcome promise
│  Sub-headline                       │
│                                     │
│  ★★★★★  4.8 · 50K ratings          │  <- Social proof
│  "Quote from a real review"         │
│                                     │
│  ┌─ ANNUAL ─────── BEST VALUE ──┐  │  <- Selected by default
│  │ $59.99/year ($0.16/day)      │  │
│  │ Save 80% vs monthly          │  │
│  └──────────────────────────────┘  │
│  ┌─ Monthly ─────────────────────┐ │
│  │ $9.99/month                   │ │
│  └───────────────────────────────┘ │
│                                     │
│  [✓] Start with 3-day free trial   │  <- Toggle, ON by default
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Start Free Trial            │  │  <- Primary CTA, full-width
│  └──────────────────────────────┘  │
│                                     │
│  Cancel anytime · Restore purchases│  <- Reassurance + compliance
│                                     │
│  [Subscription terms fine print]    │
└─────────────────────────────────────┘
```

## Section-by-section

### Hero visual

- **What:** Animated illustration, before/after collage, or AI-generated personalized output (e.g., the user's plan visualized as a glowing graphic)
- **Goal:** Emotional payoff for the onboarding work. Should feel like "this is YOUR thing, here it is".
- **Avoid:** Stock photos, generic illustrations, anything that says "you're seeing a paywall".

### Headline

- **Pattern:** "[Outcome the user wants], [time frame]"
- **Examples:**
  - "Reach your goal weight by [date]"
  - "Get the body you want in 12 weeks"
  - "Stop wasting time and start seeing results"
- **Tone:** Specific to the user's stated goal from onboarding. Use their inputs.

### Sub-headline

- **Pattern:** "[Method or how], [credibility]"
- **Example:** "Personalized AI guidance, trusted by 1.2M users"

### Social proof block

- **Star rating:** ★★★★★ + numeric ("4.8") + count ("· 50K ratings")
- **One review quote:** Real if possible; pulled from App Store reviews. Short (1–2 lines). Attributed by handle or first name.
- **Optional:** Tiny press logos ("Featured in Forbes, TechCrunch, Wired") — only if real.

### Pricing tiers

> GUIDANCE: Two tiers is enough for V1. Adding a 3rd tier (e.g., weekly) tests well in some categories. Annual MUST be pre-selected.

| Tier | Price | Trial | Selected by default? |
|---|---|---|---|
| **Annual** | $[59.99]/year ($[0.16]/day) | 3 days | ✅ Yes |
| **Monthly** | $[9.99]/month | None | No |
| Weekly (optional) | $[4.99]/week | None | No |

**Visual weight:** Annual tier is 2× the size of monthly. Has a "BEST VALUE" or "SAVE 80%" badge. Monthly tier is grayed out or smaller until selected.

**Per-day framing:** Display the per-day cost under the annual tier. Always.

### Trial toggle

- **Default:** ON
- **Copy:** "Start with 3-day free trial"
- **What it does:** Toggles between StoreKit `productIdentifier` for "trial-eligible product" vs. "non-trial product"
- **Why a toggle:** Gives the user agency, but the default does the work.

### Primary CTA

- **Copy (when trial is on):** "Start Free Trial"
- **Copy (when trial is off):** "Subscribe Now" or "Start Now"
- **Style:** Full-width, brand color, 56pt tall, primary button style from design system

### Reassurance line

- **Copy:** "Cancel anytime in Settings · Restore Purchases"
- **"Restore Purchases" is a tappable link** — required by App Store rule.
- **Visible:** Always, below the CTA.

### Fine print

- **Copy template:**

```
Subscription auto-renews at $X.XX/year unless canceled at least 24 hours before
the trial ends. Manage in your Apple ID account settings.
By starting your trial you agree to our Terms and Privacy Policy.
```

- **Required:** Subscription length, full price after trial, renewal terms, cancellation instructions, links to Terms and Privacy Policy. All required by App Store rule 3.1.2.

## Close behavior

> GUIDANCE: This is the controversial part. Cal AI does not show a close button on first impression. After ~30 seconds, a small × appears in the corner. Some apps do not offer close at all on first paywall and force the user to leave the app to dismiss. Aggressive but legal.

**Recommended for V1:**
- **First 10 seconds:** No close button visible
- **After 10 seconds:** Small × in top-left, low contrast, 24×24pt
- **Closing behavior:** Returns to home screen of app, but with minimal value (no AI inference until subscribed). The user can re-trigger the paywall by tapping any premium feature.

> Apple has rejected apps for fully blocking app exit. Always allow the user to *leave the paywall*; they don't have to *use the app*.

## Variant ideas (for A/B testing post-launch)

> GUIDANCE: V1 ships one variant. Set up Superwall from day 1 so you can test these without app review.

1. **Reverse trial vs. opt-in trial** — Charge $0 today, full price in 3 days vs. start trial after explicit consent. Reverse trial typically converts 1.5–2× better.
2. **Headline:** Specific outcome ("Lose 10 lbs by [date]") vs. generic ("Achieve your goals")
3. **Social proof:** Star rating-first vs. testimonial-first vs. user count-first
4. **Pricing:** $59.99 annual vs. $79.99 vs. $39.99 (price elasticity test)
5. **Trial length:** 3-day vs. 7-day vs. no trial (no-trial often wins on revenue per install for committed users)
6. **Timer / urgency:** "50% off, ends in 02:00" countdown — boosts urgency but can hurt App Store approval if price is fake. Only run if discount is real.

## Conversion benchmarks (Cal AI archetype)

| Metric | Below average | Average | Top quartile |
|---|---|---|---|
| Onboarding-to-paywall completion | < 50% | 60% | 75%+ |
| Paywall view → trial start | < 8% | 12% | 18%+ |
| Trial → paid conversion | < 25% | 50% (reverse trial) | 65%+ |
| LTV per install | < $5 | $10 | $25+ |

If V1 hits average, you have a real business. If V1 hits top quartile, raise a round.

## Re-engagement paywalls (post-onboarding)

> GUIDANCE: The first paywall is the big one, but re-engagement paywalls drive incremental conversion. Trigger them at:

1. **App open after first onboarding skip** — show a softer paywall ("Welcome back, ready to start?")
2. **After trying a premium feature** — show a contextual paywall ("Unlock unlimited X")
3. **Day 3 push notification** — "Your trial offer expires today" (if trial wasn't started)
4. **Day 7 in-app banner** — for users who haven't converted, surface paywall on home screen

Each trigger should have its own Superwall placement and a separate analytics event so you can measure incremental ARPU.

## Open questions

> GUIDANCE: Decisions to make before build.

1. Reverse trial or opt-in trial? (Recommend reverse trial for higher conversion.)
2. Annual price point? ($49.99 / $59.99 / $79.99 — test starts at $59.99.)
3. Show close button immediately, after delay, or never? (Recommend after 10s.)

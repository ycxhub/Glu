# Cal AI Paywall Deconstruction

> A teardown of why Cal AI's paywall converts. Use this when filling out `paywall.md` to understand each lever you have, so you can adapt without losing the mechanics.

## Why hard paywalls work for the Cal AI archetype

Conventional SaaS wisdom: free tier → premium tier ("freemium"). This works for tools where the user makes a slow decision over weeks (Notion, Figma).

Consumer mobile apps are different:
- Decision is made in a single session, in 90 seconds
- Most "free tier" users never convert (typical SaaS conversion: 2–5%)
- Pricing decisions are emotional, not rational
- App Store ratings depend on engagement, and free-tier users engage less

For a Cal AI–archetype app:
- Hard paywall: ~12% trial start, ~50% trial-to-paid = ~6% of installs pay
- Soft paywall (free with limits): ~3% conversion
- Free with paid upgrade: ~1–2% conversion

Hard paywalls do **3–5×** the revenue at the cost of higher install bounce. Worth it because:
1. Paid users are committed → better engagement → better ratings → better ASO
2. The cost of acquiring a non-paying user is wasted
3. Inference costs (LLM, vision, etc.) are paid per-call — free users burn money

This is why every viral consumer AI app since 2023 (Cal AI, RealShort, Umax, Lapse-equivalents) ships with a hard paywall.

## Paywall screen anatomy (top to bottom)

### 1. The hero zone (top 30% of screen)

**What:** Animated visual or hero illustration. Cal AI uses a stylized graphic of a meal being analyzed, with floating calorie numbers — visually echoing what the app does.

**Goal:** Emotional payoff for finishing onboarding. The user has just seen their personalized plan; this hero says "this is your thing now."

**Avoid:** Stock photos. Generic graphics that say "you are seeing a paywall."

### 2. Headline + sub-headline (under hero, 12% of screen)

**Headline pattern:** "[Outcome the user wants], [time frame]"
- "Reach your goal weight by Dec 15"
- "Get the body you want in 12 weeks"
- "Track your nutrition without the work"

**Critical:** The headline should reference user-specific data from onboarding. "Reach your goal of 145 lbs by Dec 15" is 2× more powerful than "Reach your weight loss goal."

**Sub-headline:** Method + credibility — "Personalized AI guidance, trusted by 1.2M users."

### 3. Social proof block (8% of screen)

**Format:** Star rating visual + numeric rating + count + one short review quote.

```
★★★★★  4.8 · 50K ratings
"This is the only app that actually got me to track."
                                — Jenny K.
```

**Why this works:**
- Star pattern (★★★★★) is processed before the user reads
- Specific count ("50K") is more credible than "many"
- Real names + real quotes outperform anonymous testimonials
- One quote, not three — quality > quantity

**Lazy trick:** A scrolling carousel of 4–5 reviews works almost as well and adds visual motion that holds attention.

### 4. Pricing tiers (25% of screen)

This is where the conversion lever lives. Cal AI's structure:

```
┌─ ANNUAL ────────────── BEST VALUE ──┐
│  $59.99/year                         │  <- Selected, prominent
│  ($0.16/day · Save 80%)              │
└──────────────────────────────────────┘
┌─ Monthly ────────────────────────────┐
│  $9.99/month                         │  <- Smaller, secondary
└──────────────────────────────────────┘
```

**Key tactics:**

1. **Annual is pre-selected** with visual weight 2× the monthly. The user must actively *choose* the worse deal.
2. **"Save 80%" or "BEST VALUE" badge** on annual. Pure framing — without the badge, conversion drops.
3. **Per-day price under annual.** "$0.16/day" feels cheaper than "$59.99/year" even though it's the same dollar amount. Anchoring to a small denomination is well-documented (called "pennies a day" or "small unit framing" — see Gourville 1998).
4. **Two tiers, not three.** Three tiers is a Goldilocks move that works for some apps; for Cal AI archetype, two converts better. Three tiers makes annual feel "expensive" relative to weekly; two makes it feel "the obvious choice."

### 5. Free trial toggle (5% of screen)

```
[✓] Start with 3-day free trial
```

- **Default:** ON
- **What it does:** Switches the actual StoreKit product ID between "trial-eligible" and "non-trial" SKUs
- **Why this exists as a toggle:** Some users perceive trials as "tricks" and want to subscribe directly. Giving them agency increases trust. But the default does the conversion work.

**Reverse trial alternative:** Charge $0 today, auto-renew at full price after 3 days. Skips the toggle and just *does* this. iOS supports this natively. Reverse trial outconverts opt-in trial by 1.5–2×, but Apple has been tightening rules around it; check current App Store guidelines.

### 6. Primary CTA (8% of screen)

```
┌─────────────────────────────────────┐
│         Start Free Trial            │  <- Full-width, brand color
└─────────────────────────────────────┘
```

- Full-width, brand color, 56pt tall, white bold text
- Copy depends on toggle: "Start Free Trial" or "Subscribe Now"
- Triggers `Purchases.shared.purchase(package:)` (RevenueCat)

### 7. Reassurance + restore (3% of screen)

```
Cancel anytime in Settings  ·  Restore Purchases
```

- "Restore Purchases" is a tappable link — required by App Store rule
- "Cancel anytime" is reassurance — many users abandon paywalls because they fear forgetting to cancel

### 8. Fine print (5% of screen)

Required by App Store rule 3.1.2. Must include:
- Subscription length
- Full price after trial
- Renewal terms
- Cancellation instructions
- Links to Terms and Privacy Policy

```
Subscription auto-renews at $59.99/year unless canceled at least 24 hours
before the trial ends. Manage in your Apple ID account settings.
By starting your trial you agree to our Terms and Privacy Policy.
```

### 9. Close behavior

**The controversial part.** Cal AI's behavior:

- First 10 seconds: no close button visible
- After 10 seconds: small × in top-left, low contrast
- Closing returns user to home screen of the app, but core features are gated

**Apple's rule:** You must allow the user to leave the paywall. You don't have to let them use the app.

**Aggressive variant:** Some apps don't show a close button at all. The user has to swipe down (which is the iOS sheet dismiss gesture). This is technically Apple-compliant because the gesture works, but it's borderline. Cal AI doesn't go this far.

## A/B testing variants worth running

V1 ships one variant. Set up Superwall from day 1 and start testing in week 2.

### Test 1: Trial structure
- A: Reverse trial ($0 today, charge in 3 days)
- B: Opt-in trial (toggle on by default)
- C: No trial (subscribe immediately)

Hypothesis: Reverse trial wins on revenue per install but may have higher refund rate. Worth measuring net revenue, not gross.

### Test 2: Annual price point
- A: $49.99/year
- B: $59.99/year (control)
- C: $79.99/year

Hypothesis: $59.99 is the sweet spot for "expensive enough to feel valuable, cheap enough to convert." Higher prices select for committed users (better LTV) but kill volume.

### Test 3: Headline framing
- A: Specific outcome ("Reach 145 lbs by Dec 15")
- B: Method ("AI-powered nutrition tracking, made simple")
- C: Social proof ("Join 1.2M users tracking with [App]")

Hypothesis: Specific outcome wins for users who completed all goal-setting screens; method wins for users who skipped them.

### Test 4: Social proof placement
- A: Stars + count + quote (control)
- B: Stars + count + 5-quote carousel
- C: Logos of press features (Forbes, TechCrunch)
- D: User photo grid ("These users hit their goal")

Hypothesis: Quote carousel performs slightly better; press logos work for "trust signal-needy" segments.

### Test 5: Hero visual
- A: Animated app screenshot
- B: Personalized output (e.g., user's plan visualized)
- C: Before/after collage
- D: Animated illustration

Hypothesis: Personalized output (B) wins because it ties back to onboarding work.

## Re-engagement paywalls

The first paywall is the big one. ~80% of users who don't convert at first paywall never convert. But the remaining 20% are valuable to recover.

### Trigger 1: User skipped paywall, opened app later
- Show a softer paywall: "Welcome back. Ready to start?"
- Same pricing, less aggressive copy
- May have a discount offer for returning users (e.g., 30% off first month)

### Trigger 2: User tries a premium feature
- Contextual paywall: "Unlock unlimited [feature]"
- Highlights the specific value the user just tried to get
- Often converts higher than the onboarding paywall because intent is concrete

### Trigger 3: Push notification on day 3 trial offer expiring
- "Your trial offer expires today" — works for users who started onboarding but didn't reach paywall
- Tap → directly to paywall

### Trigger 4: Day 7 in-app banner
- Persistent banner on home screen for free-tier users
- Tap → paywall

Each trigger should be its own Superwall placement and instrumented separately. This is how you find which non-converting flows are worth optimizing.

## Pricing benchmarks (Cal AI archetype, 2024–2026)

| Pricing tier | Range | Notes |
|---|---|---|
| Annual | $39.99 – $99.99 | $59.99 is the most common sweet spot for AI consumer apps |
| Monthly | $7.99 – $14.99 | Should be 5–8× the per-month annual price (price discrimination) |
| Weekly (optional) | $3.99 – $7.99 | Used to attract impulse subscribers; lower LTV |
| Lifetime (rare) | $99.99 – $199.99 | Rarely used; high churn-resistant users only |

Don't undercharge. Cal AI–archetype apps with $19.99 annual pricing routinely underperform apps with $59.99 because the lower price signals lower quality and reduces marketing budget per user.

## Final thoughts

The paywall doesn't sell the subscription — onboarding does. By the time the user sees the paywall, they've already decided yes or no. The paywall's job is to **not screw it up**:

- Don't surprise the user with the price
- Don't add friction (extra screens, sign-in barriers)
- Don't undermine commitment with skip buttons
- Don't bury the value prop in pricing detail

Get those right and 12% of paywall views convert. Don't, and 3% convert. That's the entire business.

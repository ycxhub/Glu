# Cal AI Onboarding Deconstruction

> A teardown of why Cal AI's onboarding works. Use this when filling out `onboarding.md` to understand the *purpose* behind each screen, so you can adapt the pattern to a different domain without losing the mechanics.

## Why Cal AI's onboarding is famous

Cal AI scaled to ~$30M ARR in under a year as a calorie-tracking app — a category dominated for a decade by MyFitnessPal and Lose It. Their onboarding is the centerpiece of that success. It's been copied by hundreds of consumer apps since (Umax, Fasty, RealShort, dozens of dupes).

The Cal AI onboarding is **22 screens long**. Conventional UX wisdom says shorter is better. Cal AI's data says otherwise — for hard-paywall apps, longer onboardings *increase* paywall conversion because:

1. **Sunk cost effect** — Users who've answered 18 questions don't walk away from the paywall lightly. Closing means wasting all that effort.
2. **Personalization is theater** — Asking 22 questions makes the user feel the AI "knows them," even if the underlying calculation is a 3-line formula.
3. **Loss aversion** — By the end, the user has been *promised a personalized result*. The paywall is the price of keeping it.
4. **Social proof spacing** — Long onboardings have room to drop in 2–3 social proof breaks, which short ones don't.

## The 4 phases of the flow

Cal AI's flow can be decomposed into 4 phases. Use this same structure for any Cal AI–archetype app.

### Phase 1: Welcome + commitment (Screens 1–3)
**Goal:** Get the first tap. Establish tone. Tiny commitment.

- Screen 1: Welcome (social proof bar, single CTA, no skip)
- Screen 2: First easy question (gender / segment) — low cognitive cost, builds momentum
- Screen 3: Activity / behavior pattern — slightly more thought, more sunk cost

**Why this order:** First taps need to be effortless. Hard questions early = bounce. The user is only going to commit if the first 3 taps feel "easy and quick."

### Phase 2: Personal data + problem articulation (Screens 4–9)
**Goal:** Collect data the app needs + make the user articulate their own problem.

- Screen 4: Past attempts — "Have you tried this before?" → activates loss aversion
- Screen 5: What stopped them — multi-select problems → user *says out loud* what they want fixed
- Screen 6: Long-term promise — "Most users see results in N weeks" → outcome anchor
- Screens 7–9: Physical data (height, weight, DOB) — the data inputs needed for personalization

**Why this order:** Phase 2 turns the user from a passive consumer into an active participant. They've now told the app "I tried X, it didn't work because Y, I want Z" — and the app is set up to deliver that exact thing.

### Phase 3: Goals + permissions + attribution (Screens 10–17)
**Goal:** Define success, ask for permissions while user is invested, capture attribution.

- Screens 10–12: Goal definition (what, magnitude, speed) — concretizes the outcome
- Screen 13: Social proof break — halfway through, reset doubt
- Screens 14–15: Sub-segmentation + aspirations — final personalization data
- Screen 16: Notification permission — asked AFTER user invested, with framing ("we'll remind you so you don't miss your goal")
- Screen 17: Referral source — "How did you hear about us?" — gold for marketing attribution post-iOS 14

**Why this order:** The user is now ~70% through the onboarding. They've poured in personal data and articulated their problem. Asking for notification permission here gets ~75% allow rate vs. ~30% if asked on screen 1. Same psychology applies to the attribution question.

### Phase 4: Reveal + paywall (Screens 18–22)
**Goal:** Deliver the promised value, then collect payment.

- Screen 18: Calculating screen (theatrical, 5-second progress bar)
- Screen 19: Plan reveal (the personalized output)
- Screen 20: Account creation
- Screen 21: Paywall (hard, no skip)
- Screen 22: First-launch tutorial (after subscription)

**Why this order:** The "calculating" screen is critical. The actual computation is trivial (a BMR formula plus a target calorie multiplier — could run in 50ms). Cal AI stretches it to 5 seconds with rotating status text because the **labor illusion** makes the output feel more valuable. This is well-documented UX research (Norton, Mochon, Ariely 2011: "The IKEA Effect").

## Specific Cal AI tactics worth copying

### 1. The "What's stopping you?" multi-select
- 6–8 options shown as chips
- Multiple selections allowed
- Phrased in user's language: "I lose motivation," "Don't have time," "Too complicated"
- The selected chips are remembered and addressed throughout the rest of the funnel ("We designed [App] to fix exactly these problems: [chip], [chip]")

This screen is high-converting because it *has the user say their problem*. People believe their own words more than the app's claims.

### 2. The "Most users see results in 3 weeks" promise
- Stated with statistical credibility ("Based on 10,000+ users")
- Visualized with a chart or growth curve
- Sets up the trial period — by paying for the trial, the user is buying into a 3-week test
- This screen is what makes the trial price feel like buying a *result*, not a subscription

### 3. The notification permission screen with mockup
- Shows a fake notification preview *inside the screen* — "Hey Sam, time for your morning weigh-in 💪"
- Frames the permission ask: "We'll send 1–2 reminders a day, you can change anytime"
- Primary button: "Enable Reminders" (large, brand color)
- Secondary "Maybe Later" is small, ghost — but offering it AT ALL hurts allow rate by ~40%

### 4. The "How did you hear about us?" screen
- Almost no other apps do this — most consumer apps under-instrument attribution
- The data feeds Mixpanel as a user property; every metric in the dashboard can be sliced by source
- This is how Cal AI knows TikTok organic delivers 4× the LTV of Instagram paid (or whatever the actual numbers are)

### 5. The calculating screen (the labor illusion)
- 4–6 second progress bar
- Status text rotates every 1.5 seconds:
  - "Analyzing your goals..."
  - "Matching with similar users..."
  - "Optimizing your daily target..."
  - "Almost done..."
- Underlying computation: a single formula
- Critical: the status text should reference user-specific things ("your goals," "your data") to reinforce personalization

### 6. The plan reveal screen
- ONE big number front and center (target daily calories, score, goal weight, etc.) at 60+pt display weight
- 2–3 supporting stats below ("Reach goal by [date]", "Weekly progress: X")
- Subtle animation: number ticks up from 0 to final value over 1 second
- "Continue" CTA at bottom
- This is the **emotional payoff**. The next screen is the paywall — the user is now buying *this specific number*, not a generic subscription.

## Adapting to non-fitness domains

The phases stay the same; the questions change.

| Phase | Fitness app | Skincare app | Productivity app | Photo/video gen app |
|---|---|---|---|---|
| Phase 1 | Gender, activity | Skin type, age | Work type, role | Style preference |
| Phase 2 | Past tracking, blockers | Past products, skin issues | Past tools, blockers | Past gen tools, blockers |
| Phase 2 | Height, weight, DOB | Photo of face, age | Hours/day, focus areas | Reference photos uploaded |
| Phase 3 | Lose/maintain/gain, target | Brighter / smoother / acne-free, target | Save N hours, focus mode | Quality / quantity / virality |
| Phase 4 | Personalized calorie target | Personalized routine | Personalized schedule | Personalized prompt template |

The mechanics — sunk cost, problem articulation, social proof break, calculating theater, personalized reveal — are domain-agnostic.

## Common mistakes when copying this pattern

1. **Skipping the "what stopped you" screen** — without this, the rest of the funnel doesn't have anchors to reference.
2. **Asking for notifications on screen 1** — kills allow rate.
3. **Showing a "Skip" button on every screen** — kills completion.
4. **Calculating screen too short (< 3 seconds)** — feels fake. Too long (> 8 seconds) feels broken.
5. **Plan reveal without a big number** — emotional payoff requires a specific output the user can latch onto.
6. **Letting users see pricing before the paywall** — frames the product as paid too early.
7. **Showing testimonials of unrealistic outcomes** — risks Apple rejection AND tanks trust if user doesn't see same.

## Funnel benchmarks

| Stage | Cal AI archetype baseline |
|---|---|
| Welcome → first tap | 95–98% |
| Welcome → screen 10 | 80–85% |
| Welcome → notification permission | 70–75% |
| Welcome → paywall shown | 60–65% |
| Welcome → trial started | 8–15% |
| Trial → paid | 50–65% (reverse trial) |

Below these = something specific is broken; instrument every screen and find dropoff.

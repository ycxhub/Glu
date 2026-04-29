# Onboarding Flow — [App Name]

> GUIDANCE: This is the most important file in the PRD. The onboarding flow IS the marketing funnel for a hard-paywall app — get this wrong and conversion craters. Cal AI's flow is ~22 screens; aim for 18–25. Every screen earns its place by either (a) collecting data the app uses, (b) creating personalization sunk cost, (c) building social proof / authority, or (d) priming the paywall. Read `references/cal-ai-onboarding-deconstruction.md` before filling this out.

## Onboarding philosophy

The Cal AI archetype follows three principles that should not be diluted:

1. **Personalization sunk cost** — By screen 10, the user has shared 5–8 personal details. Walking away feels like throwing away effort. This is what makes a long onboarding *increase* conversion vs. a short one.
2. **Promise, then deliver, then paywall** — Show the user a personalized result *before* the paywall. They've seen the value, now they pay to keep it.
3. **No skipping** — Every screen is required. Skip buttons reduce data collection AND signal optionality, which reduces conversion. Use "Continue" buttons that require an answer.

## Funnel targets

| Stage | Target completion rate |
|---|---|
| Screen 1 → Screen 2 | ≥ 95% |
| Screen 1 → Notification permission | ≥ 75% |
| Screen 1 → Loading screen | ≥ 65% |
| Screen 1 → Paywall shown | ≥ 60% |
| Paywall → Trial started | ≥ 12% |

Below these numbers means the funnel is broken. Diagnose by screen, fix the dropoff point.

## Screen-by-screen

> GUIDANCE: Adapt the screens below to your app's domain. The *structure* (welcome → personal data → goal → social proof → notification ask → calculating → reveal → email → paywall) should stay intact. Replace specifics (calorie tracking → your domain).

### Screen 1 — Welcome

- **Headline:** [App name] in large display weight + tagline ("[Single value prop]")
- **Visual:** App logo or hero illustration, animated subtle (pulse, float)
- **Social proof bar:** "★★★★★ Loved by [N] users" — show this even at launch with placeholder until real reviews exist
- **CTA:** "Get Started" (primary, full-width)
- **Why this screen:** First impression, sets tone. No "Skip" button. No login button (login comes after the value reveal).

### Screen 2 — Gender (or first personal data point)

- **Headline:** "What's your [gender / first key trait]?"
- **Options:** [Male / Female / Other] — large tappable cards, not radio buttons
- **CTA:** Continue (disabled until selection)
- **Why this screen:** Easy first commitment. The user has now invested 1 tap. Sunk cost begins.

### Screen 3 — Activity / Usage Pattern

- **Headline:** "How often do you [relevant behavior]?"
- **Options:** Multi-tier choice (Sedentary / Lightly active / Active / Very active or domain equivalent)
- **CTA:** Continue
- **Why this screen:** More data, more sunk cost.

### Screen 4 — Past attempts / problem articulation

- **Headline:** "Have you tried [category solutions] before?"
- **Options:** Yes / No
- **Why this screen:** Activates loss aversion. If "Yes", next screen asks why they failed (which we then promise to solve). If "No", they're a green field.

### Screen 5 — What stopped them (multi-select)

- **Headline:** "What's stopping you from [goal]?"
- **Options:** Multi-select chips: "Don't have time", "Too complicated", "Lose motivation", "Don't see results", "Hate the process", etc.
- **CTA:** Continue (require ≥1 selection)
- **Why this screen:** User explicitly states their problems. The app's job from here is to address each one. Activates the "this app gets me" feeling.

### Screen 6 — Long-term promise

- **Headline:** "[App name] users see results in [N] weeks"
- **Visual:** Bar chart, growth curve, or before/after illustration showing the promise
- **Body:** "[Stat-based credibility line, e.g. 'Based on 10,000+ users']"
- **CTA:** Continue
- **Why this screen:** Authority + outcome promise. Sets expectation for the trial period.

### Screen 7 — Height / first physical measurement (if applicable)

- **Headline:** "How tall are you?"
- **Input:** Wheel picker, ft/in or cm toggle, default to user's locale
- **Why this screen:** More personal data, more sunk cost. Enables personalized output later.

### Screen 8 — Weight / second measurement

- **Headline:** "What's your current weight?"
- **Input:** Wheel picker
- **Why this screen:** Same as above. Pair with Height for "calculating BMI" or analogous outputs.

### Screen 9 — Date of birth

- **Headline:** "When were you born?"
- **Input:** Date picker
- **Why this screen:** Age personalization + age gating compliance.

### Screen 10 — Goal

- **Headline:** "What's your goal?"
- **Options:** Domain-specific, 2–4 options (Lose weight / Maintain / Gain weight; or for non-fitness: "Look more confident" / "Track progress" / "Compete with friends")
- **CTA:** Continue
- **Why this screen:** Defines what "success" means for this user. The personalized output later will be framed in terms of this goal.

### Screen 11 — Goal magnitude (if applicable)

- **Headline:** "What's your target [weight / score / outcome]?"
- **Input:** Wheel picker or slider
- **Why this screen:** Concretizes the goal. Now the user has a number in their head — and the app holds the path to that number.

### Screen 12 — Goal speed

- **Headline:** "How fast do you want to reach your goal?"
- **Input:** Slider with descriptive labels: "Steady (3 months)" / "Moderate (6 weeks)" / "Aggressive (3 weeks)"
- **Why this screen:** Sets pace expectation. Some research/medical caveat copy below the slider for credibility ("We recommend X for sustainable results").

### Screen 13 — Social proof break

- **Headline:** "[App name] is trusted by [N] users"
- **Visual:** Star rating, review carousel with 3–5 real testimonials, or "Featured in [press logos]"
- **CTA:** Continue
- **Why this screen:** Halfway through. Reset doubt with social proof. Especially powerful here because user is mid-investment.

### Screen 14 — Diet / preference / category sub-segmentation

- **Headline:** "Which best describes you?"
- **Options:** Domain-specific (Classic / Pescatarian / Vegan / Vegetarian; or "I prefer X / Y / Z")
- **Why this screen:** Sub-segments the user for content/recommendation personalization.

### Screen 15 — Aspirations (multi-select with badges)

- **Headline:** "What do you want to achieve?"
- **Options:** Multi-select badges with emoji: "Build confidence ✨", "Look great in photos 📸", "Feel energetic 💪", "Beat my [score] 🏆", etc.
- **CTA:** Continue (require ≥1)
- **Why this screen:** Explicit aspirational framing. The user is now telling the app what to deliver — making the paywall feel like buying their own goal, not a subscription.

### Screen 16 — Notification permission ask

> CRITICAL SCREEN. This is the hardest part of the funnel. Most apps ask for notifications at the wrong time and tank conversion. Cal AI's pattern: frame it as "we'll remind you so you don't miss your goal" — never "we want to send marketing".

- **Headline:** "Stay on track with reminders"
- **Body:** "We'll send you 1–2 gentle reminders a day so you don't break your streak. You can change this anytime."
- **Visual:** Mock notification preview showing what a real notification looks like (set expectation)
- **CTA:** "Enable Reminders" (primary) → triggers iOS permission sheet
- **Secondary CTA:** "Maybe Later" (small, ghost button) — but data shows: if you offer this, 35% take it. If you make it look required and only offer "Continue", 75%+ allow.
- **Why this screen:** Notification permission is a one-shot in iOS — if denied, you have to send the user to Settings to change it. Worth optimizing.

### Screen 17 — Referral source ("How did you hear about us?")

- **Headline:** "How did you hear about us?"
- **Options:** TikTok / Instagram / Friend or Family / Google / App Store / Other
- **CTA:** Continue
- **Why this screen:** This is **gold for marketing attribution**. iOS 14+ broke deterministic attribution; user-reported source data is the best signal you'll get for paid channel ROAS. Mixpanel/Amplitude track this as a property and slice everything by it.

### Screen 18 — Calculating screen

- **Headline:** "Creating your personalized plan..."
- **Visual:** Progress bar that fills over 4–6 seconds; status text rotates: "Analyzing your goals..." → "Matching with similar users..." → "Optimizing your plan..."
- **CTA:** None (auto-advances)
- **Why this screen:** Theatrical pause. The app does ~1 second of real work, but takes 5 seconds — because the user values the output more if they perceive effort behind it. ("Effort heuristic" / "labor illusion" — well-documented in UX research.)

### Screen 19 — Plan reveal

- **Headline:** "Your personalized plan is ready"
- **Body:** Big number front-and-center — the personalized output the app calculated (target calories, score, goal date, etc.)
- **Sub-content:** 3 personalized stats backing it up ("Daily target: X", "Reach goal by: [date]", "Estimated weekly progress: Y")
- **CTA:** "Continue"
- **Why this screen:** The promised value, delivered. The user now has *something they want to keep*. The paywall on the next screen is "pay to keep this", not "pay for unknown stuff".

### Screen 20 — Account creation (email or social sign-in)

> See `auth.md` for full auth flow.

- **Headline:** "Save your plan"
- **Body:** "Create an account so we can save your progress and sync across devices."
- **Options:** "Continue with Apple" (primary) / "Continue with Google" / "Continue with Email"
- **Why this screen:** Account is required so the trial-to-paid conversion is tied to a user. Apple Sign In is mandatory if Google is offered (App Store rule).

### Screen 21 — Paywall

> See `paywall.md` for full paywall structure.

This is where 70% of revenue is decided. The user has already done the work — closing the paywall feels like wasting all that effort. Hard paywall, no skip, no soft tier.

### Screen 22 — Welcome / first launch

- **Headline:** "Welcome to [App name]"
- **Body:** Brief 2–3 step tutorial of the core action (the camera, the scan, the generate). Tooltip-style coachmarks.
- **CTA:** "[Verb] your first [thing]" — primary CTA that drops the user into the magic moment immediately

## Implementation notes

- **State persistence:** Save every onboarding answer to local SwiftData IMMEDIATELY on selection. If the user closes the app mid-flow, restart at the last completed screen.
- **Backend sync:** Send the full onboarding payload to backend on screen 20 (after auth). Store in `profiles.onboarding_responses` as JSONB.
- **Analytics:** Fire `onboarding_screen_viewed` and `onboarding_screen_completed` for every screen with the screen index and time-on-screen. This is how you find dropoff.
- **A/B testing:** V1 ships one variant. Plan to A/B test screens 1, 16 (notification ask), and 21 (paywall) by month 3.

## Anti-patterns to avoid

- **Don't add a "Login" button on screen 1** — it pulls returning users out of the funnel before they see updates. Login lives in settings.
- **Don't ask for notifications on screen 1** — premature, low yield. Wait until they've invested.
- **Don't let users skip screens** — every skipped screen is lost data. If a question is truly optional, cut it.
- **Don't show pricing during onboarding (before paywall)** — frames the product as a paid thing too early. Let value sink in first.
- **Don't put an X / close button on the paywall** — Cal AI's paywall has no close button on the first impression. After the first full minute, it can be dismissed via swipe-down.

## Open questions

> GUIDANCE: List the unresolved onboarding decisions to resolve before build.

1. [Question, e.g., "Do we ask weight/height for V1, or only goal? Trades off personalization for friction."]
2. [Question]

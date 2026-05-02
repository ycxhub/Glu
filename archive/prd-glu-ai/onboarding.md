# Onboarding Flow — Glu AI

## Onboarding philosophy

1. **Personalization sunk cost** — By screen 10 the user has shared diabetes context, goals, and friction points. Leaving feels wasteful.
2. **Promise → reveal → auth → paywall** — Personalized “spike-smart plan” appears **before** payment. Auth immediately precedes paywall so trials bind to an account.
3. **No skip on required questions** — Every screen needs an answer to continue (except explicitly optional comorbidity chips where “None of these” is a valid completion).

Funnel targets align with Cal AI archetype baselines in `about.md`.

## Funnel targets

| Stage | Target completion rate |
|---|---|
| Screen 1 → Screen 2 | ≥ 95% |
| Screen 1 → notification permission screen completed | ≥ 75% |
| Screen 1 → calculating screen | ≥ 65% |
| Screen 1 → paywall shown | ≥ 60% |
| Paywall → trial started | ≥ 12% |

## Screen-by-screen (22 screens)

### Screen 1 — Welcome

- **Headline:** “Glu AI” (display) + “Photo meals. Smarter carb context.”
- **Visual:** Subtle animated hero (plate + camera glint), brand teal on soft surface.
- **Social proof bar:** “★★★★★ Built with dietitians’ feedback in mind” (replace with real rating + count when available).
- **CTA:** “Get Started” (primary, full-width). No skip. No login on this screen.
- **Why:** First tap, tone, trust frame — **educational tool**, not a meter.

### Screen 2 — Diabetes type

- **Headline:** “What best describes you?”
- **Options (large cards):** Type 1 · Type 2 · Prediabetes · Gestational · Not sure / still learning
- **CTA:** Continue (disabled until selection).
- **Why:** Core segmentation; easy first commitment.

### Screen 3 — Carb awareness

- **Headline:** “When you eat, how often do you think about carbs?”
- **Options:** Rarely · Sometimes · Most meals · Always
- **CTA:** Continue
- **Why:** Frames later education depth and copy tone.

### Screen 4 — Prior logging attempts

- **Headline:** “Have you tried logging meals or using diabetes apps before?”
- **Options:** Yes · No
- **Why:** Loss aversion; branches optional microcopy on next screen intro line only (same UI).

### Screen 5 — What’s been hardest (multi-select)

- **Headline:** “What usually gets in the way?”
- **Chips:** “Too time-consuming” · “Hard to guess carbs” · “Forget to log” · “Apps feel clinical” · “Don’t trust estimates” · “I’m not sure what to aim for”
- **CTA:** Continue (≥1 chip). Microcopy: “We designed Glu AI around these.”
- **Why:** User states problems in their words — anchors value.

### Screen 6 — Outcome promise

- **Headline:** “Most members build a steadier logging habit in 3 weeks”
- **Visual:** Simple upward habit curve; footnote: “Self-reported consistency; not a medical outcome claim.”
- **CTA:** Continue
- **Why:** Time-bounds expectation; pairs with trial length psychologically.

### Screen 7 — Primary goals (multi-select)

- **Headline:** “What are you hoping Glu AI helps with?”
- **Chips:** “Fewer sharp swings after meals (how I feel)” · “Better carb awareness” · “Lighter logging workload” · “Weight trend support” · “Talk with my care team using a food journal”
- **CTA:** Continue (≥1)
- **Why:** Ties plan reveal to user language (still non-diagnostic).

### Screen 8 — Carb target comfort

- **Headline:** “Do you already have a daily carb target from your clinician?”
- **Options:** Yes, I have a number · I’m figuring it out · I prefer not to use a number right now
- **If Yes:** follow-up inline step on same screen or sub-step: numeric wheel **range** buckets (e.g., 100–150 g/day bands) not precise treatment — labeled “Rough range you’re working with (optional).”
- **CTA:** Continue
- **Why:** Personalization for plan reveal without collecting prescriptions.

### Screen 9 — Typical eating pattern

- **Headline:** “Which sounds most like you?”
- **Options:** 3 meals · Grazer / small meals · Intermittent fasting · Irregular schedule
- **CTA:** Continue
- **Why:** Shapes reminder timing defaults and copy.

### Screen 10 — Strictness of guidance

- **Headline:** “How direct should tips feel?”
- **Slider labels:** Gentle nudges · Balanced · More direct (still never medical commands)
- **CTA:** Continue
- **Why:** Sets coaching voice for in-app tips.

### Screen 11 — Foods you want more awareness about (multi-select)

- **Headline:** “Where do you want extra awareness?” (optional headline tweak: “Pick any that apply”)
- **Chips:** “Restaurant meals” · “Takeout” · “Home cooking” · “Packaged snacks” · “Sweets / desserts” · “Drinks”
- **CTA:** Continue (≥1)
- **Why:** Sub-segmentation for future content; increases “this is for me.”

### Screen 12 — Optional context you’re comfortable sharing

- **Headline:** “Anything else you’re comfortable telling us? (Optional)”
- **Chips:** “None of these” · “High blood pressure” · “Kidney-related guidance from my clinician” · “Celiac / gluten-free” · “Vegetarian / vegan” · “Other dietary pattern”
- **CTA:** Continue (selecting “None of these” alone is valid)
- **Why:** Respectful optional comorbidities; improves tip relevance without demanding PHI.

### Screen 13 — Social proof break

- **Headline:** “People use Glu AI to log faster and think clearer about meals”
- **Body:** Rotating 3 short quotes (replace with real TestFlight quotes pre-launch).
- **CTA:** Continue
- **Why:** Mid-funnel doubt reset.

### Screen 14 — Accountability style

- **Headline:** “What helps you stay consistent?”
- **Options:** Reminders · Streaks · Weekly recap · Just opening the app when I need it
- **CTA:** Continue
- **Why:** Pre-frames notification screen.

### Screen 15 — Aspirations (badges, multi-select)

- **Headline:** “In the next month, you’d love to…”
- **Badges:** “Feel more in control at meals” · “Spend less time logging” · “See my patterns clearly” · “Bring better notes to appointments”
- **CTA:** Continue (≥1)
- **Why:** Aspirational ownership before permission ask.

### Screen 16 — Notification permission

- **Headline:** “Stay consistent with gentle reminders”
- **Body:** “1–2 nudges on days you choose — never spam. Change anytime in Settings.”
- **Visual:** Mock notification: “Alex, quick lunch log? 📸”
- **Primary:** “Enable Reminders” → system prompt
- **Secondary:** “Maybe later” (small ghost) — product may A/B hide secondary per Cal AI learnings; document both.
- **Why:** Permission after investment.

### Screen 17 — Attribution

- **Headline:** “How did you hear about us?”
- **Options:** TikTok · Instagram · Friend / family · Google · App Store · Clinician / educator · Other
- **CTA:** Continue
- **Why:** Slice LTV and creative performance.

### Screen 18 — Calculating (labor illusion)

- **Headline:** “Creating your spike-smart plan…”
- **Progress:** 4–6 seconds; rotating status: “Balancing your goals…” · “Pairing tips with your meal style…” · “Tuning reminders…” · “Almost ready…”
- **Auto-advance**
- **Why:** Perceived value of personalization.

### Screen 19 — Plan reveal

- **Headline:** “Your starting plan is ready”
- **Hero (single rule for V1):** Large typographic **plan tier** — one of **Balanced** · **Careful** · **Max awareness** — computed from onboarding: diabetes type + carb-awareness answers + strictness slider + stated goals (implementation spec: weighted score → tier; no glucose math).
- **Supporting bullets (always three):**
  1. “Photo-log **one** meal today you usually find tricky” (pulls highest-priority chip from Screen 11 when possible; else generic copy).
  2. “In every estimate, glance at **fiber** and **added sugar** — not just carbs.”
  3. “Bring questions to your clinician; Glu AI is **educational**, not a prescription.”
- **Sub-stats row:** Reminder preset (from Screen 9 + 14) · Tips tone (from Screen 10) · “Unlimited analyses with Premium after this screen”
- **Disclaimer strip (footnote):** “Educational only — not medical advice.”
- **CTA:** Continue
- **Why:** Emotional payoff before paywall; user “owns” a named plan style.

### Screen 20 — Account creation

- **Headline:** “Save your plan”
- **Body:** “Create an account to sync meals and keep your streaks across devices.”
- **Buttons:** Continue with Apple (primary) · Continue with Google · Email magic link (tertiary)
- **Legal:** Terms + Privacy links
- **Why:** Auth after value; see `auth.md`.

### Screen 21 — Paywall

- **Hard paywall** — See `paywall.md`. No access to meal analysis or full history without subscription.

### Screen 22 — First-run coachmarks

- **When:** Only after **trial or subscription becomes active** (entitlement from RevenueCat). If the user dismisses the paywall without converting, skip this screen and land in the limited shell per `paywall.md`.
- **Headline:** “You’re in — let’s log your first meal”
- **Body:** 2–3 coachmarks: where camera lives, how to retake, where disclaimers always appear on results.
- **Primary CTA:** “Open camera” → `MealCapture` tab.

## Implementation notes

- Persist each answer locally on selection; resume mid-funnel.
- POST full `onboarding_responses` JSON to `profiles` after auth success (screen 20 complete + session).
- Analytics: `onboarding_screen_viewed` with `screen_index` 1…22; time-on-screen histograms for tuning drops.

## Anti-patterns

- No pricing before paywall.
- No notification ask on screen 1.
- No “diagnosis” language (“You are diabetic type X”) — mirror user’s self-selection only.
- No insulin dose calculators in onboarding or app.

## Open questions

1. Whether gestational users need a separate post-download disclosure flow (legal review).
2. Whether to collect **height/weight** for any non-diagnostic personalization in V2 only (skipped in V1 to reduce friction and medical adjacency).

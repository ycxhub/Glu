# Glu AI — Screen & Interaction Brief for UI/UX Design

**Audience:** Technical UI/UX designer delivering visual designs, interaction specs, and engineering handoff notes.  
**Platform:** iOS-first, SwiftUI, native patterns preferred.  
**Product:** Glu AI — a **photo-first, glucose-aware meal tracker** that provides rough calories, macros, and educational spike-risk context from meal photos.  
**Positioning:** Educational meal awareness, not medical advice.  
**Design language:** **Pastel Precision** — a calm watercolor-inspired wellness interface with crisp, readable, precise nutrition tools.  
**Source of truth:** If this brief ever disagrees with [`design.md`](./design.md), **`design.md` wins**; keep this document aligned with it.

---

## 0. Product Definition

Glu AI is not a generic calorie tracker and should not be designed like one.

It is a **photo-first, glucose-aware meal tracker** for people who want to understand meals through:

1. Rough calories
2. Macro estimates
3. Carb context
4. Fiber and added sugar awareness
5. Educational spike-risk estimates
6. A saved meal history built from photos

The product should help users build awareness without shame, fear, or clinical overwhelm.

### Product Promise

> Snap a meal. Understand the estimate. Learn the likely glucose context. Save the pattern.

### Core User Questions

Every screen should ultimately help users answer:

1. What did I eat?
2. What does Glu estimate about this meal?
3. What might this meal mean for my glucose awareness?
4. What is one small, realistic improvement I can make?

---

## 1. Brand and Design Philosophy

### Core Design Principle

> The brand may feel like watercolor. The UX must behave like a precision tool.

Glu AI should feel calm, fresh, supportive, and trustworthy. It should not feel like a harsh dieting app, a medical device, or a guilt machine.

### Desired Emotional Feel

The UI should feel:

- Calm
- Airy
- Nourishing
- Intelligent
- Premium
- Non-judgmental
- Respectful
- Lightly magical, but grounded

### Avoid

- Diet culture aesthetics
- Shame-based calorie warnings
- Bright red/orange dashboard states
- Clinical hospital-like layouts
- Spreadsheet-heavy macro screens
- Loud gamification
- Overly cute wellness visuals
- Fear-based spike-risk messaging

### Product Metaphor

> A watercolor canvas of your meal patterns, with precise nutrition estimates embedded inside.

---

## 2. Visual System: Pastel Precision

The visual system should use a soft pastel atmosphere with precise, small semantic signals where needed.

### Palette Direction

| Role | Color Direction | Suggested Hex | Usage |
|---|---|---:|---|
| Base background | Creamy vanilla | `#FFF8ED` | Global background |
| Dashboard surface | Powder blue | `#EAF5FF` | Today/Home surfaces |
| Secondary surface | Soft mint | `#EAF8F0` | Supporting cards, wellness sections |
| Elevated card | Warm ivory | `#FFFCF6` | Cards, forms, sheets |
| Primary trust anchor | Calm teal | `#0A7A6A` | Main CTA, key numerals, selected states |
| Primary soft wash | Pale teal | `#E6F5F3` | Selected rows, subtle backgrounds |
| Hydration / greens | Seafoam | `#A8E6CF` | Hydration, greens, completion |
| Protein | Apricot | `#FFD3B6` | Protein macro |
| Fats | Lemon chiffon | `#FFF4B8` | Fat macro |
| Carbs / energy | Soft peach | `#FFE1C7` | Carbs and energy |
| AI / insight | Lavender | `#D9C7F7` | Coach, insight cards |
| Reflection / secondary accent | Periwinkle | `#BFC7F7` | Secondary highlights |
| Celebration | Blush pink | `#F8C8DC` | Milestones |
| Primary text | Muted slate plum | `#353145` | Main text |
| Secondary text | Dusty lavender gray | `#7A748A` | Subtext |
| Divider | Soft mist | `#EAE4DA` | Dividers, outlines |
| Error | Muted rose | `#D97A8A` | True errors only |

### Spike-Risk Semantic Colors

Spike-risk colors should be used sparingly and never as large alarming blocks.

| Spike-risk estimate | Color Direction | Suggested Hex | UI Treatment |
|---|---|---:|---|
| Low | Soft mint green | `#6FD6A5` | Small pill/dot + label |
| Medium | Soft amber | `#E8A94D` | Small pill/dot + label |
| High | Muted rose | `#D97A8A` | Small pill/dot + label |

Do not use harsh red/orange as large fills, dashboard backgrounds, or warning banners. A high spike-risk estimate should feel informative, not frightening.

### Important Language Change

Avoid the phrase **health zone**.

Use:

- Spike-risk estimate
- Estimated spike risk
- Meal risk context
- AI meal estimate

---

## 3. Typography

Use **SF Pro** as the default iOS-native typeface unless there is a strong reason to change.

| Token | Size / Weight | Usage |
|---|---:|---|
| Display | 48 Bold | Hero stats, calorie estimates, plan tier |
| Title | 28 Bold | Screen titles |
| Title 2 | 22 Semibold | Section titles |
| Headline | 17 Semibold | Card/list titles |
| Body | 17 Regular | Rationale, paragraphs |
| Subhead | 15 Regular | Supporting copy |
| Footnote | 13 Regular | Disclaimers, errors |
| Caption | 11 Regular | Timestamps, micro labels, tile overlays |

### Typography Rules

- Calorie and macro numbers must be highly readable.
- Avoid pastel-colored body text.
- Use dark muted slate/plum for primary text.
- Use lavender/periwinkle as accents, not as primary paragraph text.
- Support Dynamic Type wherever possible.

---

## 4. Layout Rhythm

| Element | Spec |
|---|---:|
| Screen horizontal padding | 24pt |
| Card corner radius | 16pt |
| Primary button radius | 14pt |
| Chip/option row padding | 16pt |
| Minimum tap target | 44×44pt |
| Meal grid gap | 2–4pt |
| History tile aspect ratio | 1:1 |

### Layout Rules

- Each screen should have one dominant action.
- Use progressive disclosure.
- Keep functional UI crisp and readable.
- Use soft backgrounds and cards, not decorative glass stacks.
- Prioritize one-handed use.
- Avoid showing too many numbers at once.
- Use empty space intentionally.

---

## 5. Apple Platform and Liquid Glass Alignment

Glu AI should feel native to current Apple platforms.

### Strategic Layering

| Layer | Direction |
|---|---|
| Navigation chrome | Use native system chrome, including Liquid Glass where available |
| Content | Use readable, calm, mostly opaque/grouped surfaces |
| Meal photos | Keep photos prominent and crisp |
| Custom controls | Avoid decorative glass overuse |

### Liquid Glass Rules

- Prefer standard `NavigationStack`, `TabView`, sheets, toolbars, and grouped lists.
- Let system navigation chrome inherit Liquid Glass automatically on supported SDKs.
- Do not blanket nutrition cards, dense text, or macro tables in glass.
- Avoid layering glass on glass.
- Use glass effects only for floating chrome or selected lightweight controls.
- Always test with Reduce Transparency, Reduce Motion, Increase Contrast, and large Dynamic Type.

### Sheets

Sheets should follow native system behavior:

- Rounded corners
- Safe corner clearance
- Comfortable edge padding
- Clear hierarchy
- Readable content when background peeks through

---

## 6. Navigation Architecture

### High-Level Flow

```text
Onboarding
  → Auth
  → Paywall
  → If subscribed: full access
  → If dismissed: free mode with 5 meal analyses
  → After 5 free analyses used: paywall returns
  → Main app
```

### Main App Tabs

Recommended four-tab shell:

1. **Home** — Today’s meal awareness dashboard
2. **Log** — Camera-first capture
3. **History** — Photo grid meal archive
4. **Settings** — Account, subscription, preferences

### Tab Bar

| Tab | Symbol Direction | Notes |
|---|---|---|
| Home | `house` | Today overview |
| Log | `camera.viewfinder` or stronger camera icon | Capture anchor; visually emphasized |
| History | `clock` or `square.grid.3x3` | Photo archive |
| Settings | `gearshape` | Account and configuration |

The Log tab should read as the capture anchor, but do not add custom heavy chrome that fights the native tab bar.

---

## 7. Onboarding Flow

### Strategy

Use a **longer, conversion-oriented onboarding** (required **19 steps**). Do not reduce onboarding to a short generic setup flow. This matches **`design.md` §10**.

Every step must do at least one of the following:

1. Collect meaningful personalization  
2. Increase perceived product relevance  
3. Build trust  
4. Explain the glucose-aware value prop  
5. Reduce anxiety around tracking  
6. Prepare the user for the paywall  
7. Make the final plan feel earned  

If a step does none of these, cut it.

### Onboarding Feel

The onboarding should feel light, calm, personal, premium, purposeful, and **fast despite being long**. It should not feel like a medical intake form.

### Onboarding UX Rules

- One question per screen  
- One primary action  
- Soft progress indicator  
- Clear back navigation  
- Visually satisfying option rows  
- Short, reassuring helper copy  
- No dense paragraphs  
- No medical fear language  
- Keep the user moving  

### Required Long Onboarding Flow

| # | Step ID | Kind | Title | Notes |
|---:|---|---|---|---|
| 1 | welcome | Welcome | Glu AI | Brand intro and promise |
| 2 | dm_type | Single choice | What best describes you? | Type 1, Type 2, Prediabetes, Gestational, Not sure, General glucose awareness |
| 3 | carb_think | Single choice | When you eat, how often do you think about carbs? | Awareness baseline |
| 4 | tried_log | Single choice | Have you tried logging meals or diabetes apps before? | Establish pain/experience |
| 5 | barriers | Multi choice | What usually gets in the way? | Builds relevance |
| 6 | promise | Info | Small logs compound | Trust/value bridge, no unsupported claims |
| 7 | goals | Multi choice | What are you hoping Glu helps with? | Personalization |
| 8 | carb_comfort | Single choice | Do you already have a daily carb target from your clinician? | Optional framing, not required |
| 9 | eat_pattern | Single choice | Which sounds most like you? | Meal rhythm |
| 10 | strictness | Single choice | How direct should tips feel? | Tone personalization |
| 11 | food_focus | Multi choice | Where do you want extra awareness? | Context personalization |
| 12 | comorbid | Optional multi choice | Anything else you’re comfortable sharing? | Optional, skippable |
| 13 | social_proof | Info | Glu helps people log faster and think clearer | Use only truthful, non-medical copy |
| 14 | accountability | Single choice | What helps you stay consistent? | Reminder/streak personalization |
| 15 | aspirations | Multi choice | In the next month, you’d love to… | Emotional investment |
| 16 | notify_prime | Notification priming | Stay consistent with gentle reminders | Permission priming |
| 17 | attribution | Single choice | How did you hear about us? | Growth attribution |
| 18 | calculating | Calculating | Creating your spike-smart plan… | Perceived personalization |
| 19 | reveal | Plan reveal | Your starting plan is ready | Paywall readiness moment |

### Onboarding Step Copy Guidance

#### Welcome

- **Title:** Glu AI  
- **Subtitle:** Snap meals. Understand calories, macros, and glucose context — educational only.  
- **CTA:** Get Started  

#### Promise step

Do not claim “Most members build a steadier logging habit in 3 weeks” unless backed by real data. Prefer:

> Small logs compound. In a few weeks, your meal patterns become easier to see.

or

> Glu is designed to help you build a steadier logging habit without making tracking feel heavy.

#### Calculating step

- **Title:** Creating your spike-smart plan…  
- **Status lines (examples):** Balancing your goals… / Pairing tips with your meal style… / Preparing your starting plan…  
- Use a tasteful animation. Do not fake overly technical analysis.

#### Plan reveal

- **Title:** Your starting plan is ready  
- **Subtitle:** Educational only — not medical advice.  
- Plan reveal should make the user feel **understood**, not diagnosed.

### Settings and progressive prompts

Any future onboarding trims can surface deeper questions in **Settings** or post-save prompts; v1 ships this full flow unless product explicitly changes step count.

### Optional Multi-Select Rule

Optional multi-select steps must allow the user to continue without selection.

If “None of these” appears:

- Selecting “None of these” deselects all other options.
- Selecting any other option deselects “None of these.”

### Plan Reveal Tier Labels

Avoid “Careful” as a tier label. It may sound patronizing, especially for Type 1 users.

Use:

| Tier | Trigger |
|---|---|
| Gentle | User chooses gentle nudges |
| Balanced | Default |
| Focused | Type 1, direct tips, or high-awareness profile |

### Plan Reveal Bullets

Always show three bullets:

1. A personalized focus-area bullet based on selected goals/food focus.
2. “In every estimate, glance at fiber and added sugar — not just carbs.”
3. “Bring questions to your clinician; Glu AI is educational, not a prescription.”

### Promise / Social Proof Copy

Do not claim “Most members build a steadier logging habit in 3 weeks” unless backed by real data.

Preferred copy:

> Small logs compound. In a few weeks, your meal patterns become easier to see.

or

> Glu is designed to help you build a steadier logging habit without making tracking feel heavy.

---

## 8. Auth Screen

### Purpose

Create a durable account and sync meals through Supabase.

| Element | Copy / Behavior |
|---|---|
| Title | Save your plan |
| Body | Sign in to keep your plan and meal history synced. |
| Primary | Sign in with Apple |
| Secondary | Continue with Google, if wired |
| QA-only tertiary | Use mock account, simulator/dev only |
| Error area | Footnote, muted rose, dynamic server/Apple errors |

### Design Notes

- Use the native Sign in with Apple button.
- Keep this screen minimal.
- Avoid making Supabase visible in consumer-facing copy unless needed.
- If Google sign-in is not implemented, do not show it in production UI.

---

## 9. Paywall and free mode

Aligned with **`design.md` §§8–9**. The paywall is conversion-oriented but must not be manipulative, fear-based, or medically claiming.

### Paywall moment

The paywall comes after: **Onboarding** → **Plan reveal** → **Auth**. The user should already understand the product, have shared context, and have seen a personalized plan.

### Production

RevenueCat `PaywallView` (or equivalent) provides layout, products, and pricing.

Entitlement: **Glu Gold**

### If the user subscribes

Grant **full access** (unlimited meal analyses, subscription state reflected in Settings).

### If the user dismisses the paywall

Let the user enter **free mode** with **5 total meal photo analyses** (lifetime or as product defines—communicate clearly in UI). Free mode includes:

- Meal estimate view after each analysis  
- Ability to save analyzed meals  
- Basic history from those meals  
- **Clear remaining analysis count** (Home, Log, Settings as applicable)  

After the **fifth** analysis is consumed, **show the paywall again** before starting another analysis.

### Paywall header direction

Possible copy:

- **Title:** Your spike-smart plan is ready  
- **Subcopy:** Start Glu Gold for unlimited meal analysis, editable estimates, saved history, and AI-powered meal context.

### Dismiss / secondary CTA copy

Any dismiss control must be **honest**. Prefer labeled actions such as:

- **Continue with 5 free analyses**  
- **Try 5 meals first**  

Do not use an **unlabeled X** that behaves unexpectedly.

### Free mode messaging (examples)

- You have 4 free meal analyses left.  
- Try Glu with 5 analyses. Upgrade anytime for unlimited logging.  
- You’ve used your 5 free meal analyses. Start Glu Gold to keep analyzing meals.

Make the limit **visible and predictable**—not a surprise trap.

### After free limit is used

- **Title:** You’ve used your 5 free meal analyses  
- **Subcopy:** Upgrade to Glu Gold to continue analyzing meals and building your meal history.  
- **Primary:** Continue with Glu Gold (subscribe)  
- **Secondary:** Maybe later (only if product allows exit without subscribe; define behavior in implementation)

### Paywall design requirements

- High-fidelity production screen  
- Native iOS premium feel  
- Calm pastel visuals; **no fear language**; **no medical claims**  
- Clear subscription options, **Restore purchases**, Terms and Privacy  
- **“Try 5 meals first”** (or equivalent) when user has not yet exhausted free analyses  

### Required Paywall Behaviors

| Action | Behavior |
|---|---|
| Subscribe / start trial | Full access; continue to main app |
| Restore purchases | Restore RevenueCat purchases |
| Dismiss into free mode | Labeled CTA; user enters app with 5 analyses budget |

### Development fallback

Only in dev builds: RevenueCat API key missing, unlock locally, restore purchases, sign out / QA mock auth as needed.

---

## 10. Home Tab

### Purpose

Home should be a calm “Today’s meal awareness” dashboard, not a generic calorie-budget dashboard.

It should show users what they have logged today, what the estimates suggest, and what to do next.

### Structure

| Section | Content |
|---|---|
| Greeting | Time-based greeting with first name if available |
| Header | Today |
| Free mode counter | Only for free-tier users (e.g. “3 analyses left”) |
| Today summary card | Meals logged, estimated calories, estimated carbs |
| Spike-risk summary | Low / Medium / High count or distribution for today |
| Streak card | Day logging streak |
| AI insight card | One calm, contextual insight |
| Recent meals | Up to 5 recent meal cards with thumbnails |
| Empty state | Prompt to log first meal |

### Example Today Summary

- 2 meals logged
- 1,120 estimated kcal
- 138g estimated carbs
- 1 medium spike-risk meal

### AI Insight Examples

Good:

> Lunch looked carb-heavy and low in fiber. Add vegetables, dal, curd, or protein at dinner to balance the day.

Good:

> You logged breakfast two days in a row. Nice rhythm.

Avoid:

> You exceeded your carbs.

### Recent Meal Cards

Each row/card should include:

- Thumbnail 56×56
- “{kcal} kcal · {time}”
- Spike-risk estimate pill
- 1–2 line rationale

### Interaction

Recent meal rows should be tappable.

Tap opens Meal Detail sheet.

Non-tappable cards that look tappable should be avoided.

---

## 11. Log Tab

### Purpose

Camera-first meal capture.

The user should instantly understand:

> Take a photo now.

### Camera Must Be Visually Dominant

Camera is the hero control wherever it appears next to Library or other actions.

Do not design Camera and Library as symmetric peers.

### Required Hierarchy

| Action | Treatment |
|---|---|
| Camera | Primary, dominant, brand-filled or glassProminent with brand tint, larger touch target, stronger icon |
| Library | Secondary, subdued, outline/neutral/lighter fill |

### Log Screen Content

| Element | Copy |
|---|---|
| Title | Log |
| Heading | Log a meal |
| Subcopy | Snap or pick a meal photo. Glu AI returns rough calories, macros, and a spike-risk estimate — educational only. |
| Primary action | Camera |
| Secondary action | Library |
| Free mode counter | Remaining analyses when applicable (e.g. “4 free analyses left”) |
| Loading | Analyzing… |
| Errors | Muted rose footnote or banner |

### Free analysis count

In free mode, show the remaining analysis count **near the capture controls**. After the user uses the fifth analysis, **present the paywall** before allowing another analysis.

### Accessibility

VoiceOver order:

1. Camera — “Take photo. Scan meal with camera.”
2. Library — “Choose meal photo from library.”

### Sheets

1. Camera opens full-screen camera.
2. Library opens photo picker.
3. Successful analysis opens Meal Estimate sheet.

### Roadmap Logging Inputs

Do not design these as v1 primary unless product scope changes, but leave room for future expansion:

- Text meal entry
- Voice meal entry
- Barcode scan
- Saved meals
- Recent meal repeat  

(Portion and line-item editing for saved estimates belongs in **Meal Estimate** / **Edit estimate** in v1—see §12—rather than a separate logging mode.)

---

## 12. Meal Estimate Sheet

Previously called “Result.” Rename to **Meal Estimate**.

### Purpose

Show the AI’s estimate with humility, clarity, and editability.

### Shared Data Model

| Field | UI Usage |
|---|---|
| Photo | Full-width rounded image |
| Calories | Large display number + “kcal” |
| Spike risk | Low / Medium / High pill with label |
| Macros | Carbs, Fiber, Sugar, Protein, Fat |
| Confidence | Percentage or qualitative label |
| Rationale | Human-readable explanation |
| Disclaimer | Educational only / not medical advice |
| Items | Optional food assumptions / line items |

### Required Content

- Meal photo
- Estimated calories
- Spike-risk estimate
- Macro breakdown
- Confidence
- Rationale
- Disclaimer
- Assumptions or detected items, if available

### Required Actions

| Action | Treatment |
|---|---|
| Save meal | Primary |
| Edit estimate | Secondary |
| Discard | Cancel |
| Close | Toolbar action |

### Editability requirements (v1 — non-negotiable)

Aligned with **`design.md` §15**. Users **must** be able to correct the AI **before saving**.

Design and engineering must support:

- Edit portion size  
- Correct detected foods  
- Remove incorrect food item  
- Add missing item  
- Adjust quantity  
- Save corrected estimate (totals/macros update accordingly)  

### Editable food row

Each detected item row should support:

- Food name  
- Estimated quantity  
- Calories  
- Macro preview, if available  
- Edit affordance  
- Remove affordance  

### Edit estimate flow

1. User taps **Edit estimate**  
2. Sheet expands or pushes to edit mode  
3. User adjusts items and portions  
4. Calories/macros update  
5. User saves changes  
6. Returns to **Meal Estimate**  

If the user has edited details and taps **Discard**, confirm before losing changes.

### Confidence Pattern

Example:

> Confidence: Medium  
> Based on visible portions and common serving sizes. Adjust if needed.

Do not hide AI uncertainty.

---

## 13. History Tab

### Purpose

A visual archive of logged meals.

History should feel like:

> My meal photo diary.

Not:

> A spreadsheet of food entries.

### Visual Metaphor

Instagram-style profile grid:

- Uniform square tiles
- Usually 3 columns on iPhone
- Minimal gaps
- Photo fills tile
- Lightweight overlays

### Tile Overlay

Each tile must include:

1. Micro calorie label, e.g. “520 kcal”
2. Spike-risk estimate marker:
   - L / M / H
   - Small color dot or small pill
   - Color must not be the only signal

### Overlay Rules

- Use scrim, gradient hairline, or blurred pill for readability.
- Keep overlays small.
- Avoid loud red/amber bars across photos.
- High-risk should be noticeable, not alarming.

### Empty State

Title:

> No meals yet

Subtitle:

> Saved meals from the Log tab appear here.

CTA:

> Log a meal

### Interaction

Tap tile → Meal Detail sheet.

### Delete Pattern

Avoid relying on list swipe-delete in grid UI.

Use one of:

1. Long-press context menu
2. Edit mode with selectable tiles
3. Detail sheet destructive action

Recommended v1:

- Tap tile → Meal Detail
- Delete meal from detail sheet
- Optional long-press menu later

### Accessibility

VoiceOver label example:

> Meal photo. 520 calories. Medium spike-risk estimate. Logged Tuesday at 1:20 PM.

---

## 14. Meal Detail Sheet

### Purpose

Show saved meal estimate in full detail.

### Title

Meal

### Content

- Full meal photo
- Estimated calories
- Spike-risk estimate
- Macros
- Confidence, if stored
- Rationale
- Timestamp
- Disclaimer
- Optional detected items / assumptions

### Actions

| Action | Treatment |
|---|---|
| Done | Dismiss |
| Edit estimate | Secondary (supported in v1) |
| Delete meal | Destructive, bottom of sheet |

### Delete Confirmation

**Title:** Delete meal?  
**Body:** This removes the meal from your history.  
**Actions:** Cancel / Delete

---

## 15. Settings Tab

Use grouped list style.

### Sections

| Section | Contents |
|---|---|
| Account | User identity, sign out |
| Subscription | Glu Gold status, restore purchases, billing help |
| Free mode | Remaining free analyses when applicable |
| Preferences | Reminder settings, tip directness, optional personalization |
| Health context | Diabetes/glucose-awareness profile, carb target if user wants to add it |
| Legal | Educational disclaimer, privacy, terms |
| Developer | QA-only; hidden in production |

### Delete Account Flow

Avoid vague “Delete all data locally?” copy.

Use:

**Title:** Delete account?  
**Body:** This will delete local app data. Server-side account deletion is not yet available in this build.  
**Actions:** Cancel / Delete local data

If server-side deletion is supported later, update copy accordingly.

---

## 16. AI Coach / Insight System

AI Coach is not required as a root tab in v1 unless scoped. However, AI insight cards should appear throughout the product.

### Insight Card Locations

- Home
- Meal Estimate
- Meal Detail
- Weekly recap later
- Optional future Coach tab

### Tone

The AI should be:

- Calm
- Specific
- Practical
- Non-judgmental
- Honest about uncertainty

### Good Insight Copy

> This meal looks higher in fast-digesting carbs and lower in fiber. Pairing it with protein or vegetables may help make it steadier.

### Avoid

> This meal is bad for your glucose.

### Future Coach Tab

If added later, users should be able to ask:

- What can I eat for dinner?
- Estimate this meal.
- How can I make this meal steadier?
- What patterns do you see this week?
- What should I ask my clinician?

---

## 17. Notification Priming

### Screen

Title:

> Stay consistent with gentle reminders

Subtitle:

> 1–2 nudges on days you choose — never spam. Change anytime in Settings.

### Fake Notification Preview

Example:

**Glu AI**  
Alex, quick lunch log? 📸

### Actions

| Action | Behavior |
|---|---|
| Enable Reminders | Request notification permission |
| Maybe later | Skip and continue |

The “Maybe later” action should be functional, not a stub.

---

## 18. Loading and Analyzing State

### Current Behavior

Meal analysis can take time.

### Design Requirements

Show:

- Meal photo preview if available
- Spinner or subtle progress animation
- Status copy
- Educational note if analysis takes longer

### Copy

Primary:

> Analyzing meal…

Secondary rotating examples:

- Estimating visible portions…
- Looking at carbs, fiber, and sugar…
- Preparing your meal estimate…

Avoid fake precision.

---

## 19. Error and Edge States

Errors should feel calm and recoverable.

### Meal Analysis Failed

> We couldn’t analyze this photo. Try a clearer image or choose another one.

Actions:

- Try again
- Choose from Library

### Low Confidence

> I’m not fully sure about this estimate. You can adjust it before saving.

### No Food Detected

> I couldn’t clearly identify the meal. Try another angle with the food centered.

### Overwhelming / High Risk Context

Avoid panic language.

Use:

> Estimated high spike risk. This is educational context, not a medical reading.

Optional:

> Want ideas to make a similar meal steadier next time?

### Free analyses exhausted

When the user has **no free analyses** remaining and is not subscribed:

- Present paywall before starting a new meal analysis  
- Use calm copy such as: **You’ve used your 5 free meal analyses** with upgrade path to Glu Gold  
- Secondary action (e.g. “Maybe later”) only if product allows; avoid trap UX  

---

## 20. Copy Guardrails

### Always Remember

Glu AI is educational, not medical advice.

Use phrases like:

- Educational only
- Not medical advice
- Estimated
- Rough estimate
- Spike-risk estimate
- Talk to your clinician
- Based on visible portions

### Avoid

- Diagnosis language
- Prescription language
- “Safe” or “unsafe” meal
- “Good” or “bad” food
- “Health zone”
- “Failed”
- “Cheat meal”
- “Control your diabetes” unless clinically reviewed
- Guaranteed outcomes

### Preferred Rewrites

| Instead of | Use |
|---|---|
| High health zone | High spike-risk estimate |
| You failed your goal | Today went above target |
| Bad food | Higher spike-risk meal |
| Cheat meal | Treat meal or special meal |
| Control your glucose | Understand your glucose context |
| Medical result | Educational estimate |

---

## 21. Accessibility Requirements

### Required

- Dynamic Type support
- Minimum 44×44pt tap targets
- Spike-risk labels must include text, not color only
- History tile overlays must remain readable on busy photos
- VoiceOver labels for meal photos and risk estimates
- Reduce Transparency support
- Reduce Motion support
- Increase Contrast spot checks
- Dark mode support

### VoiceOver Examples

Spike pill:

> Spike-risk estimate: medium. Educational estimate only.

Meal tile:

> Meal photo. 520 calories. Medium spike-risk estimate. Logged yesterday at 8:15 PM.

Free mode counter (when visible):

> Three free meal analyses remaining.

Camera button:

> Take photo. Scan meal with camera.

---

## 22. Motion and Haptics

Motion should be subtle and purposeful.

Use:

- Soft card expansion
- Gentle sheet presentation
- Light progress fill
- Calm analyzing animation
- Success haptic after meal saved
- Gentle milestone notification

Avoid:

- Confetti
- Fireworks
- Bouncy cartoon motion
- Long blocking animations
- Alarm-like high-risk animations

### Milestone Notification

Style:

- Blush pink notification surface
- Seafoam checkmark
- Short, calm copy

Example:

> Nice rhythm. You logged 7 meals this week.

---

## 23. App Icon Direction

The app icon should align with the pastel leaf identity.

### Requirements

- 1024×1024 source artwork
- Layered artwork suitable for Icon Composer
- Rounded-square masking handled by system
- No text in icon
- Pastel tropical leaf as core symbol
- Variants for:
  - Default
  - Dark
  - Clear Light
  - Clear Dark
  - Tinted Light
  - Tinted Dark

### Icon Meaning

The leaf communicates:

- Natural growth
- Freshness
- Meal awareness
- Gentle self-improvement
- Balance
- Calm intelligence

---

## 24. Analytics Awareness

Designer does not implement analytics, but should understand the funnel.

Important events:

- `onboarding_started`
- `onboarding_completed`
- `auth_started`
- `auth_completed`
- `paywall_shown`
- `paywall_dismissed`
- `trial_started`
- `meal_capture_started`
- `meal_analysis_started`
- `meal_analysis_completed`
- `meal_analysis_failed`
- `meal_saved`
- `home_viewed`
- `history_viewed`

### Design Implication

Design should make these moments cleanly observable and separable.

---

## 25. Developer / QA Overlay

Developer overlay is internal only.

### Rules

- Hidden from production users.
- Low visual priority.
- If styled, use a small floating dev chip.
- Do not let QA controls influence consumer UI hierarchy.

---

## 26. Out of Scope for v1

These may influence future IA, but should not complicate v1 designs:

- Manual food database search
- Barcode scanner
- Voice logging
- Saved meals
- Restaurant guidance
- Grocery/fridge scan
- Wearables
- CGM integration
- Labs
- Longevity scoring
- Full clinician export
- Full AI Coach tab

Designs may leave room for these, but should not foreground them in v1.

---

## 27. Component System Checklist

The designer should specify the following components:

### Navigation

- Tab bar states
- Navigation title states
- Sheet templates
- Empty state containers

### Buttons

- Primary button
- Secondary button
- Ghost button
- Destructive button
- Camera hero button
- Library secondary button

### Onboarding

- Option row: default / selected / disabled
- Multi-select chip/row
- Progress indicator
- Fake notification preview
- Plan reveal card

### Meal Logging

- Camera action cluster
- Library action
- Analyzing state
- Error state
- Meal Estimate sheet
- Confidence indicator

### Meal Data

- Calorie display
- Macro chips
- Spike-risk pill
- Spike-risk micro marker
- Rationale card
- Disclaimer text block
- Detected item row
- Edit estimate row

### Home

- Today summary card
- Streak card
- AI insight card
- Recent meal card
- Empty first-log prompt

### History

- Square grid tile
- Tile overlay scrim
- Micro kcal label
- L/M/H marker
- Pressed state
- Delete pattern

### Settings

- Grouped list sections
- Subscription status row
- Restore purchases row
- Sign out row
- Delete account row
- Legal/disclaimer row

---

## 28. Designer Deliverables

### Required

- Figma library with tokens and components
- Light mode screens
- Dark mode screens
- Onboarding flow (19 steps, including calculating + plan reveal)
- Auth
- Paywall + free-mode entry + paywall-after-limit states
- Home dashboard
- Log tab with Camera dominance
- Meal Estimate sheet
- History photo grid
- Meal Detail sheet
- Settings
- Empty states
- Loading states
- Error states
- Accessibility annotations
- Motion notes
- Developer handoff specs

### Must Include

- Reduce Transparency spot checks
- Increase Contrast spot checks
- Dynamic Type samples
- VoiceOver strings for core actions
- History tile overlay legibility examples
- Spike-risk variants
- Camera vs Library hierarchy specs

---

## 29. Final Product Design North Star

The strongest version of Glu AI is:

> A calm glucose-aware meal journal with an AI brain underneath.

The product should make users feel:

- I can log a meal quickly.
- I understand my food better.
- I am not being judged.
- The estimates are useful, not scary.
- I can bring better questions to my clinician.
- Small patterns are becoming visible.

Above all:

> Make the product feel gentle, but make the UX extremely efficient.

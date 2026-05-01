# Glu AI — Design Brief

**Audience:** UI/UX designer, product designer, and engineering team building production-ready iOS designs.  
**Platform:** iOS-first, SwiftUI-native, with Apple platform patterns prioritized.  
**Product:** Glu AI, a photo-first, glucose-aware meal tracker that gives rough calories, macros, and educational spike-risk context from meal photos.  
**Design Direction:** **Native iOS Premium + Pastel Journal**  
**Brand Principle:** **Pastel Precision**

---

## 1. Product Definition

Glu AI is a **photo-first, glucose-aware meal tracker**.

It helps users snap or upload a meal photo, receive AI-assisted estimates, understand nutritional context, and save the meal into a visual history.

Glu AI is not a generic calorie tracker. It is not a medical device. It is not a CGM replacement. It is an educational meal-awareness companion.

### Core Product Promise

> Snap a meal. Understand the estimate. Learn the likely glucose context. Save the pattern.

### What Glu AI Provides

1. Rough calorie estimates
2. Macro estimates
3. Carb context
4. Fiber and added sugar awareness
5. Educational spike-risk estimates
6. AI-generated meal rationale
7. Editable food/portion assumptions
8. A photo-first meal history

### What Glu AI Must Not Claim

Glu AI must not diagnose, prescribe, treat, or guarantee medical outcomes.

The product should consistently use language such as:

- Educational only
- Not medical advice
- Rough estimate
- Estimated
- Spike-risk estimate
- Based on visible portions
- Talk to your clinician

---

## 2. Brand Strategy

### Brand Essence

Glu AI should feel like:

> A calm glucose-aware meal journal with an AI brain underneath.

The user should feel:

- “I understand my food better.”
- “I am not being judged.”
- “This app makes logging easier.”
- “The estimates are useful, not scary.”
- “My meal patterns are becoming visible.”
- “I can bring better questions to my clinician.”

### Brand Personality

| Attribute | Meaning in UI |
|---|---|
| Calm | Soft surfaces, gentle colors, low-noise screens |
| Intelligent | AI insights, clear estimates, confidence states |
| Trustworthy | Native iOS patterns, readable data, honest uncertainty |
| Nourishing | Pastel warmth, food-adjacent accents, welcoming copy |
| Precise | Strong hierarchy, legible numbers, structured components |
| Non-judgmental | No shame language, no aggressive warning states |
| Premium | High craft, restrained motion, polished production screens |

### Design Philosophy

> The brand may feel like watercolor. The UX must behave like a precision tool.

The interface can feel soft, airy, and pastel, but the functional layer must be crisp, fast, structured, accessible, and production-ready.

---

## 3. Visual Direction

### Chosen Direction

**Native iOS Premium + Pastel Journal**

This means the app should combine:

1. **Native iOS Premium**
   - SF Pro typography
   - Native navigation patterns
   - SwiftUI-friendly components
   - Clean hierarchy
   - Standard sheets, tab bars, forms, controls
   - Strong accessibility
   - Production-ready polish

2. **Pastel Journal**
   - Creamy vanilla backgrounds
   - Powder blue dashboard surfaces
   - Mint, seafoam, apricot, lemon chiffon, blush, lavender accents
   - Soft rounded cards
   - Gentle progress visuals
   - Meal-photo diary feel
   - Calm AI insight cards

### What It Should Feel Like

A breath of fresh air compared to stressful dieting apps.

The app should feel like a calm place to log and reflect, not a tool that scolds the user.

### What It Should Not Feel Like

- Generic green health app
- Harsh diet tracker
- Medical dashboard
- Gym bro macro logger
- Spreadsheet of food entries
- Childish pastel toy
- Overly decorative wellness journal

The right balance is:

> Soft enough to feel emotionally safe. Precise enough to feel trustworthy.

---

## 4. Color System

The color system should be pastel-first, with small and precise semantic signals.

### Core Palette

| Role | Color Direction | Suggested Hex | Primary Usage |
|---|---|---:|---|
| Base Background | Creamy vanilla | `#FFF8ED` | Global app background |
| Dashboard Surface | Powder blue | `#EAF5FF` | Home / Today surfaces |
| Secondary Surface | Soft mint | `#EAF8F0` | Supporting wellness cards |
| Elevated Card | Warm ivory | `#FFFCF6` | Cards, forms, sheets |
| Primary Trust Anchor | Calm teal | `#0A7A6A` | Main CTAs, key numerals |
| Primary Soft Wash | Pale teal | `#E6F5F3` | Selected states, subtle fills |
| Hydration / Greens | Seafoam | `#A8E6CF` | Completion, hydration, greens |
| Protein | Apricot | `#FFD3B6` | Protein macro |
| Fats | Lemon chiffon | `#FFF4B8` | Fat macro |
| Carbs / Energy | Soft peach | `#FFE1C7` | Carbs and energy |
| AI / Insight | Lavender | `#D9C7F7` | AI cards, coach surfaces |
| Secondary Accent | Periwinkle | `#BFC7F7` | Secondary highlights |
| Celebration | Blush pink | `#F8C8DC` | Milestones, gentle success |
| Primary Text | Muted slate plum | `#353145` | Main text |
| Secondary Text | Dusty lavender gray | `#7A748A` | Subtext and metadata |
| Divider | Soft mist | `#EAE4DA` | Dividers and outlines |
| Error | Muted rose | `#D97A8A` | True errors only |

### Semantic Spike-Risk Palette

Spike-risk colors must be clear but not alarming.

| Spike-Risk Estimate | Color Direction | Suggested Hex | Treatment |
|---|---|---:|---|
| Low | Soft mint green | `#6FD6A5` | Small pill/dot + label |
| Medium | Soft amber | `#E8A94D` | Small pill/dot + label |
| High | Muted rose | `#D97A8A` | Small pill/dot + label |

### Color Rules

1. Use creamy vanilla as the main base.
2. Use powder blue for the Home / Today dashboard atmosphere.
3. Use teal as the main trust/action color, not as a heavy brand wash everywhere.
4. Use pastel macro colors consistently.
5. Use spike-risk colors sparingly.
6. Avoid large red or orange panels.
7. Do not use color alone to communicate spike risk.
8. Do not use pastel colors for primary body text.
9. Primary text should remain dark, readable, and accessible.
10. High spike-risk should feel informative, not frightening.

### Forbidden Visual Pattern

Do not create a dashboard where meals are loudly marked with red/orange “danger” states.

Glu AI should inform, not alarm.

---

## 5. Typography

Use **SF Pro** as the default typeface.

### Type Scale

| Token | Size / Weight | Usage |
|---|---:|---|
| Display | 48 Bold | Hero stats, calorie estimate, plan tier |
| Title | 28 Bold | Main screen titles |
| Title 2 | 22 Semibold | Section titles |
| Headline | 17 Semibold | Card titles, list titles |
| Body | 17 Regular | Rationale, descriptions, paragraphs |
| Subhead | 15 Regular | Supporting text |
| Footnote | 13 Regular | Disclaimers, errors, helper text |
| Caption | 11 Regular | Micro labels, timestamps, grid overlays |

### Typography Rules

- Large numbers must be highly legible.
- Meal estimates must be easy to scan.
- Avoid ultra-light text weights.
- Avoid pastel-colored body text.
- Use dark muted slate/plum for text.
- Use lavender/periwinkle for accents, not core readability.
- Support Dynamic Type.
- Use Title Case for grouped list section headers where appropriate.
- Avoid ALL CAPS section labels unless used as tiny metadata.

---

## 6. Layout Principles

### Global Layout Rhythm

| Element | Spec |
|---|---:|
| Screen horizontal padding | 24pt |
| Card corner radius | 16pt |
| Primary button radius | 14pt |
| Option row padding | 16pt |
| Minimum tap target | 44×44pt |
| Sheet content padding | 20–24pt |
| History grid gap | 2–4pt |
| History tile aspect ratio | 1:1 |

### Core Layout Rules

1. One primary action per screen.
2. Use progressive disclosure.
3. Meal photos should be prominent.
4. Nutrition data should be structured, not dense.
5. Important numbers should be visible without scrolling.
6. Secondary details can live in expandable areas.
7. Keep controls thumb-friendly.
8. Design for late-night logging and one-handed use.
9. Empty states should be useful and action-oriented.
10. Avoid visual clutter.

### Visual Hierarchy

The hierarchy should usually be:

1. User task
2. Meal photo or primary estimate
3. Key action
4. Supporting nutrition data
5. AI rationale
6. Disclaimer / legal copy

---

## 7. Apple Platform Alignment

Glu AI should feel native to current Apple platforms.

### Principles

- Use native iOS navigation and sheet patterns.
- Use `TabView`, `NavigationStack`, grouped lists, standard sheets, and standard controls where possible.
- Let system chrome feel Apple-native.
- Avoid custom navigation bars unless absolutely necessary.
- Do not fight the system tab bar or sheet behavior.
- Avoid decorative glass effects over dense nutrition content.

### Liquid Glass / System Chrome Direction

Where current SDKs support Apple’s Liquid Glass-era chrome:

- Let tab bars, navigation bars, sheets, toolbars, and menus inherit system treatment.
- Keep content surfaces calm and readable.
- Do not layer glass on glass.
- Use glass-like effects only for floating chrome or lightweight controls.
- Do not place dense numeric health-adjacent content on transparent glass without contrast QA.

### Accessibility Matrix

All high-fidelity screens should be checked for:

- Reduce Transparency
- Reduce Motion
- Increase Contrast
- Large Dynamic Type
- VoiceOver labels
- Dark mode

---

## 8. Main Product Flow

### Funnel

```text
Onboarding
  → Auth
  → Paywall
  → If subscribed: full access
  → If dismissed: free mode with 5 meal analyses
  → After 5 free analyses used: paywall returns
  → Main app
```

### Paywall Strategy

The paywall should appear after personalized onboarding and auth.

The goal is to show the paywall after the user has:

1. Understood the product
2. Shared their context
3. Seen a personalized plan
4. Built enough intent to consider paying

If the user dismisses the paywall, they should enter a limited free mode with **5 meal analyses**.

### Free Mode

Free mode gives users:

- 5 total meal photo analyses
- Meal estimate view
- Ability to save analyzed meals
- Basic history from those meals
- Clear remaining analysis count

After the fifth analysis is used, the paywall appears again.

### Free Mode Messaging

Use calm, transparent copy.

Examples:

> You have 4 free meal analyses left.

> Try Glu with 5 meal analyses. Upgrade anytime for unlimited logging.

> You’ve used your 5 free meal analyses. Start Glu Gold to keep analyzing meals.

Do not make this feel like a trap. Make the limit visible and predictable.

---

## 9. Monetization and Paywall UX

### Product Rule

The paywall can be conversion-oriented, but it must not be manipulative or fear-based.

### Paywall Moment

The paywall comes after:

1. Onboarding
2. Plan reveal
3. Auth

The user has already created intent and context.

### If User Subscribes

Grant full access.

### If User Dismisses

Let the user into free mode with 5 meal analyses.

### Paywall Header Direction

Possible copy:

> Your spike-smart plan is ready

Subcopy:

> Start Glu Gold for unlimited meal analysis, editable estimates, saved history, and AI-powered meal context.

### Free Trial / Dismiss Copy

If a close/dismiss option exists, it should be honest.

Possible copy:

> Continue with 5 free analyses

or

> Try 5 meals first

Avoid using an unlabeled X that behaves unexpectedly.

### After Free Limit Is Used

Show paywall with context:

> You’ve used your 5 free meal analyses

Subcopy:

> Upgrade to Glu Gold to continue analyzing meals and building your meal history.

### Paywall Design Requirements

- High-fidelity production screen
- Native iOS premium feel
- Strong value proposition
- Calm pastel visuals
- Clear subscription options
- Restore purchases
- Terms and privacy links
- “Try 5 meals first” option if the user has not used free mode
- No fear language
- No medical claims

---

## 10. Onboarding Strategy

### Important Direction

Use a **longer, conversion-oriented onboarding**.

Do not reduce onboarding to a short generic setup flow.

The onboarding should feel like a guided personalization ritual that increases trust, relevance, and willingness to pay.

### Onboarding Purpose

Every onboarding step must do at least one of the following:

1. Collect meaningful personalization
2. Increase perceived product relevance
3. Build trust
4. Explain the glucose-aware value prop
5. Reduce anxiety around tracking
6. Prepare the user for the paywall
7. Make the final plan feel earned

If a step does none of these, cut it.

### Onboarding Feel

The onboarding should feel:

- Light
- Calm
- Personal
- Premium
- Purposeful
- Fast despite being long

It should not feel like a medical intake form.

### Onboarding UX Rules

- One question per screen.
- One primary action.
- Soft progress indicator.
- Clear back navigation.
- Visually satisfying option rows.
- Short, reassuring helper copy.
- No dense paragraphs.
- No medical fear language.
- Keep the user moving.

### Required Long Onboarding Flow

This flow intentionally preserves the conversion logic of longer AI health/fitness app onboarding.

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

Title:

> Glu AI

Subtitle:

> Snap meals. Understand calories, macros, and glucose context — educational only.

CTA:

> Get Started

#### Promise Step

Avoid unsupported claims like:

> Most members build a steadier logging habit in 3 weeks.

Use:

> Small logs compound. In a few weeks, your meal patterns become easier to see.

or

> Glu is designed to help you build a steadier logging habit without making tracking feel heavy.

#### Calculating Step

Title:

> Creating your spike-smart plan…

Status lines:

- Balancing your goals…
- Pairing tips with your meal style…
- Preparing your starting plan…

Use a tasteful animation. Do not fake overly technical analysis.

#### Plan Reveal

Title:

> Your starting plan is ready

Subtitle:

> Educational only — not medical advice.

Tier labels:

| Tier | Trigger |
|---|---|
| Gentle | User chooses gentle nudges |
| Balanced | Default |
| Focused | Type 1, direct tips, or high-awareness profile |

Avoid the tier label “Careful.”

Plan reveal should make the user feel understood, not diagnosed.

### Optional Multi-Select Rule

For optional multi-select screens:

- User can continue without selecting.
- If “None of these” is selected, deselect all other options.
- If another option is selected, deselect “None of these.”

---

## 11. Auth Screen

### Purpose

Create a durable account before payment and app access.

### Screen Requirements

| Element | Direction |
|---|---|
| Title | Save your plan |
| Body | Sign in to keep your plan and meal history synced. |
| Primary | Sign in with Apple |
| Secondary | Continue with Google only if implemented |
| QA-only | Mock account hidden in production |
| Error | Muted rose footnote |

### Design Notes

- Use native Sign in with Apple button.
- Keep the screen minimal.
- Do not expose Supabase in consumer-facing copy unless needed.
- Maintain the pastel premium visual direction.
- Make this feel like saving progress, not a bureaucratic step.

---

## 12. Home Tab

### Purpose

Home is the calm daily awareness dashboard.

It should help users understand today in a few seconds.

### Home Should Answer

1. What have I logged today?
2. What are the rough estimated calories and carbs?
3. What is the spike-risk pattern today?
4. What should I do next?

### Structure

| Section | Content |
|---|---|
| Greeting | Time-based greeting, first name if available |
| Header | Today |
| Free mode counter | Only for free users, e.g. “3 analyses left” |
| Today summary card | Meals logged, estimated calories, estimated carbs |
| Spike-risk summary | Low / Medium / High distribution |
| Streak card | Logging streak |
| AI insight card | One calm contextual insight |
| Recent meals | Up to 5 recent meal cards |
| Empty state | Prompt to log first meal |

### Visual Direction

- Powder blue atmosphere
- Creamy vanilla cards
- Soft rounded surfaces
- Calm teal key numbers
- Small spike-risk indicators
- Gentle AI lavender card

### Empty State Copy

Title:

> Log your first meal

Subtitle:

> Snap a photo and Glu will estimate calories, macros, and spike-risk context.

CTA:

> Open Camera

### Recent Meal Interaction

Recent meal cards must be tappable.

Tap opens Meal Detail sheet.

---

## 13. Log Tab

### Purpose

The Log tab is the product’s heartbeat.

The user should immediately understand:

> Take a meal photo now.

### Camera Dominance

Camera must be visually dominant over Library.

Do not design Camera and Library as equal peers.

| Action | Treatment |
|---|---|
| Camera | Primary, dominant, larger, brand-filled or glassProminent, strong icon |
| Library | Secondary, quieter, smaller or less visually weighted |

### Screen Content

| Element | Copy / Direction |
|---|---|
| Title | Log |
| Heading | Log a meal |
| Subcopy | Snap or pick a meal photo. Glu AI returns rough calories, macros, and a spike-risk estimate — educational only. |
| Primary | Camera |
| Secondary | Library |
| Free mode counter | “4 analyses left” if applicable |
| Loading | Analyzing meal… |
| Error | Calm recovery copy |

### Free Analysis Count

In free mode, show the remaining analysis count near the capture controls.

Examples:

> 4 free analyses left

> You have 1 analysis left

After the user uses the fifth free analysis, show the paywall before allowing another analysis.

### Accessibility

VoiceOver order:

1. Camera — “Take photo. Scan meal with camera.”
2. Library — “Choose meal photo from library.”

---

## 14. Analyzing State

### Purpose

Bridge the wait between photo selection and estimate result.

### Requirements

Show:

- Meal photo preview
- Calm loading animation
- Status copy
- Optional educational note
- No fake precision

### Copy

Primary:

> Analyzing meal…

Rotating secondary lines:

- Estimating visible portions…
- Looking at carbs, fiber, and sugar…
- Preparing your meal estimate…

### Motion

Use subtle motion only.

Avoid dramatic scanning lasers, medical-device visuals, or alarm-like effects.

---

## 15. Meal Estimate Sheet

### Title

Use:

> Meal Estimate

Do not use the generic title “Result.”

### Purpose

Show the AI estimate with clarity, humility, and editability.

### Required Elements

1. Meal photo
2. Estimated calories
3. Spike-risk estimate
4. Macro breakdown
5. Confidence state
6. Detected foods / assumptions
7. Rationale
8. Disclaimer
9. Save action
10. Edit action
11. Discard action

### Visual Hierarchy

1. Photo
2. Calories
3. Spike-risk pill
4. Macros
5. Detected foods / assumptions
6. AI rationale
7. Disclaimer
8. Actions

### Editable Estimates Are Required in V1

This is non-negotiable.

Users must be able to correct the AI before saving.

At minimum, design must support:

- Edit portion size
- Correct detected foods
- Remove incorrect food item
- Add missing item
- Adjust quantity
- Save corrected estimate

### Editable Food Row

Each detected item row should support:

- Food name
- Estimated quantity
- Calories
- Macro preview, if available
- Edit affordance
- Remove affordance

### Edit Estimate Flow

Possible interaction:

1. Tap “Edit estimate”
2. Sheet expands or pushes to edit mode
3. User adjusts items and portions
4. Calories/macros update
5. User saves changes
6. Returns to Meal Estimate

### Confidence Pattern

Use honest confidence labels.

Examples:

> Confidence: Medium  
> Based on visible portions and common serving sizes. Adjust if needed.

or

> Confidence: Low  
> Some foods were partially hidden. Review before saving.

Do not hide uncertainty.

### Save Meal

Primary CTA:

> Save meal

### Discard

Secondary/cancel:

> Discard

If user has edited details and taps discard, confirm before losing changes.

---

## 16. Meal Detail Sheet

### Purpose

Show a saved meal in full detail.

### Title

> Meal

### Content

- Full meal photo
- Estimated calories
- Spike-risk estimate
- Macros
- Confidence, if stored
- Detected items
- Rationale
- Timestamp
- Disclaimer

### Actions

| Action | Treatment |
|---|---|
| Done | Dismiss |
| Edit estimate | Secondary |
| Delete meal | Destructive |

### Delete Confirmation

Title:

> Delete meal?

Body:

> This removes the meal from your history.

Actions:

- Cancel
- Delete

---

## 17. History Tab

### Purpose

A visual meal archive.

History should feel like:

> My meal photo diary.

Not:

> A spreadsheet of food logs.

### Visual Direction

Use an Instagram-style profile grid:

- Square tiles
- 3 columns on iPhone
- Minimal gaps
- Photo fills the tile
- Lightweight overlays
- Fast scanning

### Tile Overlay Requirements

Each tile shows:

1. Micro calorie label, e.g. “520 kcal”
2. Spike-risk marker:
   - L / M / H
   - Small dot or small pill
   - Color plus label, never color alone

### Overlay Treatment

Acceptable options:

- Bottom gradient scrim
- Small blurred pill
- Subtle dark overlay only behind text

Avoid:

- Loud red bars
- Large warning labels
- Overly dense tile metadata

### Interaction

Tap tile → Meal Detail sheet.

### Delete Pattern

Recommended v1:

- Delete from Meal Detail sheet.
- Optional long-press delete menu later.

### Empty State

Title:

> No meals yet

Subtitle:

> Saved meals from the Log tab appear here.

CTA:

> Log a meal

---

## 18. Settings Tab

### Structure

Use grouped list style.

| Section | Contents |
|---|---|
| Account | User identity, sign out |
| Subscription | Glu Gold status, restore purchases, billing help |
| Free mode | Remaining free analyses, if applicable |
| Preferences | Reminders, tip directness |
| Health context | Glucose-awareness profile, optional carb target |
| Legal | Educational disclaimer, privacy, terms |
| Developer | QA only, hidden in production |

### Subscription States

Show:

- Glu Gold active
- Trial active
- Free mode, analyses remaining
- Free limit used

### Delete Account

If server deletion is not implemented, be explicit.

Title:

> Delete account?

Body:

> This will delete local app data. Server-side account deletion is not yet available in this build.

Actions:

- Cancel
- Delete local data

---

## 19. AI Insight System

AI appears primarily as insight cards, not necessarily as a root tab in v1.

### Locations

- Home
- Meal Estimate
- Meal Detail
- Future weekly recap
- Future Coach tab

### AI Tone

The AI should sound:

- Calm
- Specific
- Practical
- Respectful
- Honest about uncertainty
- Non-judgmental

### Good Insight Copy

> This meal looks higher in fast-digesting carbs and lower in fiber. Pairing a similar meal with protein or vegetables may help make it steadier.

### Bad Insight Copy

> This meal is bad for your glucose.

### AI Design Pattern

Insight cards should use:

- Lavender/periwinkle wash
- Soft iconography
- Short headline
- One practical suggestion
- Optional “Why?” expansion

---

## 20. Copy and Tone Guidelines

### Core Tone

- Calm
- Observational
- Precise
- Supportive
- Practical
- Non-alarmist

### Use

- “estimated”
- “rough estimate”
- “may”
- “could”
- “based on visible portions”
- “educational only”
- “not medical advice”
- “talk to your clinician”

### Avoid

- “safe”
- “unsafe”
- “bad food”
- “failed”
- “cheat meal”
- “danger”
- “control your diabetes”
- “medical result”
- “health zone”
- “prescription”
- guaranteed outcome claims

### Preferred Language

| Instead of | Use |
|---|---|
| High health zone | High spike-risk estimate |
| This is bad | This may be higher spike-risk |
| You failed your goal | Today went above target |
| Cheat meal | Treat meal or special meal |
| Medical result | Educational estimate |
| Control your glucose | Understand glucose context |

---

## 21. Component System

The designer must create a production-ready Figma component system.

### Navigation Components

- Tab bar states
- Navigation title states
- Sheet templates
- Modal templates
- Empty state containers

### Button Components

- Primary button
- Secondary button
- Ghost button
- Destructive button
- Camera hero button
- Library secondary button
- Paywall CTA
- Free mode CTA

### Onboarding Components

- Single-choice option row
- Multi-choice option row
- Optional multi-choice row
- Selected state
- Disabled state
- Progress indicator
- Plan reveal card
- Fake notification preview
- Calculating state

### Paywall Components

- Plan card
- Feature row
- Trial/subscription option
- Restore purchases
- Terms/privacy footer
- “Try 5 meals first” button
- Free limit used message

### Meal Logging Components

- Camera action cluster
- Library action
- Free analysis counter
- Analyzing state
- Error state
- Meal Estimate sheet

### Meal Estimate Components

- Calorie display
- Spike-risk pill
- Macro chips
- Confidence indicator
- Detected food row
- Portion editor
- Add item row
- Rationale card
- Disclaimer block
- Save/discard action cluster

### Home Components

- Today summary card
- Streak card
- Spike-risk distribution
- AI insight card
- Recent meal card
- Empty first-log prompt

### History Components

- Square grid tile
- Tile overlay scrim
- Micro kcal label
- L/M/H spike marker
- Pressed state
- Empty state

### Settings Components

- Grouped list row
- Subscription status row
- Free mode counter row
- Restore purchases row
- Sign out row
- Delete account row
- Legal row

### States Required

Each relevant component should include:

- Default
- Pressed
- Selected
- Disabled
- Loading
- Empty
- Error
- Success
- Dark mode
- Increased contrast where relevant

---

## 22. Motion and Haptics

Motion should feel soft, native, and useful.

### Use

- Gentle card expansion
- Native sheet transitions
- Smooth progress fill
- Calm analyzing animation
- Subtle success haptic after meal saved
- Soft milestone notification
- Small state transitions for option selection

### Avoid

- Confetti explosions
- Fireworks
- Bouncy cartoon motion
- Alarm-like high-risk animations
- Slow blocking animations
- Overdesigned AI scanning effects

### Milestone Notification

Style:

- Blush pink surface
- Seafoam checkmark
- Short supportive copy

Example:

> Nice rhythm. You logged 7 meals this week.

---

## 23. Accessibility

Accessibility is mandatory.

### Requirements

- Dynamic Type support
- VoiceOver labels
- Minimum 44×44pt tap targets
- Spike-risk labels include text, not color alone
- History tile overlays readable on busy images
- Reduce Transparency support
- Reduce Motion support
- Increase Contrast testing
- Dark mode support
- High-contrast text on pastel surfaces

### VoiceOver Examples

Camera:

> Take photo. Scan meal with camera.

Library:

> Choose meal photo from library.

Spike-risk pill:

> Spike-risk estimate: medium. Educational estimate only.

Meal tile:

> Meal photo. 520 calories. Medium spike-risk estimate. Logged yesterday at 8:15 PM.

Free mode counter:

> Three free meal analyses remaining.

---

## 24. Dark Mode

Dark mode should feel premium, calm, and evening-friendly.

### Direction

Use:

- Deep charcoal
- Midnight blue
- Muted plum
- Soft lavender glows
- Pastel accents with reduced saturation
- Cream/mist text
- Gentle edge highlights

Avoid:

- Pure black everywhere
- Neon colors
- Cyberpunk glow
- Harsh white text blocks
- Large red/orange panels

Dark mode should feel like a quiet evening nutrition journal.

---

## 25. Error and Edge States

Errors should feel recoverable.

### Meal Analysis Failed

Copy:

> We couldn’t analyze this photo. Try a clearer image or choose another one.

Actions:

- Try again
- Choose from Library

### Low Confidence

Copy:

> I’m not fully sure about this estimate. Review and adjust before saving.

### No Food Detected

Copy:

> I couldn’t clearly identify the meal. Try another angle with the food centered.

### Free Limit Used

Copy:

> You’ve used your 5 free meal analyses.

CTA:

> Continue with Glu Gold

Secondary:

> Maybe later

### High Spike-Risk Estimate

Copy:

> Estimated high spike risk. This is educational context, not a medical reading.

Optional action:

> See steadier meal ideas

Do not use fear copy.

---

## 26. App Icon Direction

The app icon should align with the pastel leaf identity.

### Requirements

- 1024×1024 source artwork
- No text
- Pastel tropical leaf symbol
- Rounded-square masking handled by system
- Layered artwork suitable for Apple Icon Composer
- Appearances:
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

## 27. High-Fidelity Design Requirement

Do not produce low-fidelity wireframes as the main deliverable.

The design ask is:

> High-fidelity, production-ready iOS screens from the start.

### Required Quality Bar

Screens should include:

- Final visual style
- Realistic copy
- Realistic spacing
- Realistic content states
- Native iOS patterns
- Component consistency
- Light mode
- Dark mode
- Accessibility annotations
- Edge states
- Handoff specs

This is not a moodboard or exploratory concept exercise.

The designer should deliver polished screens that engineering can build against.

---

## 28. Required Screen Deliverables

### Onboarding

All 19 onboarding screens:

1. Welcome
2. Diabetes/glucose-awareness profile
3. Carb awareness
4. Prior logging experience
5. Barriers
6. Promise/value bridge
7. Goals
8. Carb target comfort
9. Eating pattern
10. Tip directness
11. Food focus
12. Optional health context
13. Social proof/value bridge
14. Accountability
15. Aspirations
16. Notification priming
17. Attribution
18. Calculating
19. Plan reveal

### Auth and Monetization

20. Auth
21. Paywall
22. Paywall dismissed → free mode entry
23. Free analyses remaining state
24. Free limit used paywall
25. Restore purchases
26. Paywall error state

### Main App

27. Home, empty state
28. Home, populated state
29. Home, free mode state
30. Log tab
31. Log tab with free counter
32. Analyzing state
33. Meal Estimate
34. Edit Estimate
35. Meal saved success state
36. History empty
37. History populated grid
38. Meal Detail
39. Delete confirmation
40. Settings
41. Subscription settings
42. Free mode settings
43. Error states

### Variants

- Light mode
- Dark mode
- Large Dynamic Type sample
- Increased Contrast sample
- Reduce Transparency sample

---

## 29. Developer Handoff Requirements

Designer should provide:

- Figma file
- Design tokens
- Component library
- Light/dark color tokens
- Typography tokens
- Spacing tokens
- Component states
- Interaction notes
- Motion notes
- Accessibility notes
- VoiceOver copy
- Error copy
- App icon exports
- Asset exports
- SwiftUI implementation notes where useful

### Token Handoff

Include tokens for:

- Color
- Typography
- Spacing
- Radius
- Shadow
- Motion
- Button height
- Grid spacing
- Sheet padding

---

## 30. Product Priorities

### Priority 1: Conversion-Ready Onboarding

The onboarding must create perceived personalization and paywall readiness.

### Priority 2: Fast Photo Logging

The Camera path must be obvious, dominant, and fast.

### Priority 3: Editable AI Estimates

Users must be able to correct AI assumptions before saving.

### Priority 4: Calm Meal Awareness

The app must help users understand meals without shame.

### Priority 5: Visual Meal History

History should feel like a photo journal, not a spreadsheet.

---

## 31. Final Design North Star

The strongest version of Glu AI is:

> A premium iOS meal journal where pastel softness meets precise AI nutrition context.

It should feel gentle, but not vague.

It should be beautiful, but not decorative.

It should convert, but not manipulate.

It should educate, but not diagnose.

Above all:

> Make the product feel emotionally safe, commercially sharp, and extremely efficient.

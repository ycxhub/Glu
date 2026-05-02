# Glu AI Spike-Awareness Onboarding

Status: canonical 19-step product artifact for implementation planning
Owner: product
Source of truth: `apps/GluAI/design-doc.md`

This artifact defines the 19-step onboarding rewrite that must exist before coding. This markdown file is the canonical product artifact. Engineering may choose bundled JSON, remote config, or another storage shape later, but the copy, ids, saved fields, skip behavior, and reveal mapping below are the product contract.

If an implementation export exists, such as `onboarding-spike-awareness.json`, it is generated or hand-transcribed from this markdown artifact and must be checked against it. The JSON export is not the source of truth.

## Global Rules

- Length: exactly 19 steps.
- Exact copy: the backticked titles, subtitles, options, CTAs, and reveal templates below are the copy source for implementation.
- Positioning: food freedom plus educational spike awareness.
- UI copy must say "likely spike risk from this meal's composition", not "will this spike me" or any personalized glucose prediction.
- Do not ask for diagnosis, medical conditions, target weight, calorie goals, or weight-loss goals.
- Do not show calorie budgets, calorie targets, "calories remaining", or weight-loss framing in onboarding.
- Use "Educational only, not medical advice" on the welcome and reveal screens.
- Product owns this copy first. Engineering chooses storage after copy approval; bundled JSON is an implementation export, not the source of truth.
- The reveal screen is deterministic. It may assemble the templates below from saved fields, but it must not generate freeform coach copy.
- Selection rules:
  - `singleChoice`: one option required.
  - `multiChoice`: optional only when `allowEmptySelection: true`.
  - `welcome`, `info`, `calculating`, and `planReveal`: no option saved.
  - `notificationPriming`: user can decline notification permission and still continue.
- Skip behavior vocabulary:
  - `none`: no skip affordance.
  - `required`: user must select an option before continuing.
  - `optional; allowEmptySelection: true`: user may continue with no selected options and the saved array is empty.
  - `user may decline OS permission and continue`: notification permission refusal is a valid completion state.

## Saved Profile Fields

Store onboarding answers under an app-owned profile object. Do not infer medical status from any answer.

| Field | Type | Written by |
|---|---|---|
| `onboardingSchemaVersion` | string | global, value `spike-awareness-v1` |
| `completedAt` | ISO timestamp | `reveal` CTA |
| `foodAbundance` | string array | `food_abundance` |
| `carbAwareness` | string | `carb_think` |
| `triedFoodLogging` | string | `tried_log` |
| `loggingBarriers` | string array | `barriers` |
| `goals` | string array | `goals` |
| `carbGuidelineStatus` | string | `carb_guideline_optional` |
| `eatingRhythm` | string | `eat_pattern` |
| `tonePreference` | string | `strictness` |
| `likelyFirstLogs` | string array | `food_focus` |
| `spikeCuriosity` | string array | `spike_curiosity` |
| `accountabilityPreference` | string | `accountability` |
| `aspirations` | string array | `aspirations` |
| `notificationPrompted` | boolean | `notify_prime` |
| `notificationPermissionResult` | enum/string | OS permission result after `notify_prime` |
| `attribution` | string | `attribution` |

## Step Definitions

### 1. `welcome`

- Kind: `welcome`
- Title: `Glu AI`
- Subtitle: `Eat freely. Snap a meal and learn the likely spike risk from this meal's composition. Educational only, not medical advice.`
- Options: none
- CTA: `Get Started`
- Skip behavior: none
- Saved field: none

### 2. `food_abundance`

- Kind: `multiChoice`
- Title: `What does your week of eating look like?`
- Subtitle: `Pick the places food shows up most. This helps Glu explain real meals, not perfect diet days.`
- Options: `Home meals`, `Delivery`, `Restaurants`, `Snacks`, `Desserts`, `Sweet drinks`, `Coffee/cafe`, `Social meals`, `Mixed`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `foodAbundance`
- Reveal mapping: `food_world`

### 3. `carb_think`

- Kind: `singleChoice`
- Title: `How often do you think about carbs when you eat?`
- Subtitle: none
- Options: `Rarely`, `Sometimes`, `Most meals`, `Almost every meal`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `carbAwareness`
- Reveal mapping: `awareness_baseline`

### 4. `tried_log`

- Kind: `singleChoice`
- Title: `Have you tried food or nutrition apps before?`
- Subtitle: none
- Options: `Yes, and I stopped`, `Yes, I still use one`, `Not really`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `triedFoodLogging`
- Reveal mapping: `logging_style`

### 5. `barriers`

- Kind: `multiChoice`
- Title: `What usually gets in the way?`
- Subtitle: `Pick any that feel familiar.`
- Options: `Too much manual entry`, `I forget to log`, `Estimates feel off`, `Apps feel clinical`, `Apps feel restrictive`, `I do not want calorie goals`, `I am not sure what to look for`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `loggingBarriers`
- Reveal mapping: `friction_reduction`

### 6. `promise`

- Kind: `info`
- Title: `No food rules`
- Subtitle: `Glu is built for food freedom: snap what you ate, see the likely spike risk from this meal's composition, then review rough nutrition and one steadier move for the same meal.`
- Options: none
- CTA: `Continue`
- Skip behavior: none
- Saved field: none

### 7. `goals`

- Kind: `multiChoice`
- Title: `What are you hoping Glu helps with?`
- Subtitle: `Optional. Pick what resonates.`
- Options: `Understand likely spike risk`, `Make favorite meals steadier`, `Notice food patterns`, `Save meal estimates`, `Feel less surprised by energy dips`, `Keep eating flexible`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `goals`
- Reveal mapping: `primary_goal`

### 8. `carb_guideline_optional`

- Kind: `singleChoice`
- Title: `Do you use any carb target or guideline today?`
- Subtitle: `This is optional context, not a goal Glu will enforce.`
- Options: `I use a specific target`, `I use loose rules`, `I do not use a target`, `Not sure`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `carbGuidelineStatus`
- Reveal mapping: `guideline_context`

### 9. `eat_pattern`

- Kind: `singleChoice`
- Title: `What is your usual eating rhythm?`
- Subtitle: none
- Options: `3 meals`, `Smaller meals or grazing`, `Late meals are common`, `Irregular schedule`, `It changes a lot`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `eatingRhythm`
- Reveal mapping: `rhythm_context`

### 10. `strictness`

- Kind: `singleChoice`
- Title: `How should Glu phrase suggestions?`
- Subtitle: none
- Options: `Gentle and casual`, `Balanced and practical`, `Direct, but never restrictive`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `tonePreference`
- Reveal mapping: `tone`

### 11. `food_focus`

- Kind: `multiChoice`
- Title: `What will you probably snap first?`
- Subtitle: `Choose the meals or moments you expect to log.`
- Options: `Restaurant meals`, `Takeout`, `Home cooking`, `Packaged snacks`, `Drinks`, `Desserts`, `Fried snacks`, `Mixed plates`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `likelyFirstLogs`
- Reveal mapping: `first_logs`

### 12. `spike_curiosity`

- Kind: `multiChoice`
- Title: `What do you most want to make steadier?`
- Subtitle: `Choose any meals or moments Glu should pay attention to.`
- Options: `Rice/bread/pasta`, `Sweet drinks`, `Desserts`, `Fried snacks`, `Late dinners`, `Large portions`, `Coffee/cafe orders`, `None right now`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `spikeCuriosity`
- Reveal mapping: `steadier_focus`

### 13. `social_proof`

- Kind: `info`
- Title: `Photos become patterns`
- Subtitle: `After a few logs, Glu helps you notice which meal compositions tend to look steadier and why.`
- Options: none
- CTA: `Continue`
- Skip behavior: none
- Saved field: none

### 14. `accountability`

- Kind: `singleChoice`
- Title: `What helps you come back?`
- Subtitle: none
- Options: `Gentle reminders`, `A weekly recap`, `Seeing my saved meals`, `I will open it when I need it`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `accountabilityPreference`
- Reveal mapping: `return_loop`

### 15. `aspirations`

- Kind: `multiChoice`
- Title: `In the next month, I want to...`
- Subtitle: `Optional. Pick what fits.`
- Options: `Understand my favorite meals`, `Learn which swaps help`, `Stop guessing from vibes`, `Keep food flexible`, `Build a small meal history`
- CTA: `Continue`
- Skip behavior: optional; `allowEmptySelection: true`
- Saved field: `aspirations`
- Reveal mapping: `month_one`

### 16. `notify_prime`

- Kind: `notificationPriming`
- Title: `Reminders without pressure`
- Subtitle: `Choose gentle nudges for meal logging. You can turn them off anytime.`
- Options: none
- CTA: `Enable Reminders`
- Secondary CTA: `Not Now`
- Skip behavior: user may decline OS permission and continue
- Saved fields: `notificationPrompted`, `notificationPermissionResult`
- Reveal mapping: `return_loop`

### 17. `attribution`

- Kind: `singleChoice`
- Title: `How did you hear about Glu?`
- Subtitle: none
- Options: `TikTok`, `Instagram`, `Friend or family`, `App Store`, `Google`, `X/Twitter`, `Other`
- CTA: `Continue`
- Skip behavior: required
- Saved field: `attribution`
- Reveal mapping: none

### 18. `calculating`

- Kind: `calculating`
- Title: `Building your spike-awareness plan...`
- Subtitle: `Glu is shaping your first plan around your eating patterns, favorite contexts, and the meals you want to make steadier.`
- Options: none
- CTA: `Continue`
- Skip behavior: none
- Saved field: none

### 19. `reveal`

- Kind: `planReveal`
- Title: `Your spike-awareness plan is ready`
- Subtitle: `Start with 5 free food analyses. Each photo can save a rough estimate, a lesson on likely spike risk from this meal's composition, and one steadier move. Educational only, not medical advice.`
- Options: none
- CTA: `Save my plan`
- Skip behavior: none
- Saved fields: `completedAt`, `onboardingSchemaVersion`

## Reveal Mapping

The reveal screen may show the following dynamic bullets or cards. Use the exact templates below and omit any card whose source field is empty unless a fallback is specified.

| Reveal key | Source fields | Exact copy rule |
|---|---|---|
| `food_world` | `foodAbundance` | If non-empty: `Your real-life food context: {foodAbundanceList}. Glu will keep estimates grounded in the way you actually eat.` Fallback: `Glu will keep estimates grounded in the way you actually eat.` |
| `awareness_baseline` | `carbAwareness` | `Your carb-awareness baseline: {carbAwarenessLowercase}. Glu will explain meal composition without turning it into rules.` |
| `logging_style` | `triedFoodLogging` | `Your logging context: {triedFoodLoggingLowercase}. Glu keeps the core action to a photo and review.` |
| `primary_goal` | `goals` | If non-empty: `Your focus: {goalsList}.` Fallback: `Your focus: understand meals without turning food into rules.` |
| `guideline_context` | `carbGuidelineStatus` | If `I use a specific target` or `I use loose rules`: `Any carb guideline stays context only; Glu will not enforce calorie or carb targets.` Otherwise: `No target needed; Glu starts from the meal photo.` |
| `rhythm_context` | `eatingRhythm` | `Your rhythm: {eatingRhythmLowercase}. Glu should fit the way meals actually happen.` |
| `steadier_focus` | `spikeCuriosity` | If non-empty and not only `None right now`: `We'll pay extra attention to making {spikeCuriosityList} steadier.` Fallback: `We'll start by helping you notice meal patterns before changing anything.` |
| `friction_reduction` | `loggingBarriers` | If `I do not want calorie goals` or `Apps feel restrictive` is selected: `No calorie goals. No remaining-calorie targets. Just photo-first awareness and steadier moves.` Otherwise, if non-empty: `Glu will keep logging lightweight around: {loggingBarriersList}.` |
| `tone` | `tonePreference` | `Suggestions will stay {tonePreferenceLowercase}, with no food shame or restrictive commands.` |
| `first_logs` | `likelyFirstLogs` | If non-empty: `Good first photos: {likelyFirstLogsList}.` |
| `return_loop` | `accountabilityPreference`, `notificationPermissionResult` | If reminders selected or permission granted: `Gentle reminders can help you build a small meal history.` Otherwise: `Open Glu whenever you want a quick read on a meal.` |
| `month_one` | `aspirations` | If non-empty: `Month-one aim: {aspirationsList}.` Otherwise omit this card. |

Formatting rules:

- Render reveal cards in this order when their source fields exist: `food_world`, `primary_goal`, `steadier_focus`, `friction_reduction`, `tone`, `first_logs`, `return_loop`, `month_one`, then any remaining mapped context.
- Join lists with commas and `and` before the final item.
- Never generate a calorie target, calorie budget, weight-loss target, glucose prediction, diagnosis, or medical recommendation in the reveal.
- Never claim Glu knows the user's glucose response. Refer only to the meal's composition and saved photo estimates.

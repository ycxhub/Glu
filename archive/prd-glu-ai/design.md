# Design System — Glu AI

## Design principles

1. **Native iOS first** — SF Pro, system materials, standard sheets and navigation. The app should feel trustworthy and calm, like a serious health companion, not a toy.
2. **One primary action per screen** — Especially in onboarding and on the capture tab: one obvious next step.
3. **Photos are first-class** — Meal thumbnails drive history and home; layouts assume square or 4:3 meal photos with readable overlays for spike-risk chips.
4. **Calm clarity over alarm** — Spike-risk uses semantic color (green / amber / red) sparingly; never panic copy. Pair risk with **what to consider next** (fiber, portion), not fear.
5. **Haptics on success paths** — Light impact on save, success on completed analysis; avoid haptics on errors (already stressful).

## Color palette

**Primary**
- Brand: `#0A7A6A` (deep teal — clinical trust without hospital sterility)
- Brand-muted: `#E6F5F3` (light teal wash for cards and selected chips)

**Neutrals**
- Background: `#FFFFFF` (light) / `#000000` (dark)
- Surface: `#F5F5F7` (light) / `#1C1C1E` (dark)
- Text-primary: `#000000` (light) / `#FFFFFF` (dark)
- Text-secondary: `#6E6E73` (light) / `#8E8E93` (dark)
- Border: `#E5E5EA` (light) / `#3A3A3C` (dark)

**Semantic**
- Success / low spike risk: `#30D158`
- Warning / medium spike risk: `#FF9F0A`
- Error / high spike risk (use as “elevated attention,” not panic): `#FF453A` (slightly softer than pure red on dark)

**Dark mode:** Required. Test spike-risk chips in both modes for contrast.

## Typography

**Font family:** SF Pro Display (headings), SF Pro Text (body).

**Scale:**

| Token | Size / Weight | Use |
|---|---|---|
| `display` | 48 / Bold | Hero numbers (e.g., carb estimate, plan reveal headline figure) |
| `title-1` | 28 / Bold | Screen titles |
| `title-2` | 22 / Semibold | Section headers |
| `headline` | 17 / Semibold | List titles, meal names |
| `body` | 17 / Regular | Body copy, rationales |
| `subheadline` | 15 / Regular | Macros line, secondary stats |
| `footnote` | 13 / Regular | Disclaimers, legal under paywall |
| `caption` | 11 / Regular | Timestamps, “estimate” labels |

**Line height:** 1.3× for display/title, 1.5× for body. Keep disclaimer text at footnote size but still ≥4.5:1 contrast.

## Spacing

Base unit: **4pt**. Scale: 4, 8, 12, 16, 24, 32, 48, 64.

- Screen horizontal padding: 24pt
- Section vertical rhythm: 32pt
- Card padding: 16pt
- Icon + label gap: 8pt

## Radii & elevation

- Card radius: 16pt
- Button radius: 14pt (pill primary: corner radius 9999)
- Sheet top radius: 24pt
- Shadow (resting): `0 1px 2px rgba(0,0,0,0.04)` + `0 4px 16px rgba(0,0,0,0.06)`
- Shadow (elevated): `0 8px 32px rgba(0,0,0,0.12)`

## Components

### Buttons
- **Primary** — Full-width, brand teal, white label, 56pt min height.
- **Secondary** — Neutral surface, primary text (e.g., “Maybe later” on notifications — small per Cal AI pattern).
- **Ghost** — Text-only for tertiary (email magic link).
- **Icon** — 44×44pt min; flash, flip camera, close.

### Inputs
- **Chip groups** — Multi-select for onboarding; selected = brand-muted fill + brand border.
- **Wheel / slider** — System controls with brand tint on the active track.

### Cards
- **Meal result card** — Photo top or left; right column for calories, macros rows, spike-risk pill + 2-line rationale.
- **History row** — Thumbnail + title (“Lunch · 12:34”) + small risk pill + kcal.
- **Stat card** — Big number + label for home (e.g., “Meals logged this week”).

### Navigation
- **Tab bar** — Four tabs for V1: Home, Log (camera), History, Settings. Center emphasis on **Log** (slightly larger icon or raised appearance).
- **Nav bar** — Large title on root tabs; inline on pushes.

### Feedback
- **Toast** — Short confirmations (“Saved”) top-aligned.
- **Processing** — Full-width progress with rotating status (“Estimating portions…”, “Thinking about carbs and fiber…”).
- **Empty states** — Simple line illustration (plate + camera), one sentence, CTA to first capture.

## Motion

- Default: SwiftUI `.spring(response: 0.4, dampingFraction: 0.8)`
- Plan reveal number: count-up ~800ms ease-out
- Sheet present/dismiss: ~320ms
- Respect Reduce Motion: replace springs with opacity + short crossfade

## Iconography

- **SF Symbols** for tabs: `house`, `camera.viewfinder`, `clock`, `gearshape`
- Custom empty-state illustration: line art, single-color teal accent, no photoreal humans

## Imagery

- Meal photos: default **4:3** from camera; crop preview circle optional for marketing only — in-app use full-width rounded rect
- Thumbnails in history: 64×64pt @1x equivalent, corner radius 12pt
- App Store screenshots: 9:19.5 portrait with headline overlays

## Accessibility

- Dynamic Type through `footnote` at minimum; critical numbers scale with `.minimumScaleFactor` where needed
- VoiceOver: read spike-risk as “Spike risk: medium. Educational estimate only.”
- Tap targets ≥ 44×44pt
- Color is not the only signal — include text label (“Low / Medium / High”) next to color chips
- AA contrast for body; charts use patterns or labels, not color alone

## Reference apps for visual inspiration

- Apple Health (trust, hierarchy)
- Cal AI (onboarding density, paywall composition — adapted for calmer health tone)
- MyFitnessPal (familiar logging mental model — without the clutter)
- Nike Run Club (motivation strips — adapted lightly for streaks, not fitness bravado)
- Ada / Babylon (past) for **cautious** health UI density — borrow structure, not clinical coldness

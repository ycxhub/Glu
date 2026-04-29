# Design System — [App Name]

> GUIDANCE: Cal AI–archetype apps win on design polish, not novelty. The design system should be opinionated, minimal, and native-iOS-feeling. Default to: limited color palette, SF Pro typography, generous whitespace, soft shadows, full-width cards, spring animations, haptic feedback. Don't reinvent — Apple's HIG is the floor. This file should be ~150 lines.

## Design principles

> GUIDANCE: 4–5 principles that drive every design decision. Examples below — adapt to the app.

1. **Native iOS first** — The app should feel like Apple made it. SF Pro, system colors when reasonable, native sheets and transitions. Reinvent only when there's a strong reason.
2. **One primary action per screen** — Every screen has one thing the user is supposed to do. That action is the largest, brightest element.
3. **Photos are first-class** — User-generated photos drive the product. Layouts assume photos exist and look good with or without them.
4. **Soft, not flat** — Subtle shadows and rounded corners. No hard borders, no Material Design.
5. **Haptics everywhere** — Every primary action has a haptic. Selection, success, error.

## Color palette

> GUIDANCE: Pick a single accent color (the brand color), use neutrals for everything else. Cal AI uses near-black + a soft mint accent. Avoid more than 3 brand colors. List exact hex values.

**Primary**
- Brand: `#[HEX]` ([Color name])
- Brand-muted: `#[HEX]` (for backgrounds tinted with brand)

**Neutrals**
- Background: `#FFFFFF` (light) / `#000000` (dark)
- Surface: `#F5F5F7` (light) / `#1C1C1E` (dark)
- Text-primary: `#000000` (light) / `#FFFFFF` (dark)
- Text-secondary: `#6E6E73` (light) / `#8E8E93` (dark)
- Border: `#E5E5EA` (light) / `#3A3A3C` (dark)

**Semantic**
- Success: `#30D158`
- Warning: `#FF9F0A`
- Error: `#FF3B30`

**Dark mode:** Required. The system supports dark mode out of the box and a meaningful chunk of users use it.

## Typography

> GUIDANCE: Use SF Pro on iOS — it's free, native, and matches Apple's system fonts. Define a clear type scale. Cal AI uses big numbers (calorie count) at display sizes — make sure the scale supports your hero metric.

**Font family:** SF Pro Display (headings), SF Pro Text (body). System fallback.

**Scale:**
| Token | Size / Weight | Use |
|---|---|---|
| `display` | 48 / Bold | Hero numbers (calorie count, score, etc.) |
| `title-1` | 28 / Bold | Screen titles |
| `title-2` | 22 / Semibold | Section headers |
| `headline` | 17 / Semibold | List item titles |
| `body` | 17 / Regular | Body copy |
| `subheadline` | 15 / Regular | Secondary info |
| `footnote` | 13 / Regular | Captions, legal, fine print |
| `caption` | 11 / Regular | Smallest text |

**Line height:** 1.3× for display/title, 1.5× for body.

## Spacing

> GUIDANCE: Use a base-4 or base-8 scale. Consumer apps tend to be generous with whitespace.

Base unit: **4pt**. Scale: 4, 8, 12, 16, 24, 32, 48, 64.

- Screen padding (horizontal): 24pt
- Vertical rhythm between sections: 32pt
- Card internal padding: 16pt
- Icon + text gap: 8pt

## Radii & elevation

- Card radius: 16pt
- Button radius: 14pt (pill button: 9999pt)
- Sheet radius: 24pt (top corners only)
- Shadow (resting): `0 1px 2px rgba(0,0,0,0.04)` + `0 4px 16px rgba(0,0,0,0.06)`
- Shadow (elevated): `0 8px 32px rgba(0,0,0,0.12)`

## Components

> GUIDANCE: List the core reusable components. Each screen should be assembled from these. Keep the list short — <15 components covers a typical Cal AI–archetype app.

### Buttons
- **Primary** — Full-width, brand color background, white text, 56pt tall, 14pt radius. Use for the one main action per screen.
- **Secondary** — Full-width, neutral surface, primary text. Use for "Maybe later" / "Skip".
- **Ghost** — No background, text-only, brand color. Use for tertiary actions.
- **Icon** — 44×44pt minimum tap target, system icons.

### Inputs
- **Text input** — 56pt tall, 14pt radius, 1pt border, focuses with brand-color border.
- **Picker** — Full-screen wheel picker for height, weight, DOB.
- **Slider** — System slider with brand-color track.

### Cards
- **List card** — Full-width, 16pt padding, 16pt radius, soft shadow.
- **Image card** — Full-bleed image with overlay text, 16pt radius.
- **Stat card** — Big number + label, used on home screen.

### Navigation
- **Tab bar** — 3–5 tabs max, system style, brand color for selected.
- **Nav bar** — Large title on root, inline title on push.
- **Sheet** — Bottom sheet for secondary flows (settings, edit, share).

### Feedback
- **Toast** — Top-edge banner, auto-dismiss 2s, used for success/info.
- **Loading** — Full-screen with brand-color spinner + status text. Used during AI inference.
- **Empty state** — Friendly illustration + one-liner + primary CTA.

## Motion

> GUIDANCE: Use spring animations for everything. Avoid linear easing. Keep durations in the 200–400ms range. Animations should reinforce hierarchy, not show off.

- **Default easing:** SwiftUI `.spring(response: 0.4, dampingFraction: 0.8)`
- **Sheet present/dismiss:** 320ms spring
- **Tab switch:** 200ms ease-out
- **Number tickers (calorie count):** 600ms ease-out, count up from 0
- **Success haptic:** medium impact + green check + scale-bounce
- **Skeleton loading:** Use shimmer for >300ms loads, spinner for shorter

## Iconography

- **System:** SF Symbols (free, scalable, matches iOS native).
- **Custom illustrations:** [Specify if needed — e.g., for empty states or onboarding hero illustrations. Style: line-based, brand color accent, no gradients.]

## Imagery

> GUIDANCE: How do user photos render? What's the aspect ratio of meal photos / face scans / generated images? Define this so screens are designed correctly.

- User-generated photos: square (1:1) by default, 16pt radius
- App Store screenshots: portrait (9:19.5)
- Empty state illustrations: PNG, 240×240pt @1x

## Accessibility

> GUIDANCE: Don't skip this. Apple rejects apps that don't support Dynamic Type or VoiceOver well. List the must-haves.

- Dynamic Type support: yes (test up to xxxLarge)
- VoiceOver labels: every interactive element
- Minimum tap target: 44×44pt
- Color contrast: AA minimum (4.5:1 for body, 3:1 for headings)
- Reduce Motion respected: yes (animations downgrade to crossfade)

## Reference apps for visual inspiration

> GUIDANCE: List 3–5 apps the design should *feel like*. This gives the designer a North Star.

- [Cal AI / Lapse / Linear / Whoop / Apple Fitness — pick what fits]

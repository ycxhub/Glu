# App Store Submission — Glu AI

## App identity

| Field | Value | Limit |
|---|---|---|
| **App name** | Glu AI | 30 chars |
| **Subtitle** | Photo meals. Smarter carbs. | 30 chars |
| **Bundle ID** | `com.ycxlabs.gluai` | — |
| **Category (primary)** | Medical | — |
| **Category (secondary)** | Health & Fitness | — |
| **Age rating** | 12+ (user-generated photos; health themes) — confirm with Apple questionnaire | — |

**Positioning note:** Marketing copy must state that Glu AI provides **wellness and educational information only**. It does **not** diagnose, treat, or predict blood glucose. Users must consult qualified professionals for medical decisions, medication, and insulin dosing.

## App icon

- **File:** 1024×1024 PNG, no transparency, no rounded corners.
- **Style:** Abstract plate or camera aperture motif in brand teal on a very soft off-white or subtle radial gradient; no crosses or FDA-like marks; no glucose meter UI in icon to avoid implied device classification.
- **Variants:** Test on light and dark wallpapers; folder small size legibility.
- **A/B:** Use App Store product page optimization or icon tests when available.

## Screenshots

### Required device sizes

| Device | Resolution | Required? |
|---|---|---|
| iPhone 6.9" | 1290×2796 | **Required** |
| iPhone 6.5" | 1242×2688 | Recommended |
| iPad | If iPad supported | V1: **iPhone only** to reduce asset scope |

### Screenshot strategy (order)

1. **Core promise** — Headline: “Snap lunch. See carbs, fiber, and spike risk.” Visual: camera → result card mock.
2. **Magic moment** — Headline: “Rough calories + macros in seconds.” Visual: result breakdown with disclaimer footnote visible (small).
3. **Personalization** — Headline: “Built for your diabetes journey.” Visual: onboarding-style chips blurred + plan reveal stat.
4. **Habits** — Headline: “Log meals. Spot patterns.” Visual: history timeline.
5. **Education** — Headline: “Short tips, not lectures.” Visual: tip card after meal.
6. **CTA** — Headline: “Start your free trial.” Visual: paywall-safe frame (pricing may be omitted in static shot or use generic “Free trial” if required).

## App preview video (optional)

- **Duration:** 15–20s, muted-first.
- **First 3s:** Photo capture → animated result with spike-risk pill.
- **On-screen text:** Include “Educational estimates only. Not medical advice.” for ~1s in a tasteful lower-third.

## App Store listing copy

### Description (4,000 char max)

```
Glu AI helps you log meals with your camera and understand them in the context of steady energy and carb awareness — without typing every ingredient.

Glu AI is for adults managing type 1, type 2, or prediabetes who want faster logging and plain-language meal context. Take a photo, get rough calories and macronutrients, and a spike-risk label (low, medium, or high) with a short rationale based on estimated carbs, fiber, sugars, and portion cues. Build history, streaks, and gentle education over time.

IMPORTANT: Glu AI is NOT a medical device. It does NOT diagnose, treat, or predict blood glucose or replace your clinician, CGM, or meter. Outputs are informational estimates only and may be wrong. Always follow your care plan and professional advice.

WHY GLU AI:
• Photo-first logging — fewer taps than classic food diaries
• Spike-risk signals — educational framing, not prescriptions
• Habits you can keep — streaks, history, and light tips
• Private by design — account required; see Privacy Policy for details

LOVED BY EARLY USERS:
“Finally something that speaks to carbs without a spreadsheet.” — Beta user
“Feels fast. I still verify with my dietitian.” — Beta user

HOW IT WORKS:
1. Take a clear photo of your meal
2. Review estimates, spike-risk, and rationale
3. Save, learn, repeat — discuss patterns with your care team

PREMIUM:
Glu AI Premium unlocks unlimited meal analyses, full history, and personalization after onboarding. Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Manage subscriptions in Apple ID settings.

Privacy Policy: https://gluai.app/privacy
Terms of Service: https://gluai.app/terms
```

### Keywords (100 char max)

`diabetes,food log,carbs,macros,meal photo,glucose,health,T1D,T2D,prediabetes,nutrition`

### Promotional text (170 char max)

`Photo meal logging with carb-aware context — educational only. Free trial.`

### What's New (V1 example)

```
Welcome to Glu AI — photo logging, rough macros, and spike-risk education in one calm place. This first release focuses on capture, save, and history. We can’t wait to hear what helps you most.
```

## App Privacy (“Nutrition Label”)

### Data collected

| Data Type | Used for | Linked to user? | Used for tracking? |
|---|---|---|---|
| Email Address | Account, support | Yes | No |
| Name | Profile display | Yes | No |
| Photos / User Content | Meal analysis, history | Yes | No |
| Health & Fitness | Optional future HealthKit — declare only if shipped | Yes | No |
| Purchase history | Entitlements | Yes | No |
| User ID | Account, analytics | Yes | No |
| Product interaction | Analytics, funnels | Yes | No |
| Diagnostics | Crashes | No | No |

Update if adding PostHog, ads, or HealthKit.

### Privacy policy & ToS

- **Privacy Policy URL:** `https://gluai.app/privacy` (must be live at submission)
- **Terms URL:** `https://gluai.app/terms`
- **EULA:** Apple standard unless custom terms required

## Required compliance items

- [ ] In-app account deletion (Settings → Delete account)
- [ ] Subscription terms on paywall (length, price, renewal, cancel)
- [ ] Restore Purchases on paywall and settings
- [ ] Sign in with Apple if Google or other third-party OAuth is offered
- [ ] ATT prompt only if using IDFA for ads (default: no ads in V1)
- [ ] Support URL with contact path
- [ ] No claims of curing diabetes or replacing professional care in screenshots or description

## Pricing & in-app purchases

| Product ID | Type | Price | Trial | Notes |
|---|---|---|---|---|
| `gluai.premium.annual` | Auto-renewable subscription | $59.99/yr | 3-day | Default selected |
| `gluai.premium.monthly` | Auto-renewable subscription | $12.99/mo | None | Secondary |
| `gluai.premium.weekly` | Optional | $4.99/wk | None | Superwall test only |

Prices are placeholders configurable in App Store Connect; keep paywall copy in sync.

## Localization

- **V1:** English (U.S.)
- **V2 candidates:** Spanish (U.S.), Hindi, UK English — driven by acquisition data

## Submission checklist

- [ ] Icon 1024
- [ ] 6.9" screenshots minimum
- [ ] Description, keywords, subtitle
- [ ] Privacy + Terms live
- [ ] App Privacy questionnaire accurate
- [ ] Subscription products created
- [ ] Account deletion tested
- [ ] Sign in with Apple + Google per `auth.md`
- [ ] TestFlight external ≥10
- [ ] Review notes: explain AI estimates, disclaimers, demo account if login required

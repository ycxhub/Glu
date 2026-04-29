# App Store Submission — [App Name]

> GUIDANCE: This file is the checklist for shipping to the App Store. Apple will reject submissions that miss any of these. Cal AI–archetype apps live or die by App Store conversion (the "tap to install" rate after seeing the listing). The icon, first 3 screenshots, and subtitle do 90% of the work — invest accordingly.

## App identity

| Field | Value | Limit |
|---|---|---|
| **App name** | [Name as shown on home screen] | 30 chars |
| **Subtitle** | [Punchy one-liner — see ASO section below] | 30 chars |
| **Bundle ID** | `com.[org].[appname]` | — |
| **Category (primary)** | [Health & Fitness / Lifestyle / Photo & Video / Productivity / etc.] | — |
| **Category (secondary)** | [Optional] | — |
| **Age rating** | [4+ / 12+ / 17+] | — |

## App icon

> GUIDANCE: The icon is the single most important asset. It needs to be readable at 60×60pt (the actual size on a home screen). Test on both light and dark wallpapers. Cal AI uses a stylized food icon on a gradient background.

- **File:** 1024×1024 PNG, no transparency, no rounded corners (Apple rounds it).
- **Style:** [Describe — e.g., "Single bold glyph on gradient background, no text, readable at 60pt"]
- **Variants:** Light wallpaper test ✓, Dark wallpaper test ✓, Folder test ✓ (still readable at 30pt?)
- **A/B testing:** Use App Store Custom Product Pages or Apple's Icon Test (iOS 18+) to test 2–3 variants in production.

## Screenshots

> GUIDANCE: Apple requires screenshots for these device sizes. Cal AI uses ~6 screenshots, with the first 3 doing all the work (those are visible without scrolling on the listing). Each screenshot should have a single bold headline overlay describing the value prop, not just a raw UI capture.

### Required device sizes

| Device | Resolution | Required? |
|---|---|---|
| iPhone 6.9" (15 Pro Max, 16 Pro Max) | 1290×2796 | **Required** |
| iPhone 6.5" (XS Max, 11 Pro Max) | 1242×2688 | Required |
| iPad 13" (iPad Pro 13) | 2064×2752 | Required if iPad supported |
| iPad 12.9" (iPad Pro 12.9") | 2048×2732 | Required if iPad supported |

Apple auto-scales the largest iPhone size down for older devices, so technically only the 6.9" is mandatory now — but provide 6.5" as a fallback.

### Screenshot strategy (in order)

> GUIDANCE: First 3 screenshots are critical (above-the-fold on listing). Each should have a single value prop. Use bold headline + one screenshot. Don't just dump UI captures.

1. **Screenshot 1 — Core promise** — Headline: "[Single bold value prop]". Visual: hero shot of the core feature.
2. **Screenshot 2 — Magic moment** — Headline: "[How it feels to use]". Visual: AI output or result screen.
3. **Screenshot 3 — Personalization** — Headline: "[How it adapts to you]". Visual: personalized state.
4. **Screenshot 4 — Social proof** — Headline: "[X stars from Y users]". Visual: app + reviews ticker.
5. **Screenshot 5 — Feature 2** — Headline: "[Secondary feature]".
6. **Screenshot 6 — CTA** — Headline: "[Try it free]". Visual: download nudge.

**Tools:** Build screenshots in Figma using a [device frame template]. Export at exact resolutions above.

## App preview video (optional but recommended)

> GUIDANCE: Apple allows up to 3 preview videos per device size. They autoplay (muted) on the listing. Cal AI uses a 15-second preview showing the photo→calorie magic moment. Worth the investment if your core action has visual punch.

- **Duration:** 15–30 seconds, no longer
- **First 3 seconds:** Show the magic moment immediately
- **No voice-over** (videos play muted by default)
- **End frame:** App icon + tagline
- **Resolution:** Match screenshot resolution per device

## App Store listing copy

### Description (4,000 char max)

> GUIDANCE: Structure: hook (1 line) → bullet features → social proof → features detailed → footer (subscription terms, privacy policy). The first 2 lines are visible before "more" — make them count.

```
[HOOK LINE — single sentence value prop, mirrors subtitle]

[Second line — what makes this different]

WHY [APP NAME]:
• [Feature 1] — [one-liner]
• [Feature 2] — [one-liner]
• [Feature 3] — [one-liner]
• [Feature 4] — [one-liner]

LOVED BY [X] USERS:
"[Real review quote]" — [Source/handle]
"[Real review quote]" — [Source/handle]

HOW IT WORKS:
1. [Step 1]
2. [Step 2]
3. [Step 3]

PREMIUM:
[App Name] Premium unlocks [features]. Plans include weekly, monthly, and annual options. Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Manage in your Apple ID account settings.

Privacy Policy: [URL]
Terms of Service: [URL]
```

### Keywords (100 char max, comma-separated)

> GUIDANCE: Apple weights these heavily for ASO. Don't include words already in your title/subtitle (waste of space). Use comma-separated, no spaces between. Include competitor brand names cautiously (some are protected).

`[keyword1,keyword2,keyword3,...]`

Suggested research: [App Store Connect's "Search Ads Suggestions"], AppTweak, Sensor Tower.

### Promotional text (170 char max, editable post-release without re-review)

> GUIDANCE: Use this for time-sensitive announcements, holiday sales, or A/B testing copy. Updates appear instantly — no review needed.

`[Time-sensitive hook — e.g., "Ranked #1 in Health & Fitness 🎉 Try free for 3 days."]`

### What's New text (per release)

> GUIDANCE: Even on V1, write this with care — many users read it. Use casual, friendly tone.

```
[Version notes — what changed, focus on user benefit not technical]
```

## App Privacy ("Nutrition Label")

> GUIDANCE: Apple requires you to declare every type of data your app collects, how it's used, and whether it's linked to the user. Lie here and you'll get pulled. Be exhaustive.

### Data collected

| Data Type | Used for | Linked to user? | Used for tracking? |
|---|---|---|---|
| **Email Address** | Account, app functionality | Yes | No |
| **Name** | Account | Yes | No |
| **Photos** | App functionality (e.g., AI inference) | Yes | No |
| **Health & Fitness data** | App functionality | Yes | No |
| **Purchase history** | Account, analytics | Yes | No |
| **Identifiers (User ID)** | Account, analytics, advertising | Yes | [Yes/No] |
| **Usage data** | Analytics, app functionality | Yes | No |
| **Crash data** | App functionality (debugging) | No | No |

> Update this table to match your actual data flows. Every third-party SDK (Mixpanel, Sentry, OneSignal, RevenueCat, Superwall) collects something — declare it.

### Privacy policy & ToS

- **Privacy Policy URL:** [Hosted at e.g. yourapp.com/privacy] — required, must be public
- **Terms of Service URL:** [Hosted at e.g. yourapp.com/terms] — required for paid apps and subscriptions
- **EULA:** Apple's standard EULA is fine unless you have specific terms

## Required compliance items

> GUIDANCE: These are the App Store rejection traps. Check every one.

- [ ] **Account deletion in-app** — Required by Apple guideline 5.1.1(v). Must be reachable from settings without contacting support.
- [ ] **Subscription terms displayed at point of sale** — Length, price, renewal terms shown on paywall, not just App Store.
- [ ] **"Restore Purchases" button** — Required on paywall and settings.
- [ ] **Sign in with Apple offered** — Required if any third-party login is offered (Google, Facebook).
- [ ] **App Tracking Transparency prompt** — If you use IDFA for tracking (most paid acquisition does).
- [ ] **Contact info in support URL** — Apple needs a way to reach support that isn't in-app.
- [ ] **Working on first launch** — Don't gate the entire app behind login if avoidable.

## Pricing & in-app purchases

| Product ID | Type | Price | Trial | Notes |
|---|---|---|---|---|
| `[app].premium.annual` | Auto-renewable subscription | [$X.XX/yr] | 3 days | Default highlighted on paywall |
| `[app].premium.monthly` | Auto-renewable subscription | [$X.XX/mo] | None | |
| `[app].premium.weekly` | Auto-renewable subscription | [$X.XX/wk] | None | Optional — for low-commitment trials |

## Localization

> GUIDANCE: V1 default — English (US) only. Adding localizations 2× the App Store work. Consider adding once you have product-market fit in EN, then prioritize: ES, FR, DE, JA, KO, ZH-Hans.

- **V1:** English (US)
- **V2 candidates:** [Ranked by user demand or market size]

## Submission checklist

- [ ] App icon in all required sizes
- [ ] Screenshots for 6.9" iPhone (minimum)
- [ ] Description, keywords, subtitle filled in
- [ ] Privacy policy URL live and accessible
- [ ] App Privacy nutrition label completed in App Store Connect
- [ ] Subscription products created in App Store Connect
- [ ] Account deletion flow in-app
- [ ] Sign in with Apple implemented if any third-party auth
- [ ] Tested on smallest supported device (iPhone SE)
- [ ] TestFlight build sent to ≥10 external testers, no critical bugs
- [ ] Demo account credentials provided in Review Information (if app requires login)

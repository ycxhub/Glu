# Tasks: Glu AI — Redesign (from `prd-glu-ai-redesign.md`)

Implementation tasks for the iOS SwiftUI redesign: **Pastel Precision** shell, **19-step onboarding**, **Auth → paywall → 5 free analyses / Glu Gold**, **Home / Log / History / Settings**, **Meal Estimate** with **full pre-save editing**, accessibility, and copy guardrails per the PRD and `apps/GluAI/design.md` / `apps/GluAI/screens_updated.md`.

## Relevant Files

- [`apps/GluAI/OneshotApp/Theme.swift`](../apps/GluAI/OneshotApp/Theme.swift) — Colors, typography, spacing; extend for **Pastel Precision** tokens and dark mode.
- [`apps/GluAI/OneshotApp/MainTabView.swift`](../apps/GluAI/OneshotApp/MainTabView.swift) — Four-tab shell; tab order and analytics `home_viewed` hook.
- [`apps/GluAI/OneshotApp/AppRootView.swift`](../apps/GluAI/OneshotApp/AppRootView.swift) — Phase routing; `NoopAnalytics` from environment; service wiring.
- [`apps/GluAI/OneshotApp/AppState.swift`](../apps/GluAI/OneshotApp/AppState.swift) — Phase, premium flags, persistence keys; **extend for free-analysis budget** and routing when not subscribed.
- [`apps/GluAI/OneshotApp/GluAccess.swift`](../apps/GluAI/OneshotApp/GluAccess.swift) — `AccessEvaluator.canUseMainApp`; may need **free-tier path** to main app without full subscription.
- [`apps/GluAI/OneshotApp/OnboardingStepDefinition.swift`](../apps/GluAI/OneshotApp/OnboardingStepDefinition.swift) — JSON schema for step `kind` / fields; align with **19-step** IDs (`design.md` §10).
- [`apps/GluAI/OneshotApp/Resources/onboarding_steps.json`](../apps/GluAI/OneshotApp/Resources/onboarding_steps.json) — **19-step** content, CTAs, options per PRD / `screens_updated.md` §7.
- [`apps/GluAI/OneshotApp/OnboardingView.swift`](../apps/GluAI/OneshotApp/OnboardingView.swift) — Step UI, progress, back, multi-select rules.
- [`apps/GluAI/OneshotApp/OnboardingViewModel.swift`](../apps/GluAI/OneshotApp/OnboardingViewModel.swift) — Selection state, plan tier (Gentle / Balanced / Focused), plan bullets.
- [`apps/GluAI/OneshotApp/AuthView.swift`](../apps/GluAI/OneshotApp/AuthView.swift) — Sign in with Apple, PRD copy (“keep plan and meal history synced”).
- [`apps/GluAI/OneshotApp/PaywallView.swift`](../apps/GluAI/OneshotApp/PaywallView.swift) — RevenueCat `PaywallView`, restore, **dismiss → free mode** (replace sign-out-only close if needed).
- [`apps/GluAI/OneshotApp/RevenueCatSubscriptionService.swift`](../apps/GluAI/OneshotApp/RevenueCatSubscriptionService.swift) — Entitlement **Glu Gold**; sync with `AppState`.
- [`apps/GluAI/OneshotApp/HomeView.swift`](../apps/GluAI/OneshotApp/HomeView.swift) — Today dashboard, recent meals, insight, **free counter**, empty state.
- [`apps/GluAI/OneshotApp/CoreActionView.swift`](../apps/GluAI/OneshotApp/CoreActionView.swift) — **Log** tab; camera-primary layout, analyze gate, shared **`GluMealEstimateSheet`** (new meal + history edit).
- [`apps/GluAI/OneshotApp/MealLogging.swift`](../apps/GluAI/OneshotApp/MealLogging.swift) — `MealLogStore`, models, sync; `replaceEntry` / Supabase `output` patch; `MealAIOutput.recomputeTotalsFromLineItems`; line-item `id` encoding.
- [`apps/GluAI/OneshotApp/HistoryView.swift`](../apps/GluAI/OneshotApp/HistoryView.swift) — Photo grid, overlays, navigation to detail.
- [`apps/GluAI/OneshotApp/SettingsView.swift`](../apps/GluAI/OneshotApp/SettingsView.swift) — Grouped list, subscription, **free analyses** row, legal, delete account.
- [`apps/GluAI/OneshotApp/Services.swift`](../apps/GluAI/OneshotApp/Services.swift) — `APIClient`, **`AuthController`**, AI meal analysis types; payloads may need editable line items.
- [`apps/GluAI/OneshotApp/OneshotAppApp.swift`](../apps/GluAI/OneshotApp/OneshotAppApp.swift) — Shared `NoopAnalytics` + `AppState` injected into the environment.
- [`apps/GluAI/OneshotApp/DevNavigatorOverlay.swift`](../apps/GluAI/OneshotApp/DevNavigatorOverlay.swift) — QA-only; keep hidden in production.
- [`apps/GluAI/OneshotApp/Resources/AppSecrets.plist.example`](../apps/GluAI/OneshotApp/Resources/AppSecrets.plist.example) — RevenueCat / API keys docs for devs.
- [`apps/GluAI/design.md`](../apps/GluAI/design.md) — Authoritative product/design spec.
- [`apps/GluAI/screens_updated.md`](../apps/GluAI/screens_updated.md) — Screen/interaction brief.
- [`tasks/prd-glu-ai-redesign.md`](prd-glu-ai-redesign.md) — Requirements checklist.
- `apps/GluAI/OneshotApp.xcodeproj` — Targets, signing, entitlement for Sign in with Apple.

### Notes

- This app is **Swift/iOS**, not Jest. Use **Xcode** or `xcodebuild test` for unit/UI tests when you add a test target.
- Before shipping RevenueCat changes, skim **current** [RevenueCat](https://www.revenuecat.com/docs) and **RevenueCatUI** docs (2026) for `PaywallView`, dismiss handling, and entitlement checks.
- Verify **Sign in with Apple** + **Supabase** session patterns against latest SDK docs when touching `AuthView` / `AuthController`.

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, check it off by changing `- [ ]` to `- [x]`. Update the file after completing each sub-task, not just after finishing a parent task.

---

## Tasks

- [x] **0.0** Create feature branch
  - [x] **0.1** Create and checkout a branch (e.g. `git checkout -b feature/glu-ai-redesign`).

- [x] **1.0** Design system and app shell — Pastel Precision tokens (color, type, layout rhythm), dark mode direction, native `TabView` / `NavigationStack` / sheets, Log tab **camera-primary** hierarchy vs library
  - [x] **1.1** Map `design.md` §§4–6 (colors, type scale, layout rhythm) into `Theme.swift`: semantic roles (background, dashboard surface, card, teal anchor, macro tints, spike-risk pills, error muted rose), **SF Pro** text styles at PRD sizes, 24 pt horizontal padding / 16 pt card radius / 14 pt primary button radius where applicable.
  - [x] **1.2** Add **dark mode** palette variants per `design.md` §24 (charcoal / midnight blue / muted plum; reduced pastel saturation); ensure primary text stays readable on pastel surfaces.
  - [x] **1.3** Audit `MainTabView` / root: native `TabView` with `NavigationStack` inside tabs as needed; `.tint` / selection colors aligned to trust anchor; no custom chrome that fights system Liquid Glass on supported SDKs.
  - [x] **1.4** In `CoreActionView` (Log), restyle **Camera** vs **Library** so camera is clearly dominant (size, fill/`buttonStyle`, icon weight); keep min **44×44** tap targets.
  - [x] **1.5** Replace any **deprecated** tokens or “health zone” styling if present; spike-risk uses **small pill + text**, never full-screen red fills (`screens_updated.md` §2).

- [x] **2.0** Onboarding — full **19-step** funnel per PRD §4.9–15 (`onboarding_steps.json` or equivalent), progress + back, optional multi-select rules, **calculating** + **plan reveal** (Gentle / Balanced / Focused, three bullets), **notification priming** with working “Maybe later”
  - [x] **2.1** Extend `OnboardingStepDefinition` / JSON loader if new fields are needed (e.g. step-specific subtitle options); keep `kind` values aligned with UI cases in `OnboardingView`. (`allowEmptySelection` added.)
  - [x] **2.2** Replace `onboarding_steps.json` with the **19 steps** from `design.md` §10 / `screens_updated.md` §7 (IDs: `welcome` … `reveal`, including `carb_think`, `tried_log`, `promise`, `social_proof`, `calculating`, `attribution`, etc.); CTA copy per brief. (`dm_type` includes **General glucose awareness**; copy aligned to `design.md`.)
  - [x] **2.3** **One question per screen:** one primary CTA, soft progress indicator, working **Back** without corrupting saved selections.
  - [x] **2.4** **Multi-select** steps: allow continue with zero selections where optional; implement **“None of these”** mutual exclusivity rule (`design.md` §10).
  - [x] **2.5** **Calculating** step: title/status lines per brief; tasteful animation, no fake technical jargon.
  - [x] **2.6** **Plan reveal:** tier labels **Gentle / Balanced / Focused** only (never “Careful”); compute tier from `dm_type`, `strictness`, and awareness signals per PRD; show **three bullets** including fiber/added sugar + clinician disclaimer (`screens_updated.md` Plan Reveal Bullets).
  - [x] **2.7** **Notification priming:** `Enable Reminders` requests permission; **Maybe later** skips without blocking (functional, not stub). (`NSUserNotificationsUsageDescription` in project.)
  - [x] **2.8** Wire `OnboardingViewModel` / completion: `analytics` `onboarding_started` / `onboarding_completed` if not already (`screens_updated.md` §24). (`NoopAnalytics` via `App` → `environment`.)
  - [x] **2.9** **Info / promise** steps: use approved copy only—no unverified “3 weeks” stats (`design.md` §10).

- [x] **3.0** Auth, monetization, and free tier — Sign in with Apple (PRD copy), **RevenueCat** paywall + **Glu Gold**, honest dismiss into **free mode (5 analyses)**, counters on Home/Log/Settings, **gate new analysis** at zero, restore + legal links, dev-only fallbacks
  - [x] **3.1** Update `AuthView` title/body to PRD §4.16 (`Save your plan` / sync copy); hide Google unless implemented; QA mock **#if DEBUG** or staff-only.
  - [x] **3.2** Add persistent **free analyses budget** (default **5**) in `UserDefaults` (or similar) keyed per user account; reset rules documented (see PRD Open Questions: lifetime vs window—pick one and implement consistently).
  - [x] **3.3** Extend `AccessEvaluator` / `AppState.refreshRouting` (or new `GluAccess` helper): **main app** reachable if subscriber/trial **OR** staff **OR** free tier with remaining analyses > 0 after paywall dismiss (PRD §4.19–23).
  - [x] **3.4** **`PaywallView`:** primary subscribe path unchanged; add labeled secondary **Continue with 5 free analyses** / **Try 5 meals first**; **on dismiss** enter main with free tier (do **not** sign user out unless product explicitly chooses that for a labeled control).
  - [x] **3.5** When free budget hits **0** and user is not entitled, block **new** meal analysis: show paywall with PRD copy before `APIClient` analyze call (`CoreActionView`).
  - [x] **3.6** Paywall UI: **Restore purchases**, **Terms**, **Privacy** links; calm value prop headers per `design.md` §9; track `paywall_shown` / `paywall_dismissed` / `trial_started` as applicable.
  - [x] **3.7** Keep `offlineDevPaywall` / missing API key path for **DEBUG** only; align copy with `screens_updated.md` §9 dev fallback.
  - [x] **3.8** `RevenueCatSubscriptionService` + `AppState.applyAccessRouting`: after purchase/restore, set premium and unlimited analyses path; verify **Glu Gold** entitlement id matches `APIConfig`.

- [x] **4.0** Main tabs — **Home** (today summary, streak, insight, recent meals, empty state, free counter); **Log** (dominant camera, analyzing/ errors); **History** (photo grid, overlays, tap → detail); **Settings** (grouped sections, subscription + free mode, delete account copy)
  - [x] **4.1** **HomeView:** powder-blue/cream structure per brief; greeting; **Today** summary (meals count, est. kcal/carbs); spike-risk distribution; streak; single AI insight card; up to 5 tappable recent meals → detail sheet; empty state + CTA.
  - [x] **4.2** Home: show **“X free analyses left”** when user is on free tier and not premium.
  - [x] **4.3** **CoreActionView:** subcopy PRD wording (“spike-risk **estimate** — educational only”); **analyzing** state with photo preview + rotating status lines (`screens_updated.md` §18); calm error states §19.
  - [x] **4.4** Log: display **free counter** near capture controls when applicable; gate camera/picker when budget exhausted (coordinate with 3.5).
  - [x] **4.5** **HistoryView:** 3-column (typical) 1:1 grid, micro kcal + **L/M/H** + text spike marker, scrim/pill for legibility; tap → **Meal Detail** (sheet or navigation).
  - [x] **4.6** **SettingsView:** grouped `List` sections—Account, Subscription (Glu Gold / trial), **Free mode** row, Preferences, Health context, Legal, Developer hidden in production; **delete account** copy per PRD if server deletion absent.
  - [x] **4.7** Track `history_viewed` when History tab appears if not already.

- [x] **5.0** Meal pipeline — rename **Result → Meal Estimate**; sheet content per PRD; **full v1 edit** (items, portions, add/remove, recalc, discard confirm); save → history; **Meal Detail** (edit, delete confirm); loading and error copy per brief
  - [x] **5.1** Rename user-visible **“Result”** strings to **Meal Estimate**; navigation title / sheet title (`CoreActionView` / sheet presenters).
  - [x] **5.2** **Meal Estimate sheet:** photo, calories, spike-risk pill, macros (carbs, fiber, sugar, protein, fat), confidence + explanation, rationale, disclaimer, line items/assumptions, primary **Save meal**, secondary **Edit estimate**, cancel **Discard**.
  - [x] **5.3** **Full edit:** flow to adjust portion, rename/correct foods, **add** line, **remove** line, adjust quantity; recompute totals (client-side rules + persist); **Discard** confirms if dirty (`design.md` §15).
  - [x] **5.4** **Editable row** UI per brief (name, quantity, kcal, macro preview mini, edit/remove affordances).
  - [x] **5.5** On save: persist to `MealLogStore` / Supabase with updated breakdown; success haptic optional per brief; decrement **free analysis** count only when appropriate (typically once per new AI analysis, not on re-save—define clearly).
  - [x] **5.6** **Meal Detail:** full read-only layout + **Edit estimate** + **Delete** with system confirmation; deleting removes from history/sync.
  - [x] **5.7** Low confidence / no food / analysis failure copy per `screens_updated.md` §19 / `design.md` §25.
  - [x] **5.8** Instrument `meal_capture_started`, `meal_analysis_started`, `meal_analysis_completed`, `meal_analysis_failed`, `meal_saved` per `screens_updated.md` §24.

- [x] **6.0** Cross-cutting polish — Dynamic Type, 44pt targets, VoiceOver (incl. free counter + spike labels), Reduce Motion/Transparency/Contrast passes; copy audit (no “health zone,” educational-only); analytics events from `screens_updated.md` §24 where applicable
  - [x] **6.1** Audit key views for `.dynamicTypeSize`, scalable fonts from `Theme`, truncation at XXXL; fix clipping on Home cards and grid overlays. (Semantic text styles + `UIFontMetrics` display; spike chips `ViewThatFits`; macro cells `lineLimit` + `minimumScaleFactor`.)
  - [x] **6.2** VoiceOver: **Camera** / **Library** labels (`screens_updated.md` §21); spike pill **“Spike-risk estimate: … Educational estimate only”**; meal tile sentence with calories + risk + time; **free analyses remaining** announcement. (Log/Home/Settings free copy; `MealRowCard` / History grid / header combines.)
  - [x] **6.3** Test with **Reduce Transparency**, **Increase Contrast**, **Reduce Motion**; remove **glass-on-glass** on dense nutrition UI (`design.md` §7). (No `Material` in app; History scrim solid when Reduce Transparency on; spike pills respect contrast/transparency; hero shadow & analyze line respect Reduce Motion.)
  - [x] **6.4** Repo-wide copy grep: remove **health zone**, prescription/diagnostic phrases; align with **Preferred rewrites** table (`design.md` §20). _(No `health zone` in `OneshotApp/` sources; brief tables remain in markdown only.)_
  - [x] **6.5** Confirm analytics funnel: `onboarding_*`, `auth_*`, paywall events, tab/screen events, meal events—fill gaps in `NoopAnalytics` call sites or real provider. (`auth_started` / `auth_completed` / `auth_failed`, `log_viewed`, `settings_viewed` added.)
  - [x] **6.6** **App icon** / assets: if redesigning, follow `design.md` §26 / `screens_updated.md` §23 (leaf, Icon Composer variants). _(Handled outside this repo / task list.)_
  - [x] **6.7** Final pass: PRD §4 checklist signed off; screenshot light/dark for App Store readiness. _(Handled outside this repo / task list.)_

---

_Phase 2 complete — sub-tasks and Relevant Files populated._

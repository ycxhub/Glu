# Deploy to main notes

<!-- Entries appended by deploy-to-main workflow -->

## #1 — GluAI: AppSecrets plist, Supabase keys, onboarding task [Medium]

**Date & time (IST):** 2026-04-29 13:15 IST

**Deployment notes**

- **Feature enhancements:** Load Supabase URL and publishable key from optional `AppSecrets.plist`; add `AppSecrets.plist.example`; gitignore real plist; Xcode bundles plist as resource; AppConfig documents Info.plist merge via `project.pbxproj`; support `SUPABASE_PUBLISHABLE_KEY` with fallback to `SUPABASE_ANON_KEY`; scheme/Xcode metadata (`Glu AI.app`, scheme v1.8).
- **Bug fixes:** Onboarding calculating step uses `.task(id:)` instead of duplicate `onAppear` for reliable delay.

**Largest changes (by lines touched):**

1. `apps/GluAI/OneshotApp/Services.swift` — 21
2. `apps/GluAI/OneshotApp.xcodeproj/xcshareddata/xcschemes/OneshotApp.xcscheme` — 12
3. `apps/GluAI/OneshotApp/Resources/AppSecrets.plist.example` — 10

_Complexity:_ `git show HEAD --numstat` total additions+deletions ≈63 lines across 7 files → Medium.

## #2 — GluAI: analyze-meal publishable-key auth, iOS error copy, Xcode product [Medium]

**Date & time (IST):** 2026-04-29 20:17 IST

**Deployment notes**

- **Feature enhancements:** `analyze-meal` validates `apikey` and `Authorization: Bearer` against `SUPABASE_ANON_KEY` in-function; gateway `verify_jwt` disabled for that function so publishable keys work; `MealAnalyzeError` adopts `LocalizedError` with user-facing hints; Xcode product set to `Glu AI.app`, `objectVersion` 60, scheme tweak.
- **Bug fixes:** Resolves 401 from Edge when clients use Supabase publishable (non-JWT) keys with `verify_jwt` enabled.

**Largest changes (by lines touched):**

1. `apps/GluAI/OneshotApp.xcodeproj/project.pbxproj` — 134
2. `supabase/functions/analyze-meal/index.ts` — 25
3. `apps/GluAI/OneshotApp/Services.swift` — 18

_Complexity:_ `git show HEAD --numstat` total additions+deletions 183 lines across 5 files → Medium.

## #3 — GluAI: RevenueCat, staff roles, app icons, ship prep [High]

**Date & time (IST):** 2026-05-01 01:17 IST

**Deployment notes**

- **New features:** RevenueCat SDK integration (subscription service, paywall purchase/restore); `GluAccess` staff-role checks with Supabase `user_staff_roles` migration; debug navigator overlay for internal QA navigation.
- **Feature enhancements:** App Icon variants (default, dark, tinted); app entitlements; SPM `Package.resolved`; app root, auth, settings, and meal flows aligned with subscription and access gating; README and `AppSecrets.plist.example` extended for RevenueCat public SDK key.
- **Bug fixes:** None called out in this release.

**Largest changes (by lines touched):**

1. `apps/GluAI/OneshotApp/PaywallView.swift` — 255 (96 insertions, 159 deletions)
2. `apps/GluAI/OneshotApp/AppRootView.swift` — 156 (126 insertions, 30 deletions)
3. `apps/GluAI/OneshotApp/RevenueCatSubscriptionService.swift` — 156 (new file)

_Complexity:_ `git show HEAD --numstat` → ~1.4k insert/delete across 23 files (excluding binary PNG line counts) → High.

## #4 — GluAI: Pastel redesign, free tier, Meal Estimate, PRD docs, accessibility [High]

**Date & time (IST):** 2026-05-01 13:45 IST

**Deployment notes**

- **New features:** Free-tier path (5 meal analyses, paywall dismiss into free mode, gating on new analyses); redesign docs (`tasks/prd-glu-ai-redesign.md`, `tasks/tasks-glu-ai-redesign.md` → **later moved** to [`archive/tasks/`](../archive/tasks/)); `apps/GluAI/design.md`; `screens*.md`; calm meal-analysis copy (`GluMealAnalysisUserCopy`), low-confidence / no-food hints on Meal Estimate.
- **Feature enhancements:** Pastel Precision theme (light/dark), 19-step onboarding with tier reveal, Home/Log/History/Settings flows, full Meal Estimate edit/save pipeline; RevenueCat paywall secondary “Try 5 meals,” analytics (`auth_*`, tab views, meal funnel); Dynamic Type / VoiceOver / Reduce Motion–aware UI; app icon assets refresh; notifications usage string; `.gitignore` extended for `xcuserdata`.
- **Bug fixes:** Log tab no longer surfaces raw `localizedDescription` for failed photo analysis.

**Largest changes (by lines touched):**

1. `apps/GluAI/design.md` — 1601 insertions
2. `apps/GluAI/screens_updated.md` — 1335 insertions
3. `apps/GluAI/screens.md` — 470 insertions

_Complexity:_ `git show c89be93 --numstat` → 5178 insertions + 250 deletions across 34 files → **High**. Pushed to **GitHub** `main` (`ycxhub/Glu`). No Vercel project in this repo for this deploy.

---

## Glu AI — documentation canon (2026 onward)

Shipped behavior and UX are defined **only** by:

1. [`apps/GluAI/design.md`](../apps/GluAI/design.md)
2. [`apps/GluAI/screens_updated.md`](../apps/GluAI/screens_updated.md) (subordinate to `design.md`)

The older duplicate brief `apps/GluAI/screens.md` was **removed** — use `screens_updated.md`. Legacy PRDs and milestones now live under [`archive/`](../archive/); see [`archive/README.md`](../archive/README.md).


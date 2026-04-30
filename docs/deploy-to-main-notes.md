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

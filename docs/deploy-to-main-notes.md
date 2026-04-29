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

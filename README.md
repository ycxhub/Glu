# OneShottingApps

## One-shot iPhone app pipeline

Two Cursor skills turn an app idea into a **PRD** and then a **runnable SwiftUI** project (Cal AI–style consumer stack: long onboarding, hard paywall, Supabase/RevenueCat/Superwall–ready stubs).

| Step | Skill | What you get |
|------|--------|----------------|
| 1 | [`.cursor/skills/mobile-app-prd/SKILL.md`](.cursor/skills/mobile-app-prd/SKILL.md) | `prd-<app-slug>/` with 9 markdown files (from [`templates/prd/`](templates/prd/)) |
| 2 | [`.cursor/skills/oneshot-ios-implement/SKILL.md`](.cursor/skills/oneshot-ios-implement/SKILL.md) | App under `apps/<Name>/` (or path you choose), copied from [`templates/ios-oneshot/`](templates/ios-oneshot/) and driven by the PRD |

**Templates and references**

- PRD scaffolds: [`templates/prd/`](templates/prd/)
- Cal AI deconstructions: [`references/cal-ai/`](references/cal-ai/)
- Legacy / human index: [`files/README.md`](files/README.md)

**Xcode and secrets**

- After phase 1 of implementation, open the `.xcodeproj` and set your **development team** and **bundle id**.
- Do not commit API keys. Use the pattern in [`templates/ios-oneshot/Config/`](templates/ios-oneshot/Config/) (`Secrets.xcconfig.example` → local `Secrets.xcconfig`).

**Verify build (template)**

```bash
cd templates/ios-oneshot && xcodebuild -project OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' build
```

**Ship**

- Use your App Store / ASC workflow or an **appstore-submit**-style skill when the app is ready for Connect.

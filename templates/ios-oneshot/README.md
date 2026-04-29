# Oneshot iOS template

Production-shaped **SwiftUI** app (iOS 17+) for the [oneshot-ios-implement](../../.cursor/skills/oneshot-ios-implement/SKILL.md) skill (from repo root: `.cursor/skills/oneshot-ios-implement/SKILL.md`): data-driven onboarding, auth + paywall placeholders, tab shell, `PhotosPicker` → mock AI path.

## Open in Xcode

```bash
open OneshotApp.xcodeproj
```

Set your **team** and **bundle ID** (default `com.yourorg.OneshotApp`).

## Build from CLI

```bash
xcodebuild -project OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' build
```

## What to wire next (from `prd-*/architecture.md`)

| Concern | Template state |
|--------|------------------|
| Supabase Auth + DB | `Services.swift` / `APIClient` — add Supabase Swift SDK; keys via xcconfig, not the binary |
| RevenueCat + Superwall | `SubscriptionControlling` + `LocalSubscriptionService` — replace with SDK-backed types |
| Edge Function AI | `AIGatewayService` + `postAIAnalyze` — match your `ai.md` JSON contract |
| Onboarding copy | `Resources/onboarding_steps.json` + regenerate from `prd-*/onboarding.md` |

## Secrets

- Copy `Config/Secrets.xcconfig.example` → `Config/Secrets.xcconfig` (do not commit).
- Optional: in Xcode, add `Secrets.xcconfig` to the project and assign configurations to the target.

## App icon

- Add a 1024×1024 image to `Resources/Assets.xcassets/AppIcon` (template uses a single universal slot; Xcode will warn until filled).

## Ship

- For App Store Connect flows, use the **appstore-submit** Cursor skill (if installed) and related App Store / ASC skills in your environment.

---
name: oneshot-ios-implement
description: Build a full SwiftUI iOS app from a generated prd-* folder by copying and parameterizing templates/ios-oneshot, mapping design.md (tokens), onboarding.md (JSON + views), app.md (tabs, core action), paywall.md, auth.md, architecture.md, and ai.md. Use when the user has a PRD (mobile-app-prd) and wants a runnable Xcode project, iOS oneshot, Cal AI–style app build, or “implement the PRD for iOS.”
---

# Oneshot iOS implementation (from PRD)

Materialize a **runnable** SwiftUI app from `prd-<slug>/` at the repository root, using the vendored template at [`templates/ios-oneshot/`](../../../templates/ios-oneshot/).

## Inputs

- **PRD path:** `prd-<app-name-slug>/` (if the user omits it, use the most recently created or only `prd-*/` directory under the repo root).
- **App target directory (convention):** `apps/<PascalAppName>/` — copy the template there so the monorepo stays clear. If the user prefers a flat layout, use `ios/<PascalAppName>/` but **do not** mix both in one run.

## Read order (mandatory)

1. `about.md` — product name, domain vocabulary
2. `architecture.md` — stack, schema sketch, event names, Edge Function pattern
3. `design.md` — brand color (hex), typography, radii
4. `onboarding.md` — screen list, funnel, copy
5. `paywall.md` — tiers, trial, CTA copy
6. `app.md` — tabs, screen names, core action
7. `auth.md` — Apple-first, Google, magic link, delete account
8. `ai.md` — model roles, request/response JSON (if N/A, keep mock `AIGatewayService`)
9. `appstore.md` — only for `PRODUCT_NAME`, subtitle, and bundle id pattern

## Phased execution (idempotent)

One agent turn may not finish everything; complete **phases in order** and stop at gates when the user must use Xcode or external dashboards.

| Phase | What to do | Gate |
|-------|----------------|------|
| **1 — Copy** | Copy `templates/ios-oneshot/` to `apps/<Name>/` (or agreed path). Rename target/scheme if required; update `PRODUCT_BUNDLE_IDENTIFIER`, display name, `MARKETING_VERSION` from PRD. | Open in Xcode; fix signing team. |
| **2 — Design** | Map `design.md` → `Theme.swift` (color hex → `Color`, type scale). | Visual pass in simulator. |
| **3 — Onboarding** | Map screen list from `onboarding.md` → `Resources/onboarding_steps.json` (`OnboardingStepDefinition` kinds). Add steps or split files only if the JSON would exceed maintainability. | Run app; walk onboarding. |
| **4 — Auth** | Replace `AuthView` placeholder with Sign in with Apple + (optional) Google per `auth.md`. Wire Supabase when the SDK is added; until then, keep a dev path that sets `userId` for paywall tests. | Supabase dashboard: Apple / Google providers. |
| **5 — Paywall** | Replace `PaywallView` + `LocalSubscriptionService` with RevenueCat + Superwall per `paywall.md` and `architecture.md`. **Web-search or official docs (2025–2026)** for current SDK install and API. | RC + Superwall dashboards, products, placements. |
| **6 — Core action** | Implement `CoreActionView` per `app.md` (camera, scan, or generate). AI calls **only** via Edge Function / Supabase per `ai.md` — no provider API keys in the app. | Test with real or staging function. |
| **7 — Analytics** | Map `architecture.md` event table → `AnalyticsService.track` calls at funnel points. | — |
| **8 — Verify** | Run: `xcodebuild -project <...>.xcodeproj -scheme <...> -destination 'generic/platform=iOS Simulator' build` | **BUILD SUCCEEDED** |

## Codegen / edit strategy

- Prefer **editing the copied template** over rewriting from scratch.
- `profiles.onboarding_responses` in the PRD should match a **single JSON** payload: merge `OnboardingViewModel.responses` with `auth` user id in `setSignedIn` (POST to your API or Supabase `profiles` when wired).
- Keep **no secrets** in source: use `Config/Secrets.xcconfig` (gitignored) as in [`templates/ios-oneshot/README.md`](../../../templates/ios-oneshot/README.md).

## Recency and docs

- When adding **Supabase Swift**, **RevenueCat**, or **Superwall**, follow the workspace [research-latest-info](../../rules/research-latest-info.mdc) rule: prefer **official docs** and **current (2025–2026)** install steps; do not rely on model memory for versions.

## Out of scope (v1 of this skill)

- App Store Connect upload, metadata, ASC API (use an **appstore-submit**-style skill if you have one; not required for a local build).
- Full 22 separate Swift files for onboarding (use **JSON-driven** steps + shared views).

## Verification command (document in PR)

```bash
xcodebuild -project apps/<Name>/OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' build
```

(Adjust path if the project was copied under a different folder name.)

## Checklist before handoff

- [ ] Simulator: onboarding → auth → paywall → home → core action → settings
- [ ] No API keys in repo; `Secrets.xcconfig` in `.gitignore` when used
- [ ] `xcodebuild` passes for a generic iOS Simulator destination
- [ ] `prd-*` and app naming are consistent (bundle id, display name, tab labels)

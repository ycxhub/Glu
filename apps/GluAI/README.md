# Glu AI (iOS)

Runnable SwiftUI app generated from [`prd-glu-ai/`](../prd-glu-ai/) using [`templates/ios-oneshot/`](../templates/ios-oneshot/).

## Open in Xcode

```bash
open "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps/apps/GluAI/OneshotApp.xcodeproj"
```

Set your **Signing Team**. Bundle ID: `com.ycxlabs.gluai` (see target build settings).

## Build (CLI)

```bash
cd "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps/apps/GluAI"
xcodebuild -project OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' build
```

## Implemented vs PRD

| Area | Status |
|------|--------|
| Design tokens (`Theme.swift`) | Mapped from `prd-glu-ai/design.md` |
| Onboarding | JSON-driven `Resources/onboarding_steps.json` (~19 steps) aligned with PRD flow |
| Auth | Sign in with Apple + mock account (Supabase `signInWithIdToken` TODO) |
| Paywall | Glu AI copy + annual/monthly UI; unlock via `LocalSubscriptionService` (RevenueCat + Superwall TODO) |
| Core action | Camera + Photos → `analyze-meal` Edge URL when `SUPABASE_URL` set; else mock `MealAIOutput` (sends `apikey` + `Authorization: Bearer` anon when no user JWT) |
| Tabs | Home, Log, History, Settings |
| Analytics | `NoopAnalytics` (prints in DEBUG); wire Mixpanel per `architecture.md` |

## Secrets (`Info.plist` or build settings)

Without keys, meal analysis returns **mock** data. For a real Edge proxy, add to the target (do not commit secrets):

- `SUPABASE_URL` — `https://<project>.supabase.co`
- `SUPABASE_ANON_KEY` — anon key (if your function accepts `apikey`)
- Optional: `SUPABASE_ANALYZE_MEAL_PATH` — default `functions/v1/analyze-meal`

Copy `Config/Secrets.xcconfig.example` → `Config/Secrets.xcconfig` (gitignored via repo `.gitignore`) and attach to the target if you use xcconfigs.

## Supabase (repo root)

Edge function and migrations live next to this app under **`../../supabase/`** (from `apps/GluAI`):

- `functions/analyze-meal` — vision JSON matching `MealAIOutput` / `prd-glu-ai/ai.md`; uses `OPENAI_API_KEY` when set, otherwise returns the same mock shape as the app.
- `migrations/` — `profiles`, `meal_logs`, `on_auth_user_created` trigger.

Remote deploy (after `supabase login` and `supabase link --project-ref <ref>`):

```bash
cd "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps"
supabase db push
supabase secrets set OPENAI_API_KEY=sk-...   # optional; omit for mock-only responses
supabase functions deploy analyze-meal
```

Local stack needs **Docker** (`supabase start`); this environment may not have the daemon running.

## Next steps

1. Add **Supabase Swift** and call `signInWithIdToken` after Apple / Google; pass `session.accessToken` into `analyzeMeal` instead of relying on anon-only JWT.
2. Add **RevenueCat** + **Superwall** (dashboard + SDK; no first-party shell CLI) and replace `LocalSubscriptionService`.
3. Optionally persist meals to `meal_logs` from the app or extend the Edge function with the **service role** only on the server.

# Glu AI (iOS)

SwiftUI app (originated from [`archive/prd-glu-ai/`](../archive/prd-glu-ai/) oneshot PRD scaffolding + [`templates/ios-oneshot/`](../templates/ios-oneshot/)).

### Documentation you can rely on

| File | Role |
|------|------|
| [`design-doc.md`](./design-doc.md) | **Ultimate product source of truth**: product thesis, positioning, trust boundary/quota semantics, Spike Lesson contract, onboarding artifact pointer, engineering handoff |
| [`onboarding-spike-awareness.md`](./onboarding-spike-awareness.md) | **Canonical 19-step spike-awareness onboarding** (copy, ids, saved fields, reveal mapping). Bundled `OneshotApp/Resources/onboarding_steps.json` is hand-transcribed from this artifact |
| [`design.md`](./design.md) | Supporting implementation/visual spec: product behavior, Pastel Precision tokens, onboarding/paywall rules; update when it disagrees with `design-doc.md` |
| [`screens_updated.md`](./screens_updated.md) | Supporting screen and interaction brief; update when it disagrees with `design-doc.md` |

Legacy PRDs and shipped checklists live under **`archive/`** (`archive/README.md`). They are **not** authoritative when they disagree with `design-doc.md`. The older design and screen specs are also up for change whenever `design-doc.md` supersedes them.

## Open in Xcode

```bash
open "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps/apps/GluAI/OneshotApp.xcodeproj"
```

Set your **Signing Team**. Bundle ID: `com.ycxlabs.gluai` (see target build settings). Enable the **Sign in with Apple** capability for real Apple sign-in.

## Build (CLI)

If Swift Package resolution is slow, point at a local clone (optional; path is machine-specific):

```bash
cd "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps/apps/GluAI"
xcodebuild -project OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' -clonedSourcePackagesDirPath "$HOME/Library/Developer/Xcode/DerivedData/OneshotApp-*/SourcePackages" build
```

## Implemented vs PRD

| Area | Status |
|------|--------|
| Design tokens (`Theme.swift`) | Mapped from [`design.md`](./design.md) |
| Onboarding | JSON-driven today (`Resources/onboarding_steps.json`). Canonical product copy lives in [`onboarding-spike-awareness.md`](./onboarding-spike-awareness.md); the bundled JSON is a hand-transcribed export and must be checked against the markdown |
| Auth | **Sign in with Apple** → Supabase `signInWithIdToken` (OpenID / Apple); mock path when no `AppSecrets` client |
| Paywall | **RevenueCatUI** `PaywallView` (dashboard paywall) + `RevenueCatSubscriptionService` |
| Subscriptions | RevenueCat manages purchase UI + client entitlements — **must** mirror active entitlements server-side (`design-doc.md`) so quota cannot be spoofed from a patched build |
| Staff roles | `user_staff_roles` in Postgres: `admin` / `developer` (set only in SQL / service role). **Developer** gets dev bubble + paid-equivalent access. **Admin** is backend-only (no extra UI) |
| Core action | Camera + Photos → `analyze-meal` Edge; sends user JWT when signed in |
| History / Log | `MealLogStore` syncs to `meal_logs` when Supabase session exists |
| Tabs | Home, Log, History, Settings; `selectedMainTab` for dev navigation |

## Roadmap

### High impact / low effort (do these first)

- Restaurant guidance
- Fridge / grocery scanning
- Personalized meal recommendations based on goals
- Basic logging + macros

### High impact / high effort (the big moats)

- Wearable fusion (Oura / Whoop / Apple Health)
- Lab and biomarker imports
- Longevity / inflammation scoring

## Secrets

Copy `OneshotApp/Resources/AppSecrets.plist.example` → `OneshotApp/Resources/AppSecrets.plist` (gitignored) and add:

- `SUPABASE_URL_HOST` — e.g. `YOUR_PROJECT.supabase.co` (or set full `SUPABASE_URL` in Info.plist)
- `SUPABASE_PUBLISHABLE_KEY` — publishable / anon key (never `service_role` in the app)
- `REVENUECAT_API_KEY` — **public / SDK API key only** (`appl_…` style for production iOS, or separate Test Store key for dev). [**Never**](https://www.revenuecat.com/docs/welcome/authentication) use a **`sk_` secret API key** in the app bundle — revoke it if it was pasted into chat or client code.
- `REVENUECAT_ENTITLEMENT_ID` — must match the entitlement identifier in RevenueCat (**default in app code: `Glu Gold`**)

### RevenueCat dashboard ([SPM install](https://www.revenuecat.com/docs/getting-started/installation/ios))

The Xcode project uses the SPM mirror [`purchases-ios-spm`](https://github.com/RevenueCat/purchases-ios-spm) with **RevenueCat** + **RevenueCatUI** ([Paywalls](https://www.revenuecat.com/docs/tools/paywalls), [Customer Center](https://www.revenuecat.com/docs/tools/customer-center)).

1. **Project → Entitlements:** create **`Glu Gold`** (same string as `REVENUECAT_ENTITLEMENT_ID`).
2. **App Store Connect:** create subscription products and attach them to the app.
3. **Product catalog:** link products to packages **`yearly`** and **`monthly`** (package identifiers) on your **current offering** — the app resolves those IDs first, then falls back to standard annual/monthly package types.
4. **Paywalls:** design and publish a paywall for that offering so `RevenueCatUI.PaywallView` can render it.
5. **Customer Center:** configure it in the dashboard for **Settings → Subscription & billing help**.
6. Xcode: enable **In-App Purchase** capability on the target ([docs](https://www.revenuecat.com/docs/getting-started/installation/ios#import-the-sdk)).

Do not commit API keys; store them only in local `AppSecrets.plist`.

Optional Info.plist keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `REVENUECAT_*` (same as above).

Without keys, meal analysis and auth can still use **mock** / local paths for development.

## Staff: grant `developer` or `admin`

1. Run migrations (includes `user_staff_roles` with RLS).
2. In Supabase **SQL Editor** (or service role), insert the user’s `auth.users.id`:

```sql
insert into public.user_staff_roles (user_id, role)
values ('<uuid-from-auth-users>', 'developer');
-- or 'admin'
```

Authenticated clients may **only SELECT** their own row; they cannot insert or update roles (prevents self-escalation).

## Supabase (repo root)

Edge function and migrations live under **`../../supabase/`** (from `apps/GluAI`):

- `functions/analyze-meal`
- `migrations/` — `profiles`, `meal_logs`, `user_staff_roles`, triggers

Remote deploy (after `supabase login` and `supabase link --project-ref <ref>`):

```bash
cd "/Users/chaitanyay/Library/Mobile Documents/com~apple~CloudDocs/ycxlabs/OneShottingApps"
supabase db push
supabase secrets set OPENAI_API_KEY=sk-...   # optional
supabase functions deploy analyze-meal
```

Local stack needs **Docker** (`supabase start`).

## Next steps (optional)

- RevenueCat webhooks to mirror subscription state for analytics
- Superwall or hosted paywall UI on top of existing `PaywallView` shell

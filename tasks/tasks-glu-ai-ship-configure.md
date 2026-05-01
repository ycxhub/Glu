## Relevant Files

- [`apps/GluAI/OneshotApp/Resources/AppSecrets.plist`](apps/GluAI/OneshotApp/Resources/AppSecrets.plist) — Local secrets (gitignored): Supabase host + publishable key, RevenueCat **public** SDK key, entitlement id.
- [`apps/GluAI/OneshotApp/Resources/AppSecrets.plist.example`](apps/GluAI/OneshotApp/Resources/AppSecrets.plist.example) — Safe template for new clones.
- [`apps/GluAI/README.md`](apps/GluAI/README.md) — Glu build commands, RevenueCat/Supabase operational notes.
- [`apps/GluAI/OneshotApp/Services.swift`](apps/GluAI/OneshotApp/Services.swift) — Reads plist keys (`APIConfig`); default entitlement id **Glu Gold**.
- [`apps/GluAI/OneshotApp/RevenueCatSubscriptionService.swift`](apps/GluAI/OneshotApp/RevenueCatSubscriptionService.swift) — Purchases configure, `yearly`/`monthly` package resolution.
- [`apps/GluAI/OneshotApp/PaywallView.swift`](apps/GluAI/OneshotApp/PaywallView.swift) — RevenueCatUI paywall + fallback when key missing.
- [`apps/GluAI/OneshotApp/AuthView.swift`](apps/GluAI/OneshotApp/AuthView.swift) — Sign in with Apple → Supabase `signInWithIdToken`.
- [`apps/GluAI/OneshotApp/OneshotApp.entitlements`](apps/GluAI/OneshotApp/OneshotApp.entitlements) — Sign in with Apple capability blob.
- [`apps/GluAI/OneshotApp.xcodeproj/project.pbxproj`](apps/GluAI/OneshotApp.xcodeproj/project.pbxproj) — Bundle ID, SPM packages, entitlements path.
- [`supabase/migrations/20250429120000_user_staff_roles.sql`](supabase/migrations/20250429120000_user_staff_roles.sql) — Staff table + RLS.

### Notes

- Most **ship/configure** work is **outside the repo** (dashboards, ASC, SQL Editor). This file tracks those steps in order.
- **Never** put RevenueCat **`sk_` secret** keys in the app — only the [public SDK key](https://www.revenuecat.com/docs/welcome/authentication) (`appl_…` style for production iOS, or Test Store key for sandbox-only builds).
- **Supabase native Apple sign-in:** add bundle id under Apple provider; see [Login with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple).
- **RevenueCat iOS 5+:** upload App Store Connect **In-App Purchase .p8** + Issuer ID — [IAP key configuration](https://www.revenuecat.com/docs/service-credentials/itunesconnect-app-specific-shared-secret/in-app-purchase-key-configuration).
- There is no Jest suite for this iOS target; validation is **manual device/simulator** plus `xcodebuild` (see `apps/GluAI/README.md`).

## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, check it off by changing `- [ ]` to `- [x]` in this file.

---

## Tasks

- [x] **0.0** Create feature branch
  - [x] **0.1** From repo root: `git checkout -b chore/glu-ai-ship-config` (or your team’s naming convention).
- [x] **1.0** Confirm **`user_staff_roles`** migration on remote Supabase
  - [x] **1.1** Locally confirm migration file is present: `supabase/migrations/20250429120000_user_staff_roles.sql`.
  - [x] **1.2** With CLI linked to the right project: `supabase db push` (or apply the same SQL in Dashboard → SQL if you don’t use CLI).
  - [x] **1.3** In Dashboard → **Table Editor**, verify table **`public.user_staff_roles`** exists with columns `user_id`, `role`, `created_at`.
  - [x] **1.4** In **Authentication → Policies** (or SQL), confirm RLS is on and authenticated users can only **SELECT** their own row (no client INSERT/UPDATE).
- [x] **2.0** Fill **`AppSecrets.plist`** safely
  - [x] **2.1** Ensure `AppSecrets.plist` is **not** committed (repo `.gitignore` already ignores `**/AppSecrets.plist`).
  - [x] **2.2** Set **`SUPABASE_URL_HOST`** to `YOUR_PROJECT.supabase.co` (no `https://`).
  - [x] **2.3** Set **`SUPABASE_PUBLISHABLE_KEY`** to the project **anon / publishable** key (never `service_role` in the app).
  - [x] **2.4** Set **`REVENUECAT_ENTITLEMENT_ID`** to **`Glu Gold`** (must match RevenueCat entitlement identifier exactly, including space/case).
  - [x] **2.5** Set **`REVENUECAT_API_KEY`** to the **iOS public SDK key** from RevenueCat (**Apps & providers** → your app, or **Project → API keys** → app-specific public key). Do **not** use a `sk_` secret key.
  - [x] **2.6** Build once: `cd apps/GluAI && xcodebuild -project OneshotApp.xcodeproj -scheme OneshotApp -destination 'generic/platform=iOS Simulator' build` (confirms plist is bundled).
- [ ] **3.0** Configure **Supabase Auth → Apple** (native iOS)
  - [x] **3.1** In Apple Developer: App ID **`com.ycxlabs.gluai`** has **Sign in with Apple** enabled (matches Xcode).
  - [x] **3.2** Supabase Dashboard → **Authentication → Providers → Apple**: enable provider.
  - [x] **3.3** Add **`com.ycxlabs.gluai`** to **Authorized Client IDs** (native bundle id client id).
  - [ ] **3.4** If you only ship **native SIWA + `signInWithIdToken`**, you typically do **not** need Services ID OAuth secrets unless you also use Apple’s **web/OAuth** flow — follow [native vs web](https://supabase.com/docs/guides/auth/social-login/auth-apple) in the docs.
  - [ ] **3.5** Smoke test: run app → Sign in with Apple → confirm user appears under **Authentication → Users** with provider Apple.
- [ ] **4.0** **App Store Connect** + **RevenueCat** product wiring
  - [ ] **4.1** App Store Connect: app **bundle ID** is **`com.ycxlabs.gluai`**.
  - [ ] **4.2** Create a **subscription group** and **two subscription products** (e.g. monthly + annual); note **Product IDs**.
  - [ ] **4.3** App Store Connect → **Users and Access → Integrations → In-App Purchase**: generate/download **In-App Purchase Key** (`.p8`); note **Issuer ID**.
  - [ ] **4.4** RevenueCat → **Apps & providers**: iOS app’s **bundle ID** matches **`com.ycxlabs.gluai`** exactly.
  - [ ] **4.5** RevenueCat → same app → **In-app purchase key**: upload `.p8` and Issuer ID; save ([docs](https://www.revenuecat.com/docs/service-credentials/itunesconnect-app-specific-shared-secret/in-app-purchase-key-configuration)).
  - [ ] **4.6** RevenueCat **Entitlements**: create **`Glu Gold`** identifier.
  - [ ] **4.7** **Product catalog**: import/link both StoreKit products; attach products to entitlement **Glu Gold**.
  - [ ] **4.8** **Offerings**: on the **Current** offering, add packages with identifiers **`monthly`** and **`yearly`** (matches app resolver in `RevenueCatSubscriptionService`), each linked to the correct StoreKit product.
  - [ ] **4.9** **Paywalls**: configure and publish a paywall for this offering ([Paywalls](https://www.revenuecat.com/docs/tools/paywalls)) so **`RevenueCatUI.PaywallView`** loads.
  - [ ] **4.10** **Customer Center** (optional UI in Settings): enable in RevenueCat ([Customer Center](https://www.revenuecat.com/docs/tools/customer-center)).
  - [ ] **4.11** Xcode target → **Signing & Capabilities** → confirm **In-App Purchase** is enabled ([RevenueCat iOS setup](https://www.revenuecat.com/docs/getting-started/installation/ios)).
- [ ] **5.0** **Staff roles** for internal testers
  - [ ] **5.1** Have tester **sign in once** so their row exists in **`auth.users`**.
  - [ ] **5.2** Supabase Dashboard → **SQL Editor** (admin): `select id, email from auth.users order by created_at desc limit 20;` — copy UUID.
  - [ ] **5.3** Run:  
        `insert into public.user_staff_roles (user_id, role) values ('UUID-HERE', 'developer');`  
        (`developer` = dev bubble + paid-equivalent in app logic; **`admin`** = backend-only elevated access, same app gates.)
  - [ ] **5.4** Verify: logged in as that user → app can load staff role (settings may show staff line); **developer** sees dev navigator bubble after refresh/routing rules.
- [ ] **6.0** **Device QA** checklist
  - [ ] **6.1** Fresh install → complete onboarding → **Sign in with Apple** → lands on auth/paywall as designed.
  - [ ] **6.2** Sandbox Apple ID purchase (or sandbox restore) → **Glu Gold** active → routed to **main** tabs (`AppState` + RevenueCat subscriber state).
  - [ ] **6.3** **Restore purchases** from paywall/settings works when entitled.
  - [ ] **6.4** **History / meal_logs**: analyze a meal while signed in → row appears remotely under RLS (**Table Editor → `meal_logs`**).
  - [ ] **6.5** **Non‑developer**: no floating dev bubble. **Developer**: dev bubble appears; jumps change phase/tabs without breaking subscriber rules.
  - [ ] **6.6** Regression: staff user **without** subscription still reaches main **if** `admin`/`developer` (matches `AccessEvaluator`).
- [ ] **7.0** *(Optional backlog)*
  - [ ] **7.1** RevenueCat **server notifications** / webhook → optional mirror subscription state server-side ([Connect server notifications](https://www.revenuecat.com/docs/projects/connect-server-webhooks)).
  - [ ] **7.2** CI: cache SPM artifacts (e.g. `-clonedSourcePackagesDirPath`) so `xcodebuild` skips long **Resolve Package Graph** (see [`apps/GluAI/README.md`](apps/GluAI/README.md)).

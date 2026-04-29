# Technical Architecture — [App Name]

> GUIDANCE: This file is for engineers. Be concrete: name the libraries, version pins where they matter, name the cloud regions, name the cost line items. Cal AI–archetype apps run on a small, well-known stack. Don't reinvent. Default to the stack below; deviate only with reason.

## Stack at a glance

```
┌─────────────────────────────────────────────────┐
│  iOS Client (SwiftUI, iOS 17+)                  │
│  - RevenueCat SDK (subscriptions)               │
│  - Superwall SDK (paywall A/B)                  │
│  - Supabase Swift SDK (auth, db, storage)       │
│  - Mixpanel SDK (analytics)                     │
│  - Sentry SDK (crash + perf)                    │
│  - OneSignal SDK (push notifications)           │
└──────────────────┬──────────────────────────────┘
                   │ HTTPS
                   ▼
┌─────────────────────────────────────────────────┐
│  Backend (Supabase)                             │
│  - Postgres (users, content, subscriptions)     │
│  - Auth (Apple, Google, magic link)             │
│  - Storage (user photos, generated assets)      │
│  - Edge Functions (AI proxy, webhooks)          │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┴───────────┐
        ▼                      ▼
┌──────────────┐      ┌──────────────────┐
│ AI Providers │      │ RevenueCat       │
│ (OpenAI,     │      │ (subscription    │
│  Anthropic,  │      │  source of truth)│
│  Replicate)  │      └──────────────────┘
└──────────────┘
```

## Frontend (iOS)

| Concern | Choice | Why |
|---|---|---|
| **Language** | Swift 5.9+ | iOS native |
| **UI framework** | SwiftUI | Modern, declarative, Apple-recommended for new apps |
| **Min iOS version** | iOS 17.0 | Covers ~95% of active devices, gives access to modern SwiftUI |
| **State management** | SwiftUI `@Observable` + scoped `@State` | Avoid Redux/TCA unless team has experience |
| **Networking** | URLSession + async/await; Supabase Swift SDK for backend calls | Native, no Alamofire needed for V1 |
| **Persistence (local)** | SwiftData | Modern, works with SwiftUI; falls back to UserDefaults for simple flags |
| **Image handling** | NukeUI (or Kingfisher) | Caching, prefetching, placeholders |
| **Payments SDK** | RevenueCat | De facto standard for iOS subscriptions |
| **Paywall SDK** | Superwall | Remote-config paywall, A/B test without app review |
| **Analytics SDK** | Mixpanel + RevenueCat events | Mixpanel for funnels; RC is source of truth for revenue |
| **Crash + perf** | Sentry | Better than Crashlytics for SwiftUI |
| **Push** | OneSignal | Free tier covers V1; switch to APNs direct at scale |
| **Feature flags** | PostHog or Statsig | If A/B testing in-app features beyond paywall |

### Project structure

```
App/
├── App.swift                    # @main entry
├── Features/
│   ├── Onboarding/             # 22-screen flow, see onboarding.md
│   ├── Paywall/                # Superwall integration
│   ├── Home/                   # Tab 1
│   ├── [CoreAction]/           # Tab 2 (the camera/scan/generate flow)
│   ├── History/                # Tab 3
│   └── Settings/               # Profile, subscription, delete account
├── Core/
│   ├── Auth/                   # Supabase auth wrappers
│   ├── AI/                     # AI client + prompts
│   ├── Analytics/              # Tracking facade
│   ├── DesignSystem/           # Colors, typography, components
│   └── Networking/             # API layer
├── Models/                     # Domain models, SwiftData entities
└── Resources/                  # Assets, Localizable.strings
```

## Backend

| Concern | Choice | Why |
|---|---|---|
| **Provider** | Supabase | Postgres + Auth + Storage + Edge Functions in one product. Generous free tier. Easier than Firebase for relational data. |
| **Database** | Postgres 15 (managed by Supabase) | Real SQL, real schemas, real migrations |
| **Auth** | Supabase Auth | Apple, Google, magic link out of the box; integrates with iOS SDK |
| **Storage** | Supabase Storage (S3-compatible) | User photos and AI-generated outputs |
| **Edge Functions** | Deno (Supabase) or Cloudflare Workers | For AI proxy (so API keys don't ship in the app) and webhook handlers |
| **Region** | `us-east-1` (or `eu-west-1` if EU-first) | Matches AI provider regions to reduce latency |

### Why a backend at all (vs. pure on-device AI)?

1. **API keys** — never ship OpenAI/Anthropic keys in the app binary; they'll be extracted in 5 minutes
2. **Rate limiting & abuse prevention** — block users who burn through inference
3. **Subscription validation** — RevenueCat webhooks update Postgres, gating premium features server-side
4. **Multi-device sync** — user logs in on a new phone, all data is there

### Database schema (V1, minimum viable)

```sql
-- users (managed by Supabase Auth, with profile extension)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  display_name text,
  onboarding_completed_at timestamptz,
  onboarding_responses jsonb,  -- the 22 onboarding answers
  created_at timestamptz default now()
);

-- core entries (rename to match domain: meals, scans, generations, etc.)
create table entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  photo_url text,
  ai_output jsonb,             -- whatever the AI returned
  created_at timestamptz default now()
);

-- subscription mirror (synced from RevenueCat webhooks)
create table subscriptions (
  user_id uuid primary key references profiles(id) on delete cascade,
  status text,                 -- active, expired, in_grace_period, etc.
  product_id text,
  expires_at timestamptz,
  updated_at timestamptz default now()
);

-- Row-Level Security: every table requires user_id = auth.uid()
```

> Full schema, migrations, and RLS policies live in `/supabase/migrations/`.

## AI inference

> See `ai.md` for full model details. Architecture-level concerns:

- **Proxy pattern** — All AI calls go through Supabase Edge Functions, not directly from app to OpenAI
- **Streaming** — Use SSE for LLM responses where applicable; fall back to polling for image/video gen
- **Caching** — Cache deterministic AI outputs (e.g., same image → same calorie count) with content-hash keys in Supabase Storage. Saves 30–50% of inference cost at scale.
- **Fallback** — If primary provider returns 5xx, retry once, then fall back to secondary provider. Surface to user as "Couldn't analyze, try again" — never crash.

## Subscriptions & monetization

- **RevenueCat is the source of truth** for who is and isn't paying. Server checks RC; app reads RC SDK locally.
- **Webhook flow:** RC → Supabase Edge Function → updates `subscriptions` table → propagates entitlement to user
- **Entitlement check:** `is_premium = subscriptions.status in ('active', 'in_grace_period') AND expires_at > now()`
- **Restore purchases:** Required on paywall + settings; calls `Purchases.shared.restorePurchases()`
- **Test environment:** Sandbox accounts on TestFlight, separate RC project for staging

## Analytics events

> Define a small, focused event taxonomy. Don't track everything. Cal AI–archetype apps care about ~15 events. See `appstore.md` "Success metrics" for what's worth instrumenting.

| Event | When | Properties |
|---|---|---|
| `app_opened` | App launches | session_id |
| `onboarding_started` | First onboarding screen shown | source |
| `onboarding_screen_viewed` | Each screen | screen_name, screen_index |
| `onboarding_completed` | Final screen | total_duration_seconds, responses |
| `paywall_shown` | Paywall mounts | placement, variant_id |
| `paywall_dismissed` | User backs out without converting | dwell_time_seconds |
| `trial_started` | Subscription purchase initiated | product_id, price |
| `trial_converted` | Trial → paid | days_in_trial |
| `[core_action]_started` | User starts the magic moment | — |
| `[core_action]_completed` | Successful AI output | duration_ms, model_used |
| `[core_action]_failed` | AI errored | error_code, model_used |
| `subscription_canceled` | User cancels | tenure_days |
| `app_rated` | App Store rating prompted/given | rating |

## Cost model (estimated, at 10K MAU)

> GUIDANCE: Engineers and founders should know the unit economics. Update with real numbers post-launch.

| Service | Cost basis | Estimated monthly |
|---|---|---|
| Supabase | Pro tier + storage + bandwidth | $25–$100 |
| RevenueCat | First $10K MTR free, then 1% | $0–$100 |
| Superwall | Free up to ~$10K MTR | $0–$200 |
| OpenAI/Anthropic inference | Per-call, see `ai.md` | $200–$2,000 |
| Mixpanel | 100K events free, then ~$25/100K | $25–$200 |
| Sentry | Team tier | $26 |
| OneSignal | Free up to 10K subscribers | $0 |
| Cloudflare (image/video CDN if used) | Bandwidth + R2 | $0–$50 |
| **Total est.** |  | **$280–$2,700** |

If LTV is ~$30 and CAC is ~$10, that's $20 contribution margin per paying user. At 10K MAU and 8% paid conversion = 800 paying = $24K MRR vs. $2.7K infra = healthy.

## Security

- **API keys never in the app** — all third-party AI keys live in Supabase Edge Functions secrets
- **Row-Level Security (RLS)** on every Postgres table — users can only read/write their own rows
- **Sign In with Apple** is the default; Google fallback; magic link as accessibility fallback
- **App Transport Security** — HTTPS only, no exceptions
- **Photo data** — store in Supabase Storage with signed URLs (15-minute TTL), not public buckets
- **Account deletion** — when user deletes account, cascade delete all rows, all storage objects, all RC entitlements (compliance with GDPR/CCPA + App Store rule 5.1.1(v))

## Deployment & CI

- **Source control:** GitHub
- **CI:** GitHub Actions runs SwiftLint + unit tests on PR
- **Builds:** Xcode Cloud or Bitrise for TestFlight + App Store builds
- **Backend deploys:** Supabase CLI from CI (`supabase db push`, `supabase functions deploy`)
- **Feature flag releases:** Toggled remotely via PostHog/Statsig — no app review for behavior changes

## Open technical questions

> GUIDANCE: List the engineering questions that aren't fully resolved. These are what the engineering team should debate in week 1.

1. [Question, e.g., "On-device model for X to reduce inference cost?"]
2. [Question]
3. [Question]

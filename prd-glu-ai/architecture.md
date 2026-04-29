# Technical Architecture — Glu AI

## Stack at a glance

```
┌─────────────────────────────────────────────────┐
│  iOS Client (SwiftUI, iOS 17+)                  │
│  - RevenueCat (subscriptions)                    │
│  - Superwall (paywall A/B)                     │
│  - Supabase Swift (auth, DB, storage)          │
│  - Mixpanel + RevenueCat events                │
│  - Sentry                                       │
│  - OneSignal (push)                            │
└──────────────────┬──────────────────────────────┘
                   │ HTTPS only
                   ▼
┌─────────────────────────────────────────────────┐
│  Supabase                                       │
│  - Postgres (profiles, meals, subscriptions)    │
│  - Auth (Apple, Google, magic link)             │
│  - Storage (meal photos)                        │
│  - Edge Functions (AI proxy, RC webhooks, del)  │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                      ▼
┌──────────────────┐   ┌─────────────────┐
│ AI providers      │   │ RevenueCat       │
│ (via Edge proxy   │   │ (entitlements)   │
│  only — no keys   │   └─────────────────┘
│  in iOS binary)    │
└──────────────────┘
```

**Rule:** All model calls go through **Supabase Edge Functions** (`analyze-meal`, etc.). The iOS app never holds OpenAI / Anthropic / Google API keys.

## Frontend (iOS)

| Concern | Choice | Why |
|---|---|---|
| Language | Swift 5.9+ | Native performance |
| UI | SwiftUI | PRD target stack |
| Min iOS | 17.0 | Broad device coverage + modern APIs |
| State | `@Observable` services + local persistence | Keeps onboarding resume simple |
| Networking | URLSession async/await; Supabase SDK | |
| Local cache | SwiftData for onboarding draft; UserDefaults for flags | |
| Images | NukeUI or Kingfisher | Thumbnails + disk cache |
| Payments | RevenueCat | Subscriptions |
| Paywall UI | Superwall | Remote copy and experiments |
| Analytics | Mixpanel + RC | Funnels + revenue |
| Crashes | Sentry | |
| Push | OneSignal | Reminders per onboarding prefs |

### Project structure

```
GluAI/
├── App.swift
├── Features/
│   ├── Onboarding/
│   ├── Paywall/
│   ├── Home/
│   ├── MealCapture/        # camera + result
│   ├── History/
│   └── Settings/
├── Core/
│   ├── Auth/
│   ├── AI/                 # client calls Edge only
│   ├── Analytics/
│   ├── DesignSystem/
│   └── Networking/
├── Models/
└── Resources/
```

## Backend

| Concern | Choice | Why |
|---|---|---|
| Provider | Supabase | Auth + Postgres + Storage + Functions together |
| DB | Postgres 15 | Relational meal history, JSONB for AI payloads |
| Auth | Supabase Auth | Apple / Google / OTP |
| Storage | Supabase Storage | Private meal images per user |
| Functions | Deno on Supabase | AI proxy, webhooks |
| Region | `us-east-1` default | Align with primary model region; EU project if launching EU-first |

### Database schema (V1)

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  display_name text,
  onboarding_completed_at timestamptz,
  onboarding_responses jsonb,
  notification_pref jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  photo_path text not null,
  ai_output jsonb not null,
  user_notes text,
  created_at timestamptz default now()
);

create table subscriptions (
  user_id uuid primary key references profiles(id) on delete cascade,
  status text not null,
  product_id text,
  expires_at timestamptz,
  updated_at timestamptz default now()
);

-- RLS: enable on all tables; policies user_id = auth.uid() for meals
```

`ai_output` stores the structured response: items, totals, `spike_risk`, `rationale`, `confidence`, `disclaimer_version`.

## AI inference

- **Edge Function** `analyze-meal`: validates JWT, checks subscription mirror + RevenueCat-style entitlement (see below), fetches image from Storage signed URL, calls configured multimodal model, validates JSON schema server-side, logs latency and token usage, returns JSON to app.
- **No streaming** for V1 vision path — single JSON response under timeout (e.g., 25s server, 30s client) with intermediate “still working” UI.
- **Caching:** Hash image bytes + model version; optional short TTL cache table or KV to dedupe accidental double-taps.
- **Rate limits:** Per user per day for meal analyses; tune with costs (see `ai.md`).

## Subscriptions & monetization

- RevenueCat is **source of truth** in the app; `subscriptions` table updated via Edge webhook for server-side gates.
- **Entitlement:** `premium` required for `analyze-meal` and for reading full history beyond optional teaser (product decision: **hard paywall** means post-paywall everything premium; no free inference).
- Restore purchases: paywall + settings.

## Analytics events

| Event | When | Properties |
|---|---|---|
| `app_opened` | Launch | `session_id` |
| `onboarding_started` | Screen 1 | `attribution_pending` |
| `onboarding_screen_viewed` | Each screen | `screen_index`, `screen_name` |
| `onboarding_completed` | Pre-auth last onboarding step | `duration_s` |
| `auth_completed` | Session established | `provider` |
| `paywall_shown` | Superwall impression | `placement`, `variant` |
| `paywall_dismissed` | Close without purchase | `dwell_s` |
| `trial_started` | Purchase success | `product_id` |
| `meal_capture_started` | Camera open | — |
| `meal_analysis_completed` | Success | `latency_ms`, `spike_risk`, `model` |
| `meal_analysis_failed` | Error | `error_code` |
| `meal_saved` | User confirms save | — |
| `account_deleted` | Deletion completes | — |

## Cost model (estimated, order-of-magnitude at 10K MAU)

| Service | Basis | Est. monthly |
|---|---|---|
| Supabase | Pro + storage + egress | $25–$120 |
| RevenueCat | % of MTR | $0–$150 |
| Superwall | MTR-based | $0–$250 |
| Vision LLM via Edge | Per-image + tokens (see `ai.md`) | $300–$2,500 |
| Mixpanel | Events | $25–$200 |
| Sentry | Team | ~$26 |
| OneSignal | Free tier early | $0 |
| **Total** | | **$400–$3,200** |

Premium-only inference keeps vision calls bounded by paying users. Monitor **cost per paying user** weekly.

## Security

- Secrets only in Supabase Function secrets / project settings
- RLS on `meals` and `profiles`
- Signed URLs for photos; bucket not public
- Strict JSON schema validation on AI output; reject missing disclaimer fields
- Account deletion Edge Function cascades meals, storage objects, anonymizes analytics where APIs allow

## Deployment & CI

- GitHub + Actions: SwiftLint, unit tests on PR
- Xcode Cloud or CI macOS runner for TestFlight
- `supabase db push` + `supabase functions deploy` from protected branch

## Open technical questions

1. Whether to add **HealthKit** write (carbs) in V1 or defer to V2 for scope and privacy review.
2. On-device **barcode** scan in V2 for packaged foods to improve accuracy hybrid.
3. Optional **human-in-the-loop** correction dataset — privacy review before training.

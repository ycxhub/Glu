# Glu AI — test harness (v1 trust boundary)

## Edge (`analyze-meal`)

From repo root:

```bash
cd supabase/functions/analyze-meal && deno test edge_contract_test.ts
```

## iOS

Open `OneshotApp.xcodeproj` in Xcode and run the **OneshotApp** scheme on a simulator. There is no XCTest target in this template yet; add one to host unit tests for `MealAnalyzeResult` decoding, `GluInstallId`, and onboarding JSON loading.

## SQL / RLS

Apply migrations to a dev project, then manually verify:

- `reserve_meal_analysis` / `finalize_meal_analysis` / `release_meal_analysis` with concurrent clients.
- `meal_logs` RLS: user can only `select/update/delete` own rows.
- `revenuecat_entitlements` idempotent upserts on duplicate webhook payloads.

## Eval fixtures

See `apps/GluAI/evals/spike_envelope_fixtures.json` for forbidden-phrase examples aligned with the Edge sanitizer regex set.

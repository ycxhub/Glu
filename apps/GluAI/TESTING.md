# Glu AI — test harness (v1 trust boundary)

## Edge (`analyze-meal`)

From repo root:

```bash
cd supabase/functions/analyze-meal && deno test edge_contract_test.ts
```

## iOS

The iOS app uses a dual-pronged QA strategy designed to be driven by AI agents:

1. **Snapshot Tests (`OneshotAppTests`)**: We use `swift-snapshot-testing` to catch visual regressions without needing manual device checks.
2. **UI Tests (`OneshotAppUITests`)**: We use XCUITest to verify E2E flows (e.g., logging a meal, navigating the dashboard) using the Accessibility tree.

### Running Agent QA

To run the automated QA suite (which executes tests, generates reports, and extracts screenshots for AI inspection), use the provided script from the repository root:

```bash
./apps/GluAI/bin/ios-qa.sh
```

**Note:** For the best experience, ensure `xcbeautify` and `xcparse` are installed via Homebrew to format the output and extract UI test screenshots.

## SQL / RLS

Apply migrations to a dev project, then manually verify:

- `reserve_meal_analysis` / `finalize_meal_analysis` / `release_meal_analysis` with concurrent clients.
- `meal_logs` RLS: user can only `select/update/delete` own rows.
- `revenuecat_entitlements` idempotent upserts on duplicate webhook payloads.

## Eval fixtures

See `apps/GluAI/evals/spike_envelope_fixtures.json` for forbidden-phrase examples aligned with the Edge sanitizer regex set.

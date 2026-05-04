#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/OneshotApp"
SCHEME="$ROOT/OneshotApp.xcodeproj/xcshareddata/xcschemes/OneshotApp.xcscheme"

test -f "$APP/PrivacyInfo.xcprivacy"
grep -q "com.apple.developer.in-app-purchase" "$APP/OneshotApp.entitlements"
grep -q "Configuration.storekit" "$SCHEME"
test -f "$ROOT/Config/Configuration.storekit"
test -f "$ROOT/RUNBOOK.md"

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --config "$ROOT/../../.swiftlint.yml" "$APP"
fi

git -C "$ROOT/../.." grep -nE '"Glu Gold"|"glu_gold"' -- 'supabase/functions/*.ts' 'supabase/functions/**/*.ts' ':(exclude)supabase/functions/_shared/entitlements.ts' && exit 1 || true
git -C "$ROOT/../.." grep -nE "'Glu Gold'|'glu_gold'" -- 'supabase/migrations/*.sql' ':(exclude)supabase/migrations/20260503120000_glu_quota_entitlements_envelope.sql' ':(exclude)supabase/migrations/20260504000000_entitlement_helper.sql' && exit 1 || true

echo "GluAI preflight checks passed."

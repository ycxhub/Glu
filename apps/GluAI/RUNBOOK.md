# GluAI Paywall Runbook

## RevenueCat Webhook Offline

Supabase function logs show 5xx responses and RevenueCat is retrying events. Fix and redeploy the Edge Function, then run a RevenueCat backfill before launch traffic resumes.

## Apple Shared Secret Rotated

Generate a new app-specific shared secret in App Store Connect, paste it into RevenueCat, verify a sandbox purchase, then revoke the old secret after RevenueCat's grace window.

## App Store Product Approval Delay

Do not submit the app until annual and monthly products are ready to submit and attached to the app version. Query App Store Connect daily while blocked.

## RevenueCat Outage

The server hot path uses the Supabase `revenuecat_entitlements` mirror. Paying users keep access through the mirror. Offerings fetch may fail; keep Restore visible and show a temporary subscription-unavailable message.

## Webhook Secret Leaked

Rotate `REVENUECAT_WEBHOOK_AUTH` in RevenueCat and Supabase together. Verify the new value is at least 32 bytes and that webhook deliveries return 200.

## Sentry Quota Exhausted

Lower trace sampling and investigate noisy errors before restoring the default sample rate.

## Mixpanel Quota Exhausted

Sample non-revenue analytics first. Revenue, restore, entitlement, and purchase failure events should remain unsampled.

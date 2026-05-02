# Authentication — Glu AI

## Auth philosophy

1. **Apple-first** — Primary button; fastest path for iOS users; required if Google is offered (App Store guideline).
2. **No passwords** — OAuth + email magic link only.
3. **Late account** — Auth at onboarding screen 20, after plan reveal, immediately before hard paywall — matches funnel in `onboarding.md`.
4. **One human per account** — V1 single profile; no family sharing.

## Supported providers

| Provider | Required? | Placement | Notes |
|---|---|---|---|
| Sign in with Apple | Yes (if Google offered) | Screen 20 top | Native `ASAuthorizationController` |
| Sign in with Google | Recommended | Second | `GIDSignIn` or Supabase hosted flow |
| Email magic link | Recommended | Tertiary | Accessibility + corporate users |

No SMS/phone in V1.

## Sign-up screen (onboarding screen 20)

- **Title:** “Save your plan”
- **Body:** “Create an account to sync meals, streaks, and preferences across devices.”
- **Buttons:** Continue with Apple (black) · Continue with Google (outlined) · “Use email instead” ghost
- **Footer:** “By continuing you agree to the Terms of Service and Privacy Policy.” (tappable links)

Post-success navigation: **Paywall** (Superwall) → on active entitlement → main tabs.

## Sign in with Apple flow

1. Tap Apple button
2. System sheet → Face ID / passcode
3. Receive `identityToken` + user identifier
4. `supabase.auth.signInWithIdToken(provider: .apple, idToken: ...)`
5. On first sign-in persist `fullName` components if provided (only once from Apple)
6. Upload local onboarding answers to `profiles.onboarding_responses`
7. Register RevenueCat with stable `app_user_id` = Supabase `user.id` UUID string
8. Present paywall

**Developer setup:** Apple capability, Services ID, key in Supabase, Xcode capability enabled.

**Relay emails:** Store as given; cannot merge across apps; handle Apple server notifications (see below).

## Sign in with Google flow

1. Tap Google → Google SDK or OAuth web flow
2. Exchange ID token with Supabase `signInWithIdToken(provider: .google)`
3. Same steps 6–8 as Apple

**Setup:** Google Cloud OAuth iOS client + web client for Supabase; URL schemes in Info.plist.

## Email magic link flow

1. Expand email form
2. `signInWithOtp(email)`
3. Branded Supabase email template: “Sign in to Glu AI — link expires in 60 minutes”
4. Universal Links → app handles session exchange
5. Same sync + RC + paywall path

**Rate limit:** Max 3 OTP emails per hour per address (Edge middleware or Supabase hook).

## Session management

- Supabase session in Keychain via SDK defaults
- Auto refresh; on revoke → sign out to welcome
- Sign out clears local caches but **warns** if offline unsynced meals exist (future); V1 may block sign-out until sync completes if pending queue added later

## Account linking

- Prefer single email identity. Implement Edge-assisted linking if duplicate risk with Google real email vs Apple relay (cannot unify relay with Google directly — treat as separate accounts unless user uses same real email on Apple “share email”).

## Account deletion (App Store 5.1.1(v))

**Entry:** Settings → Account → Delete my account

**UX:**
1. Explain: deletes profile, meals, photos, push tokens, analytics subject to vendor APIs, and revokes app access.
2. Clarify subscriptions: “Deleting your account does **not** auto-cancel Apple subscriptions. Manage billing in Apple ID subscriptions.” with link.
3. Type `DELETE` confirmation
4. Call Edge `delete-user`:
   - Delete `meals` rows + storage objects under `user_id/`
   - Delete `profiles` + `subscriptions` mirror
   - `auth.admin.deleteUser(id)` server-side
   - RevenueCat subscriber delete API
   - OneSignal player delete
   - Mixpanel GDPR delete API if enabled
5. Local sign-out → onboarding welcome screen (or marketing welcome depending product choice — default: welcome screen 1)

## Apple Server-to-Server notifications

- Register `https://<project>.functions.supabase.co/apple-sso` (exact path TBD) for consent-revoked and account-delete events
- On `account-delete` or `consent-revoked`: treat as forced sign-out + scheduled data purge same as user-initiated delete

## Security checklist

- [ ] No AI or third-party secret keys in the iOS binary
- [ ] ATS HTTPS only
- [ ] JWT verification on Edge for all privileged routes
- [ ] RLS policies tested with non-owner JWT (must fail)
- [ ] Magic link rate limits
- [ ] Restore purchases visible
- [ ] Sign in with Apple tested on device + Simulator limitations documented

## Testing accounts

- Dedicated Apple ID + Google account for QA and App Review
- Credentials in 1Password / team vault — **never** committed
- App Review notes include test login path if paywall blocks guests

## Open auth questions

1. Whether to require email magic link verification before enabling purchases (adds friction — default no).
2. Whether enterprise SSO is ever needed (unlikely V1).

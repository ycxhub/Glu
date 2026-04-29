# Authentication — [App Name]

> GUIDANCE: For consumer iOS apps, auth is mostly a solved problem — get it wrong only by trying to be clever. Use Supabase Auth + Sign in with Apple + Sign in with Google. Email magic link as fallback. No passwords. Account deletion is mandatory (App Store rule 5.1.1(v)). This file documents the flows.

## Auth philosophy

1. **Apple-first** — Sign in with Apple is the default option, top of the list, primary button styling. iOS users prefer it (one-tap, no email leakage), and Apple requires it if you offer any other social login.
2. **No passwords** — Passwords cause forgotten-password flows, security incidents, and friction. Use OAuth + magic link.
3. **Late account creation** — Don't ask the user to create an account on screen 1. Wait until after the value reveal in onboarding (screen ~20). The user is much more committed by then.
4. **One identity per user** — Same email across providers should map to one account. (Apple's relay email makes this tricky — see "Edge cases" below.)

## Supported providers

| Provider | Required? | When to show | Notes |
|---|---|---|---|
| **Sign in with Apple** | Required (App Store rule if any social offered) | Always, top of list, primary button | Default for iOS users; uses native sheet |
| **Sign in with Google** | Recommended | Always, secondary button | Best for users with Google accounts (most) |
| **Email magic link** | Recommended | "More options" tap or always-visible tertiary | Fallback for users who don't want social login; required for accessibility |
| **Phone (SMS)** | Skip for V1 | — | Adds Twilio dependency, complexity, fraud risk. Not worth it for V1. |
| **Password** | Never | — | Don't add this. |

## Sign-up screen (final onboarding screen, ~Screen 20)

```
┌─────────────────────────────────────┐
│  Save your plan                     │
│                                     │
│  Create an account so we can save   │
│  your progress and sync your data.  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  󰀵 Continue with Apple       │  │  <- Primary, black bg
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │   Continue with Google       │  │  <- Secondary, white bg
│  └──────────────────────────────┘  │
│                                     │
│  Or sign in with email              │  <- Tertiary, ghost
│                                     │
│  By continuing you agree to our     │  <- Required legal
│  Terms and Privacy Policy.          │
└─────────────────────────────────────┘
```

## Flow: Sign in with Apple

1. User taps "Continue with Apple"
2. iOS native sheet appears (`ASAuthorizationController`)
3. User authenticates via Face ID / Touch ID / passcode
4. iOS returns `userIdentifier`, `fullName` (first time only), `email` (or relay email)
5. iOS app sends ID token to Supabase Auth via `signInWithIdToken(provider: .apple)`
6. Supabase creates or matches user
7. App receives session, persists locally
8. App syncs onboarding data from local SwiftData → backend (`profiles.onboarding_responses`)
9. App proceeds to paywall

**Required Apple setup:**
- App ID configured with "Sign in with Apple" capability in Apple Developer portal
- Service ID created for backend OAuth (used by Supabase)
- Private key downloaded and configured in Supabase dashboard
- Configuration in Xcode: enable "Sign in with Apple" in capabilities

**Apple's privacy relay:** Users can choose to share their real email or a relay email (`xyz123@privaterelay.appleid.com`). Treat both as canonical for your app — store whichever Apple gives you. If user later changes their relay setting, you'll receive a new email; handle this via Apple Server-to-Server notifications (see "Apple Server Notifications" below).

**First-time-only data:** Apple returns `fullName` and `email` *only* on the first authorization. Subsequent sign-ins return only the `userIdentifier`. **Persist these on the first call** — there's no second chance.

## Flow: Sign in with Google

1. User taps "Continue with Google"
2. App opens Google sign-in via `GIDSignIn.sharedInstance.signIn()` (Google Sign-In SDK) or via Supabase Auth's Google OAuth flow
3. Google returns ID token + user profile
4. iOS app sends ID token to Supabase: `signInWithIdToken(provider: .google)`
5. Supabase creates or matches user
6. Same as Apple flow from step 7

**Required Google setup:**
- OAuth client created in Google Cloud Console (iOS type for native, Web type for Supabase)
- Reverse-DNS URL scheme added to Info.plist for the iOS callback
- Client ID configured in Supabase dashboard

## Flow: Email magic link

1. User taps "Or sign in with email"
2. App shows email input field + "Send link" CTA
3. User submits email → app calls Supabase `auth.signInWithOtp({ email })`
4. Supabase sends email with magic link (custom template recommended — Supabase default is generic)
5. User taps link → opens app via Universal Link (configured in app's Associated Domains)
6. App calls Supabase to exchange the token in URL for a session
7. Same as Apple flow from step 7

**Email template:** Customize in Supabase to match brand. Subject: "Your sign-in link to [App Name]". Body: link valid for 60 minutes, single-use.

**Universal Link setup:** Required so taps from Mail open the app, not Safari. Configure `apple-app-site-association` file at `https://[domain]/.well-known/apple-app-site-association`.

## Session management

- **Storage:** Supabase SDK stores access + refresh tokens in iOS Keychain (encrypted, survives app reinstall)
- **Token expiry:** Access token 1 hour, refresh token long-lived (~30 days)
- **Auto-refresh:** Supabase SDK handles refresh transparently
- **Multi-device:** Sign in on a new device → all data syncs from backend
- **Sign out:** Clears Keychain + local SwiftData, returns to welcome screen

## Account linking / merging

> GUIDANCE: Edge case but happens often: user signs in with Apple, later tries Google with the same email. Should be one account, not two.

**Strategy:** Match on canonical email at sign-in. If a user with that email already exists, link the new provider to the existing account. Supabase doesn't do this automatically — implement via Edge Function:

```
on auth.signIn() with provider B:
  email = decode_jwt(token).email
  existing_user = find_user_by_email(email)
  if existing_user:
    link_provider_to_user(existing_user.id, provider B, token)
    return existing_user.session
  else:
    create_user(email, provider B)
```

For Apple's relay emails, this is harder — relay emails are unique per app, so cross-app linking isn't possible. Within your app, treat relay email as canonical.

## Account deletion (REQUIRED — App Store rule 5.1.1(v))

> GUIDANCE: This is the most-rejected reason for App Store submissions. Get it right or you don't ship.

**Requirements:**
- Reachable from Settings without contacting support
- Confirmation step (type DELETE or biometric)
- Deletes all user data, not just deactivates
- Works end-to-end without human intervention
- Communicates what gets deleted

**Flow:**
1. Settings → Account → "Delete account"
2. Show confirmation: "This will permanently delete your account, all your entries, your subscription, and all your data. This cannot be undone."
3. Type-to-confirm: "Type DELETE to confirm"
4. App calls `/api/account/delete` (Supabase Edge Function)
5. Edge Function:
   - Marks user for deletion
   - Cascades delete: `entries`, `subscriptions`, all `storage` objects under user prefix
   - Calls RevenueCat API to delete the RC user (`DELETE /v1/subscribers/{id}`)
   - Calls Mixpanel/PostHog to delete user (GDPR right-to-be-forgotten)
   - Calls OneSignal to delete subscription
   - Deletes from `auth.users` (Supabase)
6. App signs user out, returns to welcome screen

**Apple subscription:** Important — deleting the account does NOT cancel an active App Store subscription. Apple owns the subscription. Tell the user: "Your subscription will continue until the end of the current period. To cancel, manage in your Apple ID settings." Provide a deep link to subscription management.

## Apple Server-to-Server notifications

> GUIDANCE: Apple sends notifications when users delete their Apple account, change their relay email, or revoke your app's access. Handle these or your DB will get out of sync.

**Endpoint:** `/api/apple/notifications` (Supabase Edge Function, signed by Apple)

**Notification types:**
- `email-disabled` — User disabled relay email forwarding. App will stop receiving emails to that relay address.
- `email-enabled` — User re-enabled
- `consent-revoked` — User revoked sign-in. Must sign user out and treat as deleted.
- `account-delete` — User deleted Apple ID entirely. Must delete account.

Apple requires you to register this endpoint URL in your Apple Developer portal.

## Security checklist

- [ ] No API keys or secrets in the iOS app binary
- [ ] All auth flows use HTTPS (App Transport Security)
- [ ] Tokens stored in iOS Keychain, not UserDefaults
- [ ] Backend validates every JWT on every request (don't trust client-asserted user IDs)
- [ ] Rate-limit magic link sends (max 3 per hour per email)
- [ ] Rate-limit failed token validations (deter abuse)
- [ ] Row-Level Security on every Postgres table — `auth.uid() = user_id`
- [ ] Sign out clears Keychain + local cache fully
- [ ] Account deletion verified end-to-end with test account
- [ ] Sign in with Apple Server Notifications endpoint registered

## Testing accounts

- Maintain a test Apple ID with known credentials for QA / TestFlight reviewers
- Maintain a test Google account
- Document credentials in 1Password / shared password manager (NOT in code)
- Provide credentials to App Store Review in submission notes

## Open auth questions

1. [Phone auth for international users where Google penetration is low? Adds complexity, may add later.]
2. [SSO for B2B / employer-paid plans? Not for V1.]
3. [Family sharing — one subscription, multiple users? V2+.]

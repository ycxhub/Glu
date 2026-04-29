# App Screens — [App Name]

> GUIDANCE: This file describes the *core product* — what the user uses every day after onboarding and paywall. Cal AI–archetype apps have **3–5 tabs maximum**. More than that = scope creep. The home screen and the core action screen do 90% of the work.

## Information architecture

```
[App Name]
├── Tab 1: Home              (today's overview, quick stats)
├── Tab 2: [Core action]     (the magic moment — camera, scan, generate)
├── Tab 3: History           (past entries, browseable)
├── Tab 4: Insights          (optional — trends, charts) ← cut for V1
└── Tab 5: Settings/Profile  (account, subscription, preferences)
```

For V1, default to **3 tabs**: Home, Core Action, Settings. Add History and Insights once core loop works.

> GUIDANCE: If your app's core action is *constantly* used (camera-first apps), promote it to a center-tab Floating Action Button or large center tab item — Cal AI puts the camera as the centerpiece.

## Screen 1: Home (Tab 1)

**Purpose:** "What's the state of my goal today?"

**What's on it:**
- Header: greeting + date ("Good morning, Sam")
- Hero metric: big number representing today's primary signal (calories remaining, streak count, score). 48pt display weight.
- Progress ring or bar: visual representation of progress toward today's goal
- Action affordance: "Add [thing]" CTA, opens core action flow
- Today's entries: scrollable list of items added today (meals, scans, generations)
- Streak / motivational moment: "You're on a 7-day streak 🔥"

**Empty state:** First-launch user has no entries. Show coachmark + arrow pointing to the core action CTA: "Tap here to [verb] your first [thing]"

**Interactions:**
- Tap an entry → opens detail view (sheet)
- Long-press entry → quick edit / delete
- Pull-to-refresh: re-fetch from backend (sync across devices)
- Tap streak → celebration animation + share sheet

**Data shown:** Today's entries from `entries` table where `created_at::date = today`, plus computed totals.

**Tracking events:**
- `home_viewed` (with property: streak_count, today_total)
- `entry_tapped`, `streak_tapped`, `add_entry_tapped`

## Screen 2: [Core Action] (Tab 2)

**Purpose:** The magic moment. The reason the user paid.

> GUIDANCE: This screen needs to be ruthlessly fast and frictionless. Every tap added here costs you retention. Cal AI's camera opens directly to the camera viewfinder — not a "choose camera or library" screen.

**Default state:** Open directly into the action UI.

- For **camera apps:** Camera viewfinder, large capture button, switch-camera + flash toggles, gallery thumbnail in corner
- For **scan apps:** Camera with target overlay (face frame, food frame, document frame)
- For **generate apps:** Text input field with placeholder + generate button, optional "Try an example" prompts

**On capture / submit:**
1. Show capture immediately (optimistic UI)
2. Transition to processing screen with skeleton + animated status text ("Analyzing...")
3. AI returns result (target: < 3s)
4. Show result screen (see Screen 2b)

**Result screen (Screen 2b):**
- Big visual: the captured photo / output / generated content
- AI output: the structured result, formatted nicely (calorie list, score breakdown, score, etc.)
- Actions: Save / Share / Retry / Edit
- Confidence indicator (if relevant): subtle visual hint when AI is uncertain
- Auto-save default: ON (auto-saves to history); user can manually delete

**Failure states:**
- AI errored → "Couldn't analyze. Try again with better lighting / clearer image" + Retry button
- Network down → "You're offline. We'll process this when you're back online" + queue locally
- Inappropriate content → "We can't process this content" (no detail; don't explain why)

**Tracking events:**
- `core_action_started` (when capture begins)
- `core_action_processing` (when AI call starts)
- `core_action_completed` (when result shown) — properties: duration_ms, confidence_avg
- `core_action_failed` — properties: error_code
- `result_saved`, `result_shared`, `result_retried`, `result_deleted`

## Screen 3: History (Tab 3)

**Purpose:** Browse, search, and re-engage with past entries.

**Layout:** Vertical scroll, grouped by date.

- Date headers (sticky as you scroll): "Today", "Yesterday", "October 18", etc.
- Entry rows: thumbnail + summary text + small stats
- Search bar at top (filter by name, date, content)
- Filter chips: "This week", "This month", "All time"

**Interactions:**
- Tap entry → detail sheet (same as home)
- Swipe left on row → Delete / Share
- Empty state: "Your entries will show up here" + CTA

**Data:** Last 30 days lazy-loaded; older fetched on scroll.

## Screen 4: Settings / Profile (Last Tab)

**Purpose:** Account, subscription, preferences, support.

**Sections (in order):**

1. **Profile**
   - Avatar (initials placeholder)
   - Name (tap to edit)
   - Email (read-only)
   - Onboarding answers — link to "Edit your goals"

2. **Subscription**
   - Current plan: "Premium · Annual" + renewal date
   - "Manage Subscription" → opens Apple subscription management
   - "Restore Purchases" (required by App Store)

3. **Preferences**
   - Notifications (toggle + manage which types)
   - Units (metric / imperial)
   - Dark mode (system / light / dark)
   - Apple Health integration (toggle, if applicable)

4. **Goals (re-edit onboarding answers)**
   - Goal weight / target / output
   - Goal speed
   - Diet / preferences

5. **Support**
   - "Contact us" → mailto: support@app.com
   - "FAQs" → in-app webview or web link
   - "Rate this app" → triggers SKStoreReviewController

6. **Legal**
   - Privacy Policy (link)
   - Terms of Service (link)
   - Open Source Licenses (link)

7. **Account**
   - Sign out
   - **Delete account** — REQUIRED by App Store rule 5.1.1(v). Must work end-to-end without contacting support.

8. **Footer (subtle, small)**
   - "Made with ☕ by [team]"
   - App version + build number (helps support tickets)

**Delete account flow:**
- Confirm dialog: "Delete account? This will permanently erase all your data, including [list]. This cannot be undone."
- Type-to-confirm: "Type DELETE to confirm"
- Calls backend `/api/account/delete` which cascades to: profiles, entries, storage objects, RC entitlement, push subscription
- Signs user out, returns to welcome screen

**Tracking events:**
- `settings_viewed`, `subscription_managed_tapped`, `account_deleted`

## Cross-cutting flows

### Notifications

- **Daily reminder:** "Don't forget to [core action] today" — sent at user-selected time (default 9 AM)
- **Streak alert:** "You're on a [N]-day streak! Keep it going." — sent if user hasn't logged today by 8 PM
- **Re-engagement:** "We miss you" — sent at day 3 of inactivity, then weekly
- **Milestone:** "You hit your [milestone]!" — sent on goal achievement

All managed via OneSignal segments and triggers; user can opt out per category in Settings.

### Sharing

- Native iOS share sheet from result screen, history entry, milestone celebration
- Share format: image with watermark + URL to install app (built-in viral loop)

### Apple Health (if applicable)

- Read: weight, steps, workouts (request explicit permission)
- Write: nutritional info, body measurements (with explicit permission)
- Settings toggle to disable

## Open product questions

> GUIDANCE: Things to debate before building.

1. **3 tabs or 4?** Recommend 3 for V1 (Home, Core Action, Settings). Add History as Tab 3 by month 2 if engagement data supports it.
2. **Offline mode?** V1 should queue captures offline and process when reconnected. Avoid shipping a "you're offline" wall.
3. **Multi-account / family?** V1 is single-user. Family accounts in V2+.

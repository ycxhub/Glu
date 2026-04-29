# App Screens — Glu AI

## Information architecture

```
Glu AI
├── Tab 1: Home            (today snapshot, streak, quick glance)
├── Tab 2: Log             (camera → analyze → result — center emphasis)
├── Tab 3: History         (past meals, filters)
└── Tab 4: Settings        (account, subscription, reminders, legal)
```

**V1:** Four tabs as above. “Insights” as a separate tab is **deferred** — a lightweight “This week” strip on Home covers early habit analytics.

## Tab 1: Home

**Purpose:** “How am I doing today with logging and meal awareness?”

**Contents:**
- Greeting + date
- **Streak** row: “7-day logging streak” with fire icon; tappable for micro-celebration (non-medical copy)
- **Today at a glance:** count of meals logged today; optional average of **educational** spike-risk distribution (e.g., “2 low · 1 medium today”) — never framed as glucose
- **This week strip:** simple bar chart of meal counts or stacked risk counts (informational)
- **Primary CTA:** “Log a meal” → switches to Log tab with camera ready
- **Recent meals:** last 3 cards pulled from `meals` (thumbnail, time, kcal, spike-risk pill)

**Empty state (first day post-paywall):** Coachmark pointing to Log tab: “Tap Log to capture your first meal.”

**Interactions:**
- Tap meal → `MealDetail` sheet (photo, numbers, rationale, disclaimer, delete)
- Pull-to-refresh syncs from Supabase

**Data:** `meals` for `created_at` in local day window; respect user timezone.

**Events:** `home_viewed`, `home_log_tapped`, `home_meal_tapped`

## Tab 2: Log (core action)

**Purpose:** Fastest path from hunger to saved structured log.

**Default:** Camera viewfinder fills safe area; secondary controls: torch, flip camera, small gallery picker.

**Flow:**
1. **Capture** — Still photo only V1 (video later).
2. **Processing** — Full-screen with branded progress + rotating strings (“Estimating portions…”, “Thinking about carbs, fiber, and sugar…”).
3. **Result** — `MealResultView`:
   - Hero photo
   - Totals row: kcal · carbs · fiber · sugar · protein · fat (layout scrolls on small phones)
   - **Spike risk** pill: Low / Medium / High + color from design system + text label for a11y
   - **Rationale** card: 2–3 sentences from model
   - **Disclaimer** footnote always visible: “Educational estimate only. Not medical advice.”
   - Chips for low-confidence items if `confidence` low
   - Actions: **Save** (primary), Retake, Discard
4. **Save** — Inserts `meals` row with `ai_output` JSON; optimistic UI then confirm toast.

**Failure:** Network/AI errors per `ai.md`; offline queue optional V1.1 (V1 can show blocking offline message + “try again”).

**Events:** `meal_capture_started`, `meal_analysis_started`, `meal_analysis_completed`, `meal_analysis_failed`, `meal_saved`, `meal_retried`, `meal_discarded`

## Tab 3: History

**Purpose:** Browse and reflect; bring notes to appointments.

**Layout:**
- Search (by free text in `user_notes` or rough item names client-side)
- Sticky date headers
- Rows: thumbnail · time · kcal · spike-risk pill
- Filters: Last 7 days / 30 days / All

**Detail sheet:** Same as Home; include “Add note” multiline field for clinician conversation prompts (stored `user_notes`).

**Swipe actions:** Delete (confirm), Share (image + summary card).

**Events:** `history_viewed`, `history_meal_opened`, `history_deleted`, `history_shared`

## Tab 4: Settings

**Sections (order):**

1. **Profile** — Display name, email (read-only), avatar initials
2. **Subscription** — Plan, renewal, Manage Subscription (StoreKit), Restore Purchases
3. **Reminders** — toggles aligned to onboarding promise; time pickers for lunch/dinner nudges
4. **Goals & preferences** — link to compact sheet re-editing key onboarding answers (diabetes type, tone, targets comfort) → PATCH `profiles.onboarding_responses`
5. **Data & privacy** — Export my data (V1.1 if needed), Privacy Policy, Terms
6. **Support** — Email support@gluai.app, FAQ link
7. **Diagnostics** — toggle “Share anonymized logs” for support (optional)
8. **Account** — Sign out, **Delete account** (required) with cascade per `auth.md`
9. **Footer** — Version/build

**Delete account:** Two-step confirm + type DELETE; call Edge delete function.

**Events:** `settings_viewed`, `subscription_manage_tapped`, `account_deleted`

## Cross-cutting flows

### Notifications

- Types: daily nudge, streak protection (“still time to log dinner”), trial ending (via RC)
- Deep link opens Log tab
- All user-configurable; respect system denial gracefully

### Sharing

- `UIActivityViewController` with rendered card: photo + totals + spike risk + watermark “Glu AI — educational estimates”

### Apple Health

- **V1 default:** Not integrated (reduces scope and privacy review). Settings may show “Coming soon” toggle **hidden** until shipped — avoid dead toggles in review build.

## Product copy guardrails (all screens)

- Never “predict your glucose.”
- Never insulin dose lines.
- Use “estimate,” “may,” “consider discussing with your clinician.”

## Open product questions

1. Whether Home shows any **numeric carb budget progress** or only logs count (safer V1: logs count + qualitative mix).
2. Offline queue priority vs ship-fast V1 blocking offline.
3. Future **clinician PDF export** of last 14 days of meals + notes.

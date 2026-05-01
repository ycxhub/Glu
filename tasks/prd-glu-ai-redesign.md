# PRD: Glu AI — Product Redesign (iOS)

## 1. Introduction / Overview

Glu AI is a **photo-first, glucose-aware meal tracker** on iOS (SwiftUI, native patterns). It delivers **rough** calorie and macro estimates, **educational** spike-risk context, and a **photo-based meal history**—without presenting as a medical device or generic calorie-counting app.

This PRD defines the **redesign scope** to align the live app with the product and design system described in:

- **`apps/GluAI/design.md`** — **authoritative** for any product or UX conflict  
- **`apps/GluAI/screens_updated.md`** — **screen and interaction brief**, maintained to match `design.md`

**Problem:** The current experience can drift from the intended brand (**Pastel Precision** / **Native iOS Premium + Pastel Journal**), information architecture, monetization model, and onboarding depth documented in these references.

**Goal:** Ship a cohesive redesign so the app feels **calm, trustworthy, and precise**, respects **accessibility** and **copy guardrails** (educational-only language), and implements the **19-step conversion-oriented onboarding**, **5 free meal analyses** then paywall, and **full Meal Estimate editing in v1**.

**Stakeholder decisions (this PRD):**

| Topic | Decision |
|--------|-----------|
| Onboarding | **~19-step** flow per `design.md` |
| Monetization | **5 free analyses**, then paywall; dismiss enters free mode |
| Meal Estimate | **Full editability in v1** (non-negotiable) |
| Doc conflicts | **`design.md` wins**; `screens_updated.md` aligned accordingly |
| Success focus | **Qualitative**: brand fit, accessibility, App Store readiness (no numeric targets mandated here) |

---

## 2. Goals

1. **Visual and brand alignment:** Implement **Pastel Precision** tokens (color, type, layout rhythm) and emotional tone (calm, non-judgmental, premium)—as specified in `design.md` and the visual sections of `screens_updated.md`.
2. **IA and navigation:** Use a **four-tab** shell—**Home**, **Log**, **History**, **Settings**—with native `TabView` / `NavigationStack` / sheets; **Log** emphasizes **camera-first** hierarchy (camera dominant vs. library).
3. **Onboarding:** Ship the **full 19-step** personalization funnel including **calculating** and **plan reveal**, with honest copy (no unsupported social proof), **`design.md` tier labels** (Gentle / Balanced / Focused; never “Careful”), and three plan-reveal bullets consistent with references.
4. **Monetization:** **Paywall after auth** with **`design.md` messaging**; **honest dismiss** into **free mode (5 analyses)**; clear counters; **paywall returns** when the limit is exhausted; **Glu Gold** entitlement via RevenueCat; **restore purchases** and legal links.
5. **Core logging loop:** Capture → analyze → **Meal Estimate** (rename from “Result”) → **edit** → save → **History** grid → **Meal Detail**; errors and loading states per brief.
6. **Trust and compliance (UX):** Consistent **educational-only** disclaimers, **spike-risk** language (not “health zone”), no fear-based or diagnostic copy—per copy guardrails in both references.
7. **Accessibility:** Dynamic Type, 44×44 pt targets, text + color for spike risk, Reduce Transparency / Reduce Motion / Increase Contrast checks, VoiceOver strings—including **free analyses remaining** where shown.
8. **Design deliverable parity:** Work to **`design.md` §§27–28** (high-fidelity, light/dark, edge states, component library expectation); engineering implements per SwiftUI and system APIs **current for 2026** (verify RevenueCat / Sign in with Apple / Supabase client docs at implementation time).

---

## 3. User Stories

1. **As a new user**, I want a **guided onboarding** that reflects my glucose context and goals, so the app feels **relevant** and I understand what Glu offers before paywall.
2. **As a user who is not ready to subscribe**, I want to **try the product with 5 meal analyses** with a **clear remaining count**, so I can evaluate Glu without confusion or a hidden trap.
3. **As a subscriber**, I want **unlimited analyses** and my **subscription status** visible in Settings, so I trust billing state.
4. **As a meal logger**, I want **camera** to be the obvious primary action on **Log**, so I can snap a meal quickly one-handed.
5. **As someone using AI estimates**, I want to **edit portions and line items** before saving, so the log reflects my meal when the model is wrong.
6. **As a history browser**, I want a **photo grid** with **small kcal and spike-risk** markers, so my diary is scannable and emotionally safe (no alarming red bars).
7. **As a user with accessibility needs**, I want **large type and VoiceOver** to work on **Home, Log, History, sheets, and paywall**, so I can use the app reliably.
8. **As a clinician-adjacent user**, I want language that stays **educational** and encourages **clinician questions**, so the app does not feel like it prescribes or diagnoses.

---

## 4. Functional Requirements

**Global / brand**

1. The app MUST present Glu AI as **educational meal awareness**, not medical advice—using approved phrasing from `design.md` / `screens_updated.md` (“estimated,” “spike-risk estimate,” “not medical advice,” etc.).
2. The app MUST NOT use deprecated UX copy **“health zone”**; use **spike-risk / meal risk context** language instead.
3. The visual system MUST follow **Pastel Precision** roles and hex direction in `design.md` §4 (cream base, powder blue home atmosphere, teal trust anchor, semantic macro tints, muted spike-risk pills—**no large alarming red/orange fills**).
4. Typography MUST use **SF Pro** at the **token scale** in `design.md` §5 / `screens_updated.md` §3; primary body text MUST remain **dark, readable** (not pastel-colored body copy).
5. Layout MUST follow **global rhythm**: 24 pt horizontal padding, 16 pt card radius (references specify 16 pt cards, 14 pt primary buttons), **44×44 pt** minimum tap targets, **1:1** history tiles.
6. The app MUST support **Dark mode** per **`design.md` §24** (premium, calm; reduced saturation pastels; no pure-black neon aesthetic).
7. Motion MUST be **subtle** (sheet transitions, soft loading); MUST respect **Reduce Motion**; avoid alarm-like high-risk animation (`design.md` §22 / `screens_updated.md` §22).

**Platform / chrome**

8. Navigation MUST use **native** patterns: `NavigationStack`, `TabView`, standard sheets and toolbars; on supported SDKs, **system chrome** MAY use Liquid Glass where appropriate; content surfaces MUST stay **readable and mostly opaque**—**no glass-on-glass** or glass over dense numeric content (`design.md` §7 / `screens_updated.md` §5).

**Onboarding (19 steps)**

9. The app MUST implement the **19-step** flow in **`design.md` §10** / **`screens_updated.md` §7** (step IDs: `welcome` through `reveal`, including `carb_think`, `tried_log`, `promise`, `calculating`, `attribution`, etc.).
10. Each onboarding screen MUST have **one primary question** and **one primary CTA**; MUST include **back** navigation and a **soft progress** indicator.
11. **Optional multi-select** steps MUST allow continue with no selection; **“None of these”** MUST deselect other options and vice versa (rules in references).
12. **Plan reveal** MUST use tier labels **Gentle / Balanced / Focused** only; MUST NOT use **Careful** as a tier label.
13. **Plan reveal** MUST show **three bullets**, including fiber/added-sugar awareness and **clinician / educational** disclaimer bullet—consistent with `screens_updated.md` **Plan Reveal Bullets**.
14. **Promise / info** steps MUST NOT use unsupported claims (e.g. unverified “3 weeks” habit stats); use approved replacement copy from references.
15. **Notification priming** step MUST offer **Enable Reminders** and a **functional “Maybe later”** (`screens_updated.md` §17).

**Auth**

16. After onboarding, the app MUST show **Auth** before paywall, with **Save your plan** and body copy per **`design.md` §11** (**sign in to keep plan and meal history synced**).
17. The primary action MUST be **Sign in with Apple** (native button). **Google** MUST appear only if implemented.
18. **QA / mock sign-in** MUST be hidden in production builds.

**Paywall and free mode**

19. The app MUST show **paywall after Auth**, following **`design.md` §§8–9** and **`screens_updated.md` §9**.
20. **Subscribe / start trial** MUST unlock **Glu Gold** (full access) via **RevenueCat** (entitlement name per product config; references use **Glu Gold**).
21. **Dismiss** MUST be **explicitly labeled** (e.g. **Continue with 5 free analyses** / **Try 5 meals first**); MUST NOT use an unlabeled control with surprising behavior.
22. Free mode MUST grant exactly **5 meal photo analyses** (or product-owned number—if changed, update all UI strings consistently); MUST allow **estimate view**, **save meals**, and **history** for those meals; MUST show **remaining count** on **Home**, **Log**, and **Settings** as specified in `design.md`.
23. When remaining analyses reach **zero** for non-subscribers, the app MUST **block new analysis** until **paywall** is shown with context copy from references; MUST NOT feel like a dark pattern (“trap”).
24. Paywall MUST include **Restore purchases**, **Terms**, **Privacy**; MUST avoid fear-based and medical-revenue copy.
25. **Development builds** MAY expose fallback controls (e.g. missing RevenueCat key) as in `screens_updated.md` §9.

**Main tabs — Home**

26. Home MUST show **Today** dashboard sections per **`design.md` §12** / **`screens_updated.md` §10**: greeting, **free mode counter when applicable**, today summary (meals, est. kcal, est. carbs), spike-risk distribution, streak, **one** AI insight card, up to **5 recent meals**, empty state with CTA toward logging.
27. Recent meal rows MUST be **tappable** and open **Meal Detail** (not decorative-only cards).

**Main tabs — Log**

28. Log MUST make **Camera** visually **dominant** over **Library** per hierarchy tables in references.
29. Log MUST show **free analysis count** near capture when in free mode; after **5th** analysis, MUST gate with paywall before next analysis (`design.md` §13).
30. Successful analysis MUST open **Meal Estimate** sheet; errors MUST use calm, recoverable copy (`screens_updated.md` §§18–19).

**Meal Estimate and editing**

31. The sheet title MUST be **Meal Estimate** (not “Result”).
32. The sheet MUST show: photo, calories, spike-risk pill, macros, confidence, detected items/assumptions, rationale, disclaimer, **Save**, **Edit estimate**, **Discard**—per **`design.md` §15** / **`screens_updated.md` §12**.
33. **v1 MUST ship full editing** before save: portion, correct foods, remove item, add item, adjust quantity, **save corrected estimate** with updated calories/macros (`design.md` §15).
34. Each line item MUST support edit/remove affordances as in **`design.md` “Editable food row.”**
35. **Discard** after edits MUST **confirm** before losing changes (`design.md` §15).
36. Confidence MUST be **honest** (e.g. Medium/Low with explanatory subcopy); MUST NOT hide uncertainty.

**History and Meal Detail**

37. History MUST use **3-column (typical) square grid**, photo-forward, light metadata overlay (micro kcal + **L/M/H** spike marker + text—not color alone) (`design.md` §17 / `screens_updated.md` §13).
38. Tap tile → **Meal Detail**; **delete** SHOULD live in **Meal Detail** (destructive, confirmed)—avoid grid swipe-delete as primary pattern.
39. Meal Detail MUST match content/actions in references (**Done**, **Edit estimate**, **Delete meal** with confirmation).

**Settings**

40. Settings MUST use **grouped list** with sections: Account, Subscription, **Free mode** (when applicable), Preferences, Health context, Legal, **Developer (QA-only hidden in prod)** (`design.md` §18 / `screens_updated.md` §15).
41. **Delete account** copy MUST match explicit **local vs server** deletion expectation per references if server deletion is absent.

**AI insights**

42. Insight cards MUST use calm, specific tone; MAY appear on Home, Meal Estimate, Meal Detail; MUST follow good/bad examples in references (**no** “this meal is bad for your glucose”).

**Errors and edge cases**

43. Implement failure, low confidence, no-food-detected, and high spike-risk **educational** copy per **`screens_updated.md` §19** / **`design.md` §25**.
44. **Free limit exhausted** MUST follow **`screens_updated.md` §19** and paywall behavior in §22–23 above.

**App icon**

45. Icon direction MUST follow **`design.md` §26** / **`screens_updated.md` §23** (pastel leaf, no text, Icon Composer–ready variants).

**Analytics (design implication)**

46. Key funnel events SHOULD remain instrumentable as listed in **`screens_updated.md` §24** (onboarding, auth, paywall, meal capture/analysis/save, tab views); exact implementation is engineering-owned.

---

## 5. Non-Goals (Out of Scope)

Per **`screens_updated.md` §26** (and reinforced in `design.md` where applicable), **v1 redesign does NOT include**:

- Manual food database search  
- Barcode scanner  
- Voice logging (as primary)  
- Saved meals / restaurant guidance / grocery scan  
- Wearables, **CGM integration**, labs  
- Full **AI Coach** root tab (insights without dedicated tab are in scope)  
- Longevity scoring, full clinician export  

Design MAY reserve space for future inputs but MUST NOT ship these as primary flows in v1.

---

## 6. Design Considerations

- **Single implementation target:** **`apps/GluAI/design.md`** for product behavior, monetization, onboarding length, free tier, and **non-negotiable editing**. **`apps/GluAI/screens_updated.md`** for **screen-by-screen interaction**, analytics list, and granular UX notes—**already reconciled** to `design.md` for conflicts called out in this PRD.
- **High fidelity:** **`design.md` §27** — production-ready screens, not wireframes-only; include light/dark, large Dynamic Type, contrast/transparency samples, and **VoiceOver strings** for core flows.
- **Component library:** Build to **`design.md` §21** / **`screens_updated.md` §27** checklist (buttons including **camera hero** and library secondary, spike pills, macro chips, grid tile overlays, paywall components including **free mode** states).
- **Rename:** All “Result” UX surfaces → **Meal Estimate**.
- **Copy guardrails:** Enforce tables in **`design.md` §20** / **`screens_updated.md` §20**.

---

## 7. Technical Considerations

- **Stack:** SwiftUI iOS app; native Sign in with Apple; backend/auth/sync per existing app (e.g. **Supabase**—**do not** surface Supabase in consumer copy unless necessary).
- **Subscriptions:** **RevenueCat** for paywall UI (`PaywallView` or current recommended API) and **Glu Gold** entitlement—**verify 2026 SDK/docs** when implementing.
- **Photo pipeline:** Camera + photo picker; analysis latency handled with **Meal Estimate** loading UX (`design.md` §14 / `screens_updated.md` §18).
- **State:** Persist **free analyses remaining**, subscription state, and meal records consistently; gate **new** analysis when count is 0 and user is unsubscribed.
- **Accessibility hooks:** Test **Reduce Transparency**, **Reduce Motion**, **Increase Contrast**, **largest Dynamic Type** on pastel surfaces (`design.md` §7–8 / §23).

---

## 8. Success Metrics

**Primary (qualitative — per stakeholder direction 5D):**

- **Brand and UX review:** Stakeholders sign off that the app matches **Pastel Precision** and **Native iOS Premium + Pastel Journal** without diet-clinic or alarmist feel.
- **Accessibility pass:** Core flows usable with **VoiceOver** and **large Dynamic Type**; spike-risk never **color-only**.
- **App Store readiness:** Screenshots and metadata align with **educational-only** positioning; paywall and IAP behavior match review expectations.
- **No critical copy violations:** No diagnostic/prescriptive language; no “health zone”; paywall dismiss behavior is **transparent**.

**Supporting (optional quantitative — to be adopted if product adds goals later):** onboarding completion rate, paywall conversion, first meal saved, D7 retention—not required by this PRD revision.

---

## 9. Open Questions

1. **5 analyses scope:** Confirm whether the **5 free analyses** are **lifetime per account** vs **rolling window** vs **per install**—references assume a clear, honest cap; pick one and unify strings + analytics.
2. **“Maybe later” on limit screen:** Confirm whether users who exhausted free tier MAY dismiss paywall without subscribing (`design.md` §25 shows secondary **Maybe later** in one place)—define consistent behavior.
3. **Google Sign-In:** If not shipping, ensure **no** Google CTA in production (requirements already state conditional display).
4. **Server-side account deletion:** When available, update **Delete account** copy in Settings per `design.md` §18 / `screens_updated.md` §15.

---

## Document history

| Version | Date | Notes |
|--------|------|--------|
| 1.0 | 2026-05-01 | Initial PRD from `design.md` + aligned `screens_updated.md`; stakeholder choices 1B 2B 3A 4B 5D |

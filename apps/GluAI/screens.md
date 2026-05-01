# Glu AI — Screen & interaction brief for UI/UX design

**Audience:** Technical UI/UX designer delivering visual designs and interaction specs for engineering handoff.  
**Platform:** iOS (SwiftUI), native patterns first — aligned with Apple’s **Liquid Glass** navigation/control layer on current SDKs ([Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), [Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/liquid-glass)).  
**Product:** Glu AI — photo-based meal logging with AI-assisted calorie/macro estimates and **glycemic spike–risk context**. Positioning is **educational**, not medical advice.  
**Canonical design principles & tokens:** See repo `prd-glu-ai/design.md` (expanded below as a summary). **§Liquid Glass** below bridges PRD tokens with Apple’s platform materials.

---

## 1. Product snapshot

| Item | Detail |
|------|--------|
| **One-liner** | Snap or pick a meal photo; get rough calories, macros, and a spike-risk label; save history and build streaks. |
| **Primary users** | People managing diabetes or related glucose awareness (Type 1, Type 2, prediabetes, gestational, unsure). |
| **Monetization** | Subscription **“Glu Gold”** (RevenueCat); trial supported. Paywall after auth for non-subscribers. |
| **Account** | Sign in with Apple → Supabase session; optional mock/dev paths. |
| **Backend** | Supabase (auth, `meal_logs`, Edge Function `analyze-meal`). |

---

## 2. User journey (high level)

```text
Onboarding (JSON-driven steps)
    → Auth (Sign in with Apple)
    → Paywall (Glu Gold — RevenueCat-hosted UI when configured)
    → Main app (Tab bar: Home | Log | History | Settings)
```

**Staff-only (developer role):** Floating **dev** chip opens a sheet to jump funnel phases / tabs for QA — design may ignore or treat as internal overlay.

---

## 3. Design system summary (implement `prd-glu-ai/design.md`)

### Principles

1. Native iOS, calm health companion — not playful or alarming.  
2. **One primary action** per onboarding step and on Log tab.  
3. **Photos first** — thumbnails on Home; **History** as a **profile-style photo grid** (see §F); meal imagery prominent on result flows.  
4. **Camera is visually dominant** — wherever capture appears (Log tab today; any future shortcut), the **camera** control must read as **sharply distinct** from adjacent actions (Library, secondary buttons): stronger fill/contrast, larger touch target or weight, optional icon emphasis — never symmetric “equal” pairing with library (see §E).  
5. Spike-risk uses **semantic color sparingly**; pair with explanatory rationale, not fear copy.  
6. Light haptics on success paths only (design note for motion specs).

### Color (light / dark)

| Role | Light hex | Notes |
|------|-----------|--------|
| Brand primary | `#0A7A6A` | CTAs, key numerals, tint |
| Brand muted | `#E6F5F3` | Selected rows, washes |
| Spike low | `#30D158` | “Low” risk |
| Spike medium | `#FF9F0A` | “Medium” |
| Spike high | `#FF453A` | “High” — attention, not panic |

Use **system** background/surface/label for neutrals in implementation; designer should specify dark-mode equivalents aligned with PRD.

### Typography (SF Pro)

| Token | Size / weight | Usage |
|-------|----------------|--------|
| Display | 48 Bold | Hero stats (kcal, plan tier name) |
| Title | 28 Bold | Screen titles |
| Title 2 | 22 Semibold | Sections (“Today”, “Recent”) |
| Headline | 17 Semibold | List titles |
| Body | 17 Regular | Rationale, paragraphs |
| Subhead | 15 Regular | Supporting copy |
| Footnote | 13 | Disclaimers, errors |
| Caption | 11 | Meta, timestamps |

### Layout rhythm

- Screen horizontal padding: **24pt**  
- Card corner radius: **16pt**; primary button radius: **14pt**  
- Chip / option rows: **16pt** internal padding; selected state = muted fill + subtle brand stroke  

### Navigation

- **Tab bar:** Home (`house`), Log (`camera.viewfinder`), History (`clock`), Settings (`gearshape`). The **Log** tab should read as the **capture anchor** (stronger emphasis than other tabs — icon weight, tint, or treatment per Apple patterns). **Inside Log**, **Camera** must stay **visually dominant** vs Library — see §E. On current Apple SDKs, tab bars participate in the **Liquid Glass** navigation layer — detail in **§Liquid Glass** below.  
- Root tabs: prefer **large titles** where it fits brand; pushes/sheets: **inline** title.

### Accessibility

- Dynamic Type–friendly; spike-risk must include **text** (“Low / Medium / High”), not color alone.  
- Minimum tap targets **44×44 pt**.  
- VoiceOver: e.g. “Spike risk: medium. Educational estimate only.”

---

## Liquid Glass & Apple platform alignment

This section translates Apple’s guidance into **actionable design asks** for Glu AI. Primary sources: [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), [Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/liquid-glass), [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views), and related HIG/material docs linked from those pages.

### What Liquid Glass is

- Apple describes **Liquid Glass** as a dynamic **material** that combines optical glass-like qualities with **fluid motion** — used as a distinct **functional layer** for **controls and navigation**, adapting to context (overlap, focus, environment) so **underlying app content stays the hero**.
- Standard SwiftUI/UIKit/AppKit components (**navigation stacks, tab bars, toolbars, sheets, popovers, many controls**) pick up this material **automatically** when the app is built with the **latest Xcode SDKs** and run on current platform releases.

### Strategic principle for Glu AI (navigation vs content)

| Layer | Role | Liquid Glass |
|-------|------|----------------|
| **Chrome** | Tab bar, nav bars, toolbars, sheets, menus, floating secondary actions | Embrace **system** Liquid Glass; minimize custom backgrounds that fight the material |
| **Content** | Meal photos, macro grids, onboarding body copy, rationales, disclaimers | Keep **readable, calm surfaces** (solid/grouped materials); **do not** blanket content cards in glass for decoration |

Apple stresses a **clear hierarchy**: navigation floats above content; overcrowding or **layering glass on glass** degrades clarity — especially risky for a **health-literacy** product.

### Visual refresh — designer/engineering asks

1. **Prefer standard navigation & surfaces** (`NavigationStack`, `TabView`, system toolbars, grouped lists/forms) so tab bars and sheets inherit Liquid Glass without bespoke blur stacks.
2. **Audit custom appearances** on bars and tabs: remove opaque custom fills/overlays where they **compete** with system glass or **scroll-edge** treatments.
3. **Sheets & modals** (meal result, History detail, RevenueCat paywall container, alerts): Apple notes sheets adopt Liquid Glass, **rounder corners**, and half-sheets **inset** so content **peeks through** — comps should show safe padding from curved edges and acceptable “peek” outside the sheet.
4. **Lists / Settings**: Expect **roomier row metrics** and rounded sections when using grouped styles; use **Title Case** section headers to match system convention (avoid ALL CAPS headers).

### Navigation — Glu-specific

- **Four-tab shell** aligns with Apple’s pattern of tabs sitting in the **topmost Liquid Glass layer**. Explore **emphasis on Log** via iconography and placement — not by adding a second glass-heavy bar. Reinforce **capture** there and on the Log screen via **Camera-first hierarchy** (§E).
- **Optional behaviors** to specify in mocks/prototypes (when targeting latest SDKs): tab bar **minimize-on-scroll** (`tabBarMinimizeBehavior`) for Home/History long feeds; **sidebar-adaptable** tab style on iPad for parity with system apps.
- **Scroll edge legibility**: Where stats or sticky headers float over scrolling meal content, specify whether engineering should rely on **system scroll-edge obscuring** (`scrollEdgeEffectStyle`, `safeAreaBar`) rather than custom gradients — preserves consistency with Liquid Glass toolbars.

### Controls & buttons

- System **buttons** gain glass-related styles (e.g. SwiftUI **`glass`** / **`glassProminent`** button styles); Apple recommends adopting these instead of **hand-rolled** glass on buttons.
- **Glu brand teal** primary CTAs (onboarding, Save meal) may remain **filled/prominent** for trust and WCAG-ish clarity if designers judge glass-prominent insufficient on busy imagery — but **avoid duplicating** both heavy brand fill **and** glass on the same cluster.
- **Be judicious with tint** on controls: tint should encode **meaning** (primary path, danger), not decoration ([color HIG](https://developer.apple.com/design/human-interface-guidelines/color)); reserve strong teal for primary actions and spike semantics already defined in §3.
- **Camera capture cluster:** Pair **Camera + Library** so Camera is unmistakably primary (filled / prominent / larger); Library stays secondary — never two equal-weight chrome buttons (detail §E).

### Custom UI (onboarding chips, stat cards, spike pills)

Apple warns: **avoid overusing** Liquid Glass on custom controls; it **distracts from content**.

- **Default**: onboarding option rows, macro cards, and spike pills remain **opaque / grouped / subtle blur-off** materials unless a specific component needs to read as **floating chrome** (e.g. a single floating **Analyze** or **Log** accessory).
- If glass is justified on a **custom** element, reference [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views): use **`glassEffect(_:in:)`**, prefer **`GlassEffectContainer`** when multiple glass shapes sit nearby (performance + **morphing** between states), and consider **`glassEffectID`** / **`glassEffectTransition`** for coordinated appear/disappear animations — **never** stack unrelated glass textures behind dense numeric medical-adjacent text without contrast QA.

### Motion & morphing

- Apple highlights **fluid morphing** (e.g. toolbar controls, menus). For Glu, flag opportunities: Log tab **camera → analyzing → result** transitions; sheet presentation of **Result**. Designers may specify **matched** motion IDs only where engineering adopts `GlassEffectContainer`; otherwise prefer **simple** sheet transitions to reduce scope.

### Accessibility & user preferences

Liquid Glass leans on translucency and motion; Apple notes users may enable **Reduce Transparency**, **Reduce Motion**, or adjust Liquid Glass appearance (**Clear / Tinted** where available). Designs must remain legible when effects simplify to **solid** backgrounds.

**Designer QA matrix**

- Reduce Transparency ON — spike labels and disclaimers still readable  
- Increase Contrast — brand teal + spike colors still distinguishable  
- Dynamic Type largest sizes — glass chrome doesn’t clip titles  

### App icon

Apple expects **layered**, simplified icons with **filled overlapping shapes**; effects applied by the system. Deliver **layered artwork** suitable for **Icon Composer** ([creating icons with Icon Composer](https://developer.apple.com/documentation/Xcode/creating-your-app-icon-using-icon-composer)); preview on updated grids from [Apple Design Resources](https://developer.apple.com/design/resources/).

### Screen-by-screen Liquid Glass notes

| Area | Direction |
|------|-----------|
| **Onboarding** | Full-bleed content area with standard nav absent — primary CTA can use system prominent/filled style; avoid glass behind long questionnaire lists |
| **Auth** | Sign in with Apple is system chrome — design around default; secondary links remain minimal |
| **Paywall** | RevenueCat UI inherits platform sheet/chrome — mock safe areas + corner radii; don’t overlay fake glass panels |
| **Home / History** | **Home:** content-forward scroll; **History:** dense **square photo grid** (profile-style); thumbnails opaque; overlays legible at small sizes |
| **Log** | Toolbar/title standard; **Camera vs Library asymmetric** (§E); Camera sheet full-screen; **Result** sheet matches system Liquid Glass sheet spec |
| **Settings** | Grouped list — embrace larger rows/rounded sections |
| **Dev overlay** | QA-only; if styled, single small floating control — optional `glassEffect` or system-equivalent; not shipped to consumers |

### Compatibility note (engineering handoff)

Teams shipping against older appearances may use **`UIDesignRequiresCompatibility`** while adopting new SDKs; design brief assumes **forward-looking** comps match Liquid Glass-era system chrome unless product explicitly scopes compatibility mode ([Information Property List reference](https://developer.apple.com/documentation/BundleResources/information-property-list)).

---

## 4. Screen inventory & specs

### A. Onboarding flow (`OnboardingView`)

**Behavior**

- Sequential steps with **persisted index** (resume if app killed).  
- Primary CTA is **full-width** bottom button (`PrimaryButtonStyle`: brand fill, white text). Disabled until valid selection on choice steps.  
- **Single-choice:** one option selected; rows show checkmark when selected.  
- **Multi-choice:** at least one option required to continue.  
- **Calculating:** ~4.5s delay with spinner + status lines (no CTA until auto-advance).  
- **Plan reveal:** dynamic **tier label** + three bullets + subtitle; CTA completes onboarding.

**Welcome extra UI**

- Row: ★ “Built for people managing diabetes” (yellow star + subhead).

**Notification priming**

- Title / subtitle from JSON; fake notification preview card (“Glu AI” / “Alex, quick lunch log? 📸”); secondary **“Maybe later”** (currently non-functional stub — design should specify placement; product may wire skip).

**Dynamic plan reveal content**

- **Tier string** (large brand-colored display):  
  - **“Max awareness”** if strictness contains “More direct” / “direct”.  
  - **“Careful”** if diabetes type = Type 1.  
  - Else **“Balanced”**.  
- **Bullets** (always three):  
  1. First bullet interpolates multi-selected **food_focus** (comma-separated) or fallback “your focus areas”.  
  2. “In every estimate, glance at fiber and added sugar — not just carbs.”  
  3. “Bring questions to your clinician; Glu AI is educational, not a prescription.”  
- Footer: step subtitle — **“Educational only — not medical advice.”**  
- CTA: **“Save my plan”**

**Per-step copy (source: `Resources/onboarding_steps.json`)**

| # | Step ID | Kind | Title | Subtitle | Options | CTA |
|---|---------|------|-------|----------|---------|-----|
| 1 | welcome | welcome | Glu AI | Photo meals. Smarter carb context — educational only. | — | Get Started |
| 2 | dm_type | single | What best describes you? | — | Type 1, Type 2, Prediabetes, Gestational, Not sure / still learning | Continue |
| 3 | carb_think | single | When you eat, how often do you think about carbs? | — | Rarely, Sometimes, Most meals, Always | Continue |
| 4 | tried_log | single | Have you tried logging meals or diabetes apps before? | — | Yes, No | Continue |
| 5 | barriers | multi | What usually gets in the way? | Select all that apply. | Too time-consuming; Hard to guess carbs; Forget to log; Apps feel clinical; Don't trust estimates; Not sure what to aim for | Continue |
| 6 | promise | info | Most members build a steadier logging habit in 3 weeks | Self-reported consistency — not a medical outcome claim. | — | Continue |
| 7 | goals | multi | What are you hoping Glu AI helps with? | — | Fewer sharp swings…; Better carb awareness; Lighter logging workload; Weight trend support; Notes for my care team | Continue |
| 8 | carb_comfort | single | Do you already have a daily carb target from your clinician? | — | Yes, I have a number; I'm figuring it out; Prefer not to use a number now | Continue |
| 9 | eat_pattern | single | Which sounds most like you? | — | 3 meals; Grazer / small meals; Intermittent fasting; Irregular schedule | Continue |
| 10 | strictness | single | How direct should tips feel? | — | Gentle nudges; Balanced; More direct (still not medical commands) | Continue |
| 11 | food_focus | multi | Where do you want extra awareness? | — | Restaurant meals; Takeout; Home cooking; Packaged snacks; Sweets / desserts; Drinks | Continue |
| 12 | comorbid | multi | Anything else you're comfortable sharing? (Optional) | Select any — or choose “None of these”. | None of these; High blood pressure; Kidney-related guidance…; Celiac / gluten-free; Vegetarian / vegan | Continue |
| 13 | social_proof | info | People use Glu AI to log faster and think clearer about meals | Replace with real quotes after launch — placeholder. | — | Continue |
| 14 | accountability | single | What helps you stay consistent? | — | Reminders; Streaks; Weekly recap; Just opening the app when I need it | Continue |
| 15 | aspirations | multi | In the next month, you'd love to… | — | Feel more in control…; Spend less time logging; See my patterns clearly; Bring better notes to appointments | Continue |
| 16 | notify_prime | notificationPriming | Stay consistent with gentle reminders | 1–2 nudges on days you choose — never spam. Change anytime in Settings. | — | Enable Reminders |
| 17 | attribution | single | How did you hear about us? | — | TikTok; Instagram; Friend / family; Google; App Store; Clinician / educator; Other | Continue |
| 18 | calculating | calculating | Creating your spike-smart plan… | — | — | *(auto-advance)* |
| 19 | reveal | planReveal | Your starting plan is ready | Educational only — not medical advice. | *(dynamic tier + bullets)* | Save my plan |

**Calculating subcopy (below spinner)**

- “Balancing your goals…  
  Pairing tips with your meal style…”

**Designer notes**

- Progress indicator (step X of Y or slim progress bar) is **not** in current build — recommended for design exploration.  
- Back / skip policies: product may add later; specify preferred patterns.

---

### B. Auth (`AuthView`)

**Purpose:** Create durable account; sync meals via Supabase.

| Element | Copy / behavior |
|---------|------------------|
| Title | Save your plan |
| Body | Sign in with Apple to sync meals across devices. Your session is secured with Supabase. |
| Primary | **Sign in with Apple** (system button, black style, ~56pt height, rounded ~14pt) |
| Secondary link | Continue with Google (wire SDK) — **stub**: tapping shows error string about wiring SDK |
| Tertiary | Use mock account (simulator) — generates local mock user (QA) |
| Error area | Footnote, red — dynamic server / Apple errors |

**States**

- Success → transitions out via parent (subscription routing).  
- Supabase missing → may still complete with Apple ID locally + inline warning.

---

### C. Paywall (`PaywallView`)

**Production:** RevenueCat **PaywallView** — layout, imagery, pricing copy, and packages come from **RevenueCat dashboard** (designer coordinates with PM for dashboard templates + optional marketing frames). Entitlement name: **Glu Gold**. Close button visible; closing triggers **sign-out** (Supabase + RevenueCat + local state) — intentional UX.

**Development fallback** (when API key missing)

| Element | Copy |
|---------|------|
| Title | RevenueCat API key missing |
| Body | Add REVENUECAT_API_KEY to AppSecrets.plist. entitlement: Glu Gold *(variable in prod)* |
| Primary | Unlock locally (QA) |
| Secondary | Restore purchases |
| Tertiary | Sign out |

**Overlay:** Purchase errors — top banner, footnote red on material background.

---

### D. Main tab — Home (`HomeView`)

**Structure**

- Navigation stack; scrollable content.

| Section | Content |
|---------|---------|
| Greeting | Time-based: “Good morning / afternoon / evening[, FirstName]” — FirstName from Apple/display name when available |
| Header | **Today** (title 2) |
| Stats row (card) | Left: **streak** — big number + “day logging streak”; Right: **meals today** — count + label |
| Recent | Title **Recent**; if empty: “Log your first meal from the Log tab.” Else up to 5 **meal row cards**: thumbnail 56×56, “{kcal} kcal · {time}”, 2-line rationale, **SpikeRiskPill** |

**Interaction**

- Rows are presently **non-navigation** (informational); tapping could deep-link to History detail in a future iteration — designer may propose.

---

### E. Main tab — Log (`CoreActionView`)

**Purpose:** Capture meal photo → analyze → optional save.

**Design requirement — camera sharply distinct**

- **Camera** is the **hero control** wherever it appears next to Library or other actions: it must read **immediately** as “take a photo now,” not as one of two peers.
- Deliver specs that enforce **clear hierarchy**: e.g. Camera = **brand-filled primary** (or system **`glassProminent`** + brand tint on Liquid Glass SDKs), **larger minimum height/tap area**, bolder **`camera.fill`** treatment; Library = **secondary only** (outline, subdued/neutral glass, or lighter fill).
- **Do not** spec symmetric dual bordered buttons for Camera/Library — widen the visual gap beyond today’s prominent-vs-bordered implementation if needed.
- **Motion/focus:** Optional subtle emphasis on Camera only (pulse on first launch, accessibility hint) — designer discretion; Library stays quiet.

| Element | Copy |
|---------|------|
| Title (nav) | Log |
| Heading | Log a meal |
| Subcopy | Pick or snap a photo. Glu AI returns rough calories, macros, and a spike-risk label — educational only. |
| Actions | **Camera** — primary / dominant; **Library** — secondary / subdued |
| Loading | ProgressView — “Analyzing…” |
| Errors | Footnote red — localized failure strings |

**Accessibility**

- VO order and labels: Camera first — e.g. “Take photo” / “Scan meal with camera”; Library — “Choose photo from library.”

**Sheets**

1. **Camera** — full-screen `UIImagePickerController` (camera).  
2. **Result** — after success (see §G).

**Future placements**

- Reuse this **same Camera primary treatment** if capture shortcuts appear on Home empty states, widgets, or elsewhere.

---

### F. Main tab — History (`HistoryView`)

**Visual metaphor:** Meal archive reads like an **Instagram-style profile grid** — uniform **square** cells (typically **3 columns** on phone; designer scales gutter/spacing for iPad), minimal gaps, **photo fills the tile**, so the tab feels like “my meals” not a spreadsheet.

**Per-tile overlay (small typography)**

- **Calories:** Tiny label on each tile — e.g. `{n} kcal` — caption or footnote scale (~11–12pt equivalent), **high contrast** on image (scrims, gradient hairline bottom bar, or blurred pill — designer specifies). Must remain readable on busy food photos.
- **Risk / “health zone” strip:** Discrete **traffic-light cue** aligned with spike-risk estimates (**not** medical CGM zones):  
  - **Green** → Low spike risk  
  - **Amber** → Medium  
  - **Red** → High  
  Implementation options: slim **corner notch**, **bottom-edge bar**, or **dot + abbreviation** (“L / M / H”) — **color must not be the only signal** (pair with letter or icon per accessibility §3).
- Footnote for screen or first-run hint: zones reflect **AI meal estimates — educational only.**

**Interaction**

- **Tap tile** → detail sheet (`MealResultDetailView`, §G): full rationale, macros, delete.
- **Delete / reorder:** Current build uses **list swipe-delete**; grid UX should specify **alternative** — long-press menu, edit mode, or trailing swipe on tile — designer delivers pattern + engineering follows.

| State | UI |
|-------|-----|
| Empty | System `ContentUnavailableView`: title “No meals yet”, subtitle “Saved meals from the Log tab appear here.” |
| Populated | **Square grid** of meal thumbnails; each tile shows **small kcal** + **green / amber / red** zone indicator |

**Detail:** Sheet — **Done** dismiss + **Delete meal** (§G).

**Designer deliverables**

- Light + dark comps; **Reduce Transparency** / **Increase Contrast** on overlays  
- Spec tile aspect ratio (1:1), corner radius (match brand or flush grid per Instagram), safe padding from screen edges  

---

### G. Meal result — preview sheet (`ResultSheet`) & detail (`MealResultDetailView`)

**Shared data model (`MealAIOutput`)**

| Field | UI usage |
|-------|-----------|
| Photo | Full-width rounded image when available |
| Calories | Large display number + “kcal” |
| Spike risk | Pill: Low / Medium / High (capitalized label + semantic color) |
| Macros | Carbs, Fiber, Sugar, Protein, Fat (grams); Result sheet also shows **Confidence** %{derived from 0–1} |
| Rationale | Body text |
| Disclaimer | Footnote secondary — default text includes educational / not medical advice |
| Items[] *(optional)* | Per-food line items — **not shown in current UI**; designer may propose breakdown sheet |

**Result sheet (post-capture)**

- Title: **Result**  
- Actions: **Save meal** (primary), **Discard** (cancel), toolbar **Close**

**History detail**

- Title: **Meal**  
- Same content grid + **Delete meal** destructive at bottom

---

### H. Main tab — Settings (`SettingsView`)

List grouped sections:

| Section | Contents |
|---------|-----------|
| Account | Optional error caption; User ID line; Staff role line if present (internal) |
| Subscription | Glu Gold: Active/Inactive; Trial active when applicable; **Restore purchases**; **Subscription & billing help** → RevenueCat **CustomerCenterView** |
| Developer | Reset onboarding (QA) — destructive flow sign-out |
| Actions | **Sign out**; **Delete account (5.1.1(v) flow)** → alert: title “Delete all data locally?” — explains server delete TODO |

---

### I. Developer overlay (`DevNavigatorOverlay`)

- Floating purple **dev** capsule; sheet **Developer routes** with funnel jumps and tab shortcuts.  
- **Design:** Low priority; internal QA only.

---

## 5. Components to specify in design system file

- Primary / secondary / ghost buttons (+ map to **system glass** button styles where Apple recommends replacing custom chrome — see §Liquid Glass)  
- **Camera capture button** — distinct variant (hero vs Library secondary); states default/highlighted/disabled  
- Onboarding option row (default / selected / disabled) — **opaque/grouped**, not decorative glass stacks  
- **SpikeRiskPill** (three variants + dark mode + increased contrast); align **green / amber / red** with History grid zones  
- **History grid tile** — square thumbnail + overlay scrim + **micro kcal** + zone indicator (see §F); pressed state  
- Meal row card (**Home** recent strip — distinct from History grid)  
- Stat card (Home)  
- Empty states (History, optional Home)  
- Loading / analyzing state  
- Error banner / inline error  
- Fake notification preview (notification priming)  
- Sheet templates (result, camera chrome) — **inset half-sheet**, corner clearance, peek-through outside sheet  
- **Tab bar** states: resting vs minimized-on-scroll (optional spec)  
- **App icon** layers for Icon Composer  

---

## 6. Copy guardrails (legal / tone)

- Prefer **“educational only,” “not medical advice,” “talk to your clinician”** near estimates and onboarding promises.  
- Avoid guaranteed outcomes; **promise** step explicitly says “Self-reported consistency — not a medical outcome claim.”  
- Spike-risk is **estimate-based**, not a CGM reading.

---

## 7. Analytics events (for correlation with design experiments)

Examples logged in app: `meal_capture_started`, `meal_analysis_started`, `meal_analysis_completed`, `meal_saved`, `meal_analysis_failed`, `paywall_shown`, `paywall_dismissed`, `trial_started`, `rc_customer_info`, `home_viewed`. Designer does not implement — awareness for funnel KPIs.

---

## 8. Out of scope / roadmap (inform visual backlog)

From product README — not required for v1 screens but may influence IA:

- Restaurant guidance, fridge/grocery scan, personalized recommendations  
- Wearables (Health / Oura / Whoop), labs, longevity scoring  

---

## 9. Deliverables checklist for designer

- [ ] Figma (or tool) library matching tokens + components above  
- [ ] **Liquid Glass era chrome**: tab bar + navigation + sheets framed so **content** reads below floating navigation (see §Liquid Glass)  
- [ ] All onboarding steps (mobile frames), light + dark  
- [ ] Auth, Paywall (production frame + fallback dev frame), edge/error states  
- [ ] Four main tabs + spike-risk variants (+ optional **tab minimize on scroll** comp for Home/History); **Log tab: Camera sharply distinct from Library** (sizes/colors/spec sheet); **History: Instagram-style square grid** with overlay kcal + green/amber/red zone + delete/access pattern    
- [ ] Result sheet & meal detail + empty / loading / error (**sheet corner inset / peek-through**)  
- [ ] Settings + Customer Center entry  
- [ ] Interaction notes: transitions, sheets, tab emphasis on Log  
- [ ] Accessibility annotations (VO strings, Dynamic Type samples) + **Reduce Transparency / Increase Contrast** spot checks  
- [ ] **Layered app icon** asset direction for Icon Composer / Xcode  
- [ ] Spec export or developer handoff (spacing, colors, typography styles)

---

**Document version:** 1.3 — History specified as Instagram-style grid with micro kcal + green/amber/red risk zones (aligned to spike-risk estimates).

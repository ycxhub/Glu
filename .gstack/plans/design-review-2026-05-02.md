# GluAI Design Review — `dev` branch (2026-05-02)

Scope: SwiftUI files modified in PR #1 (`dev` → `main`, merged as commit `198e3e9`).
Method: source-code design review against `apps/GluAI/OneshotApp/Theme.swift` tokens and `apps/GluAI/design-doc.md` philosophy. Three parallel reviewer subagents covered different file groups.

## Summary

**51 findings** across 9 files: **9 P0**, **22 P1**, **20 P2**.

The system is largely on-rails — most files correctly use `AppTheme.Typography.*` and `AppTheme.*` color tokens, `PrimaryButtonStyle` / `LibrarySecondaryButtonStyle`, `SpikeRiskPill`. No gradient heroes, no decorative blob SVGs, no purple/violet-on-white slop, no 3-column-icons-in-circles fingerprint.

Real issues cluster into:

1. **App Store compliance** (P0): AuthView missing pre-sign-in privacy/terms link; PaywallView missing Restore Purchases on the live RevenueCat path.
2. **Hierarchy weakness** (P0): HomeView has two competing `display`-sized numbers above the fold (streak vs today's meal count); Today's-estimates card stacks two equal stat tiles + chip strip into one card; Settings Sign Out and Delete Account share a section with default chrome.
3. **Empty state design** (P0): HistoryView uses generic `ContentUnavailableView` with system clock icon — no warm voice, no primary action.
4. **Touch target / a11y** (P0): Onboarding option rows lack explicit 44pt min-tap; Onboarding "fake notification" preview is decorative slop with icon-as-decoration.
5. **Token sweep** (P1): scattered magic-number paddings (10, 14), corner radii (4, 12), and one stray `.font(.caption)`. Mechanical to fix; ~22 findings collapse in one batch.
6. **Polish** (P2): centered text walls on a list-style screen (CoreActionView Log), orphan caption labels, missing `.accessibilityHidden(true)` on decorative icons, hard-coded user copy strings.

## Top 3 fixes by impact

1. **AuthView pre-sign-in privacy/terms link** — App Store review risk. P0, ~10 lines.
2. **PaywallView Restore Purchases + Terms/Privacy footer** — Apple Sub guideline compliance. P0, ~20 lines.
3. **HomeView streak/today refactor** — kills the dual-anchor AI-slop pattern. P0, ~30 lines across two cards.

If you want one mechanical PR: the **token-cleanup sweep** resolves 22 findings (all P1 padding/radius/font violations) in pure search-and-replace.

## Open questions before implementing

- **Card padding token**: introduce `AppTheme.Layout.cardPadding = 20`, or migrate all cards to `screenPadding = 24`? (Affects HomeView, CoreActionView, MealLogging cards.)
- **History grid radius**: token `historyCellRadius = 4` or true edge-to-edge `Rectangle()`? (Affects HistoryView contact-sheet feel.)
- **Scope**: implement all 51, or P0+P1 only (31 findings)?

---

## CoreActionView.swift (18 findings: 0 P0, 9 P1, 9 P2)

### P1 CoreActionView.swift:521 — Hardcoded `cornerRadius: 12` on macro cell

**Criterion**: #4 Magic-number radius — should use a Layout token.

**Before**:
```swift
.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
```

**After**:
```swift
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
```

**Acceptance**: Open the meal-estimate sheet; the six macro cells (Carbs / Fiber / Sugar / Protein / Fat / Items) keep the same rounded look; radius now resolves through `AppTheme.Layout.buttonRadius` (14).

---

### P1 CoreActionView.swift:519 — `.padding(10)` magic number on macro cell

**Criterion**: #3 Magic-number spacing — `10` is not on the 4/8/12/16/20/24 scale.

**Before**:
```swift
.padding(10)
.background(macroKeyTint(k).opacity(k == "Items" ? 0.28 : 0.38))
```

**After**:
```swift
.padding(12)
.background(macroKeyTint(k).opacity(k == "Items" ? 0.28 : 0.38))
```

**Acceptance**: Macro cells in the estimate sheet have slightly more breathing room (12pt instead of 10), grid still fits two cells per row at standard widths.

---

### P1 CoreActionView.swift:398, 409 — Spike lesson card uses off-scale `spacing: 10` + `.padding(12)`

**Criterion**: #3 Magic-number spacing.

**Before**:
```swift
if let env = envelope {
    VStack(alignment: .leading, spacing: 10) {
        Text("Spike lesson").font(AppTheme.Typography.headline)
        SpikeRiskPill(risk: env.spike_lesson.risk_band)
        Text(env.spike_lesson.headline)
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.label)
        Text(env.spike_lesson.coaching)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.secondaryLabel)
    }
    .padding(12)
```

**After**:
```swift
if let env = envelope {
    VStack(alignment: .leading, spacing: 8) {
        Text("Spike lesson").font(AppTheme.Typography.headline)
        SpikeRiskPill(risk: env.spike_lesson.risk_band)
        Text(env.spike_lesson.headline)
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.label)
        Text(env.spike_lesson.coaching)
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.secondaryLabel)
    }
    .padding(16)
```

**Acceptance**: 8pt internal stack, 16pt outer padding. Headline/pill/coaching read as a tight group; no off-scale 10/12 mix.

---

### P1 CoreActionView.swift:433, 441 — No-food / low-confidence callouts use `.padding(12)` instead of token

**Criterion**: #3 Magic-number spacing consistency.

**Before**:
```swift
if showNoFoodHint {
    Text(GluMealAnalysisUserCopy.noFoodDetected)
        .font(AppTheme.Typography.footnote)
        .foregroundStyle(AppTheme.secondaryLabel)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.dashboardSurface, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
} else if draft.confidence < 0.55 {
    Text(GluMealAnalysisUserCopy.lowConfidenceEstimate)
        .font(AppTheme.Typography.footnote)
        .foregroundStyle(AppTheme.secondaryLabel)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.dashboardSurface, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
}
```

**After**: replace `.padding(12)` with `.padding(AppTheme.Layout.optionRowPadding)` in both branches.

**Acceptance**: Both callouts use `optionRowPadding` (16). Visually slightly more padded, matches the design system option-row token.

---

### P1 CoreActionView.swift:601 — `.padding(12)` on `MealLineEditCard`

**Criterion**: #3 Magic-number spacing.

**Before**:
```swift
.padding(12)
.frame(maxWidth: .infinity, alignment: .leading)
.background(AppTheme.surface)
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
```

**After**:
```swift
.padding(AppTheme.Layout.optionRowPadding)
.frame(maxWidth: .infinity, alignment: .leading)
.background(AppTheme.surface)
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
```

**Acceptance**: Each line-item card uses `optionRowPadding` (16). Cards feel slightly more generous; touch targets for inline buttons stay comfortable.

---

### P1 CoreActionView.swift:466 — "Discard" button drops out of design system

**Criterion**: #12 Reinventing — every other action button on this sheet uses `PrimaryButtonStyle` or `LibrarySecondaryButtonStyle`; this one renders as default tinted, looks alien.

**Before**:
```swift
Button("Discard", role: .cancel) {
    if isDirty {
        showDiscardConfirm = true
    } else {
        onDiscard()
    }
}
```

**After**:
```swift
Button("Discard", role: .cancel) {
    if isDirty {
        showDiscardConfirm = true
    } else {
        onDiscard()
    }
}
.buttonStyle(LibrarySecondaryButtonStyle())
```

**Acceptance**: Save (primary), Edit estimate (secondary), Discard (secondary) — all three buttons share width, height, radius, weight.

---

### P1 CoreActionView.swift:563 — Add-item button uses `.borderless` instead of `LibrarySecondaryButtonStyle`

**Criterion**: #12 Reinventing existing components.

**Before**:
```swift
Button {
    draft.items.append(MealLineItem(name: "Food item", portionGuess: "1 serving", calories: 0, carbsG: 0))
} label: {
    Label("Add item", systemImage: "plus.circle.fill")
}
.buttonStyle(.borderless)
```

**After**:
```swift
Button {
    draft.items.append(MealLineItem(name: "Food item", portionGuess: "1 serving", calories: 0, carbsG: 0))
} label: {
    Label("Add item", systemImage: "plus.circle.fill")
        .frame(maxWidth: .infinity)
}
.buttonStyle(LibrarySecondaryButtonStyle())
```

**Acceptance**: While editing line items, "Add item" renders as a full-width secondary button matching the rest of the sheet.

---

### P1 CoreActionView.swift:597 — Inline "Remove item" — implicit/insufficient tap target

**Criterion**: #5 Touch targets <44pt + #12 Reinventing.

**Before**:
```swift
Button("Remove item", role: .destructive, action: onRemove)
    .font(AppTheme.Typography.caption)
```

**After**:
```swift
Button("Remove item", role: .destructive, action: onRemove)
    .font(AppTheme.Typography.footnote)
    .frame(minHeight: AppTheme.Layout.minTap)
    .accessibilityLabel("Remove \(item.name.isEmpty ? "item" : item.name)")
```

**Acceptance**: VoiceOver announces the specific item being removed; tap target ≥44pt regardless of Dynamic Type. `.destructive` keeps the red rendering — no manual `AppTheme.error` needed.

---

### P1 CoreActionView.swift:178 — Toolbar "Close" missing accessibility hint

**Criterion**: #11 Missing `.accessibilityLabel` / hint.

**Before**:
```swift
ToolbarItem(placement: .cancellationAction) {
    Button("Close") { estimateSession = nil }
}
```

**After**:
```swift
ToolbarItem(placement: .cancellationAction) {
    Button("Close") { estimateSession = nil }
        .accessibilityHint("Dismisses the estimate without saving")
}
```

**Acceptance**: VoiceOver on estimate sheet announces "Close, button. Dismisses the estimate without saving." No visual change.

---

### P2 CoreActionView.swift:43 — Title/subtitle centered on a left-rail list-style screen

**Criterion**: #7 AI slop — centered text walls on a content screen. iOS first-party apps left-align body.

**Before**:
```swift
VStack(spacing: 24) {
    Text("Log a meal")
        .font(AppTheme.Typography.title)
    Text("Pick or snap a photo. Glu AI returns a spike-risk estimate and nutrition guesses — educational only, not medical advice.")
        .font(AppTheme.Typography.subhead)
        .foregroundStyle(AppTheme.secondaryLabel)
        .multilineTextAlignment(.center)
```

**After**:
```swift
VStack(alignment: .leading, spacing: 20) {
    Text("Log a meal")
        .font(AppTheme.Typography.title)
    Text("Pick or snap a photo. Glu AI returns a spike-risk estimate and nutrition guesses — educational only, not medical advice.")
        .font(AppTheme.Typography.subhead)
        .foregroundStyle(AppTheme.secondaryLabel)
        .frame(maxWidth: .infinity, alignment: .leading)
```

(Switch sibling captions to leading too; keep the busy/analyzing transient state centered.)

**Acceptance**: Log screen reads like a settings/list screen (left-aligned). Hero buttons keep `.frame(maxWidth: .infinity)` so they remain full-width.

---

### P2 CoreActionView.swift:43 — VStack `spacing: 24` between unrelated groups too generous

**Criterion**: #3 spacing rhythm.

**Before**: single `VStack(spacing: 24)` with title + subhead + freeline + canAnalyze + buttons all 24pt apart.

**After**: nest the title+subhead pair in an inner VStack with `spacing: 8`; outer remains `spacing: 20`.

**Acceptance**: Title/subhead read as one block (8pt gap); everything else 20pt. Hierarchy: who-am-I (title) → meta (free line / gating) → action → status.

---

### P2 CoreActionView.swift:425 — Confidence percentage is a stranded one-liner

**Criterion**: #8 hierarchy weakness.

**Before**:
```swift
Text(String(format: "Confidence: %.0f%%", draft.confidence * 100))
    .font(AppTheme.Typography.caption)
    .foregroundStyle(AppTheme.secondaryLabel)
```

**After** (move it adjacent to the kcal hero so it documents the kcal estimate; delete the standalone Text at line 425):
```swift
HStack(alignment: .firstTextBaseline) {
    Text("\(draft.calories) kcal")
        .font(AppTheme.Typography.display)
        .foregroundStyle(AppTheme.brand)
    Text(String(format: "%.0f%% conf", draft.confidence * 100))
        .font(AppTheme.Typography.caption)
        .foregroundStyle(AppTheme.secondaryLabel)
        .accessibilityLabel(String(format: "Confidence %.0f percent", draft.confidence * 100))
    Spacer()
    SpikeRiskPill(risk: draft.spikeRisk)
}
.accessibilityElement(children: .combine)
```

**Acceptance**: Hero row reads "{kcal} • {conf}% — pill" as a single anchor. Removing the orphan caption tightens vertical rhythm by ~28pt.

---

### P2 CoreActionView.swift:447 — Rationale + disclaimer are bare floating `Text`

**Criterion**: #8 hierarchy weakness.

**Before**:
```swift
Text(draft.rationale)
    .font(AppTheme.Typography.body)
Text(draft.disclaimer)
    .font(AppTheme.Typography.footnote)
    .foregroundStyle(AppTheme.secondaryLabel)
```

**After**:
```swift
VStack(alignment: .leading, spacing: 8) {
    Text(draft.rationale)
        .font(AppTheme.Typography.body)
    Text(draft.disclaimer)
        .font(AppTheme.Typography.footnote)
        .foregroundStyle(AppTheme.secondaryLabel)
}
.frame(maxWidth: .infinity, alignment: .leading)
```

**Acceptance**: Rationale + disclaimer read as one block (8pt gap, leading-aligned, full width).

---

### P2 CoreActionView.swift:73, 81 — Hero buttons cause VoiceOver double-read

**Criterion**: #11 Missing `.accessibilityLabel` / decoupling.

**Before**:
```swift
Button { beginCaptureCamera() } label: {
    Label("Camera", systemImage: "camera.fill")
        .frame(maxWidth: .infinity)
}
.buttonStyle(CameraHeroButtonStyle())
.disabled(!canAnalyze || busy)
.accessibilityLabel("Camera")
.accessibilityHint("Take a new meal photo")
```

**After**: add `.accessibilityHidden(true)` on the inner `Label`. Same treatment for the PhotosPicker label at line 80–82.

**Acceptance**: VoiceOver announces "Camera, button. Take a new meal photo." once instead of twice.

---

### P2 CoreActionView.swift:494 — Macro grid gutters inconsistent

**Criterion**: #3 spacing rhythm.

**Before**:
```swift
private var macroGrid: some View {
    Grid(horizontalSpacing: 16, verticalSpacing: 8) {
```

**After**:
```swift
private var macroGrid: some View {
    Grid(horizontalSpacing: 12, verticalSpacing: 12) {
```

**Acceptance**: Equal gutters (12pt). Defer if the user prefers wider current gutters.

---

### P2 CoreActionView.swift:511 — `spacing: 2` inside macro cell off-scale

**Before**:
```swift
private func macroCell(_ k: String, _ v: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
```

**After**:
```swift
private func macroCell(_ k: String, _ v: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
```

**Acceptance**: Caption-to-value gap is 4pt (still tight, on-scale).

---

### P2 CoreActionView.swift:520 — Magic opacity `0.28 / 0.38`

**Criterion**: #1 (opacity scalars on a token).

**After**: extract to a private helper `macroTileOpacity(for:)` so values move out of the layout block. Defer until Theme adds proper tinted-surface tokens if user prefers.

---

### P2 CoreActionView.swift:584-599 — Edit-mode line item lacks visual hierarchy

Add a quiet caption header above the text fields ("New item" or current name) so each card has an anchor. Pair with the P1 fix above. Adds explicit `spacing: 12` on the kcal/carbs HStack.

---

## MealLogging.swift

No findings — pure model + Supabase data layer with no SwiftUI view chrome.

---

## OnboardingView.swift (8 findings: 2 P0, 4 P1, 2 P2)

### P0 OnboardingView.swift:204-224 — Notification priming "fake notification" is decorative slop

**Criterion**: AI slop pattern (decorative card with icon-as-decoration that masquerades as a system notification), card overuse, hierarchy weakness.

**Before**:
```swift
case .notificationPriming:
    RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(AppTheme.surface)
        .frame(height: 72)
        .overlay {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Glu AI")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryLabel)
                    Text("Quick lunch log?")
                        .font(AppTheme.Typography.subhead)
                }
                Spacer(minLength: 0)
                Image(systemName: "camera.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.brand.opacity(0.85))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
        }
```

**After**:
```swift
case .notificationPriming:
    VStack(alignment: .leading, spacing: 8) {
        Text("Sample reminder")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.secondaryLabel)
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("Glu AI")
                .font(AppTheme.Typography.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.secondaryLabel)
            Text("Quick lunch log?")
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.label)
        }
        .padding(AppTheme.Layout.optionRowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
    }
```

**Acceptance**: Preview reads as a labelled "sample" instead of a fake icon-circle notification; height is content-driven; corner radius uses `cardRadius`.

---

### P0 OnboardingView.swift:362-381 — Selectable `row` lacks explicit 44pt min-tap

**Criterion**: #5 Touch targets <44pt.

**Before**:
```swift
private func row(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.label)
                .multilineTextAlignment(.leading)
            Spacer()
            if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.brand) }
        }
        .padding(16)
        .background(selected ? AppTheme.brandMuted : AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(selected ? AppTheme.brand.opacity(0.35) : Color.clear, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
}
```

**After**:
```swift
private func row(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.label)
                .multilineTextAlignment(.leading)
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.brand)
                    .accessibilityHidden(true)
            }
        }
        .padding(AppTheme.Layout.optionRowPadding)
        .frame(minHeight: AppTheme.Layout.minTap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selected ? AppTheme.brandMuted : AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous)
                .stroke(selected ? AppTheme.brand.opacity(0.35) : Color.clear, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(selected ? .isSelected : [])
}
```

**Acceptance**: Every option row reports ≥44pt height in Accessibility Inspector; checkmark is hidden from VoiceOver and selected state is exposed via `.isSelected` trait.

---

### P1 OnboardingView.swift:55-61 — Hardcoded `padding(.horizontal, 24)` for progress header

**Before**:
```swift
ProgressView(value: Double(vm.index + 1), total: Double(vm.steps.count))
    .tint(AppTheme.brand)
    .padding(.horizontal, 24)
    .padding(.top, 8)
Text("Step \(vm.index + 1) of \(vm.steps.count)")
    .font(AppTheme.Typography.caption)
    .foregroundStyle(AppTheme.secondaryLabel)
    .padding(.horizontal, 24)
    .padding(.bottom, 4)
```

**After**: replace `.padding(.horizontal, 24)` with `.padding(.horizontal, AppTheme.Layout.screenPadding)` (both occurrences); change `.padding(.bottom, 4)` to `.padding(.bottom, 8)` for on-scale rhythm.

**Acceptance**: `grep -n "padding(.horizontal, 24)" OnboardingView.swift` returns no matches.

---

### P1 OnboardingView.swift:205, 374, 377 — Magic radius 12/14 instead of layout tokens

**Before / After**: replace literal `cornerRadius: 14` and `cornerRadius: 12` with `AppTheme.Layout.cardRadius` (notification preview card) or `AppTheme.Layout.buttonRadius` (option row + stroke).

**Acceptance**: All `cornerRadius:` literals in this file resolve to `AppTheme.Layout.cardRadius` or `AppTheme.Layout.buttonRadius`.

---

### P1 OnboardingView.swift:212 — Hardcoded `.font(.caption.weight(.semibold))`

**Before**:
```swift
Text("Glu AI")
    .font(.caption.weight(.semibold))
    .foregroundStyle(AppTheme.secondaryLabel)
```

**After**:
```swift
Text("Glu AI")
    .font(AppTheme.Typography.footnote.weight(.semibold))
    .foregroundStyle(AppTheme.secondaryLabel)
```

**Acceptance**: No `.font(.caption…)` literals remain in OnboardingView.swift.

---

### P1 OnboardingView.swift:284 — `.padding(24)` magic number

**Before**: `.padding(24)`
**After**: `.padding(AppTheme.Layout.screenPadding)`

---

### P2 OnboardingView.swift:233 — Decorative `scaleEffect(1.4)` on calculating spinner

**After**: replace `.scaleEffect(1.4)` with `.controlSize(.large)`; pair the spinner and text in an HStack with explicit `.accessibilityElement(children: .combine)` and a single combined label.

---

### P2 OnboardingView.swift:218-221 — Camera icon decorative inside notification preview

Folded into the P0 fix above — drop the icon entirely.

---

## AuthView.swift (4 findings: 2 P0, 1 P1, 1 P2)

### P0 AuthView.swift:18-24 — No visible privacy/terms link before sign-in

**Criterion**: Auth-specific rule 14 — privacy/terms link visible before sign-in. Apple's review guidelines + design-review rule 14 both require this.

**Before**:
```swift
Text("Save your plan")
    .font(AppTheme.Typography.title)
Text("Sign in with Apple to keep your personalized plan and meal history synced across devices.")
    .font(AppTheme.Typography.subhead)
    .foregroundStyle(AppTheme.secondaryLabel)
    .multilineTextAlignment(.center)
    .padding(.horizontal, 8)
```

**After**:
```swift
Text("Save your plan")
    .font(AppTheme.Typography.title)
Text("Sign in with Apple to keep your personalized plan and meal history synced across devices.")
    .font(AppTheme.Typography.subhead)
    .foregroundStyle(AppTheme.secondaryLabel)
    .multilineTextAlignment(.center)
    .padding(.horizontal, AppTheme.Layout.screenPadding)

HStack(spacing: 4) {
    Text("By continuing you agree to our")
        .foregroundStyle(AppTheme.secondaryLabel)
    Link("Terms", destination: AppLegalLinks.termsOfUse)
        .foregroundStyle(AppTheme.brand)
    Text("and")
        .foregroundStyle(AppTheme.secondaryLabel)
    Link("Privacy", destination: AppLegalLinks.privacyPolicy)
        .foregroundStyle(AppTheme.brand)
}
.font(AppTheme.Typography.footnote)
.multilineTextAlignment(.center)
.padding(.horizontal, AppTheme.Layout.screenPadding)
```

**Acceptance**: Both Terms and Privacy visible above or under the Sign in button before the user taps. Tapping each opens the canonical URL.

---

### P0 AuthView.swift:39-40 — Custom radius/frame fights `SignInWithAppleButton`

**Criterion**: Auth-specific rule 14 — use Apple's official button as-is. Wrapping with `.frame(height: 56)` + `.clipShape(RoundedRectangle(cornerRadius: 14))` fights the system button. Apple's HIG: don't restyle beyond the documented `cornerRadius` modifier.

**Before**:
```swift
.signInWithAppleButtonStyle(.black)
.frame(height: 56)
.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
.padding(.horizontal, 24)
```

**After**:
```swift
.signInWithAppleButtonStyle(.black)
.frame(height: AppTheme.Layout.minTap + 12)         // 56pt — meets Apple's HIG min
.cornerRadius(AppTheme.Layout.buttonRadius)         // 14pt, Apple's recommended path
.padding(.horizontal, AppTheme.Layout.screenPadding)
```

**Acceptance**: Button uses `cornerRadius(_:)` (Apple's documented styling hook) instead of `clipShape`, frame height resolves via the layout token.

---

### P1 AuthView.swift:24, 41, 63 — Three different gutters on the same screen

**Before**: subtitle uses `padding(.horizontal, 8)`, Apple button uses `padding(.horizontal, 24)`, outer container uses bare `.padding()` (system default ≈16).

**After**: all three resolve through `AppTheme.Layout.screenPadding`. Replace bare `.padding()` with explicit `.padding(.horizontal, AppTheme.Layout.screenPadding).padding(.vertical, AppTheme.Layout.screenPadding)`.

**Acceptance**: All elements share the same horizontal gutter; no `padding(.horizontal, 8)` or bare `.padding()` left.

---

### P2 AuthView.swift:16 — VStack `spacing: 24` should resolve through token

**Before**: `VStack(spacing: 24)`
**After**: `VStack(spacing: AppTheme.Layout.screenPadding)`

---

## HomeView.swift (9 findings: 2 P0, 4 P1, 3 P2)

### P0 HomeView.swift:36-58 — Streak/meals card has dual `display`-sized numbers competing

**Criterion**: Home-specific rule 15 — one primary visual anchor. Two `display`-sized numbers in the same HStack create a 50/50 split with no clear anchor.

**Before**:
```swift
HStack(alignment: .top) {
    VStack(alignment: .leading, spacing: 4) {
        Text("\(meals.streakDays)")
            .font(AppTheme.Typography.display)
            .foregroundStyle(AppTheme.brand)
        Text("day logging streak")
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.secondaryLabel)
    }
    Spacer()
    VStack(alignment: .trailing, spacing: 4) {
        Text("\(meals.todayMeals.count)")
            .font(AppTheme.Typography.display)
            .foregroundStyle(AppTheme.label)
        Text("meals today")
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.secondaryLabel)
    }
}
.padding(20)
.frame(maxWidth: .infinity, alignment: .leading)
.background(AppTheme.surface)
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
```

**After**:
```swift
VStack(alignment: .leading, spacing: 8) {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
        Text("\(meals.streakDays)")
            .font(AppTheme.Typography.display)
            .foregroundStyle(AppTheme.brand)
        Text("day streak")
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.label)
    }
    Text("\(meals.todayMeals.count) meals logged today")
        .font(AppTheme.Typography.subhead)
        .foregroundStyle(AppTheme.secondaryLabel)
}
.padding(AppTheme.Layout.screenPadding)
.frame(maxWidth: .infinity, alignment: .leading)
.background(AppTheme.surface)
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
.accessibilityElement(children: .combine)
.accessibilityLabel("\(meals.streakDays) day streak. \(meals.todayMeals.count) meals logged today.")
```

**Acceptance**: Streak number is the only `display`-sized element on Home above the fold; secondary count is `subhead`. One clear anchor.

---

### P0 HomeView.swift:60-75 — Today's-estimates card stacks two equal stat tiles + chip strip

**Criterion**: AI slop pattern (uniform stat tiles), card overuse.

**Before**:
```swift
if !meals.todayMeals.isEmpty {
    VStack(alignment: .leading, spacing: 12) {
        Text("Today's estimates")
            .font(AppTheme.Typography.title2)
        HStack {
            todayStatLabel("Est. kcal", "\(todayCalories)")
            Spacer()
            todayStatLabel("Est. carbs", String(format: "%.0f g", todayCarbs))
        }
        spikeDistributionRow
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppTheme.dashboardSurface)
    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
}
```

**After**:
```swift
if !meals.todayMeals.isEmpty {
    VStack(alignment: .leading, spacing: 12) {
        Text("Today's estimates")
            .font(AppTheme.Typography.headline)
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(todayCalories)")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.label)
                Text("kcal · \(String(format: "%.0f", todayCarbs)) g carbs")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
            }
            Spacer(minLength: 0)
        }
        spikeDistributionRow
    }
    .padding(AppTheme.Layout.screenPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppTheme.dashboardSurface)
    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
}
```

**Acceptance**: Card has one clear primary number (kcal in title), supporting text on a single line, chip row underneath. Dual-`title2` numbers no longer compete.

---

### P1 HomeView.swift:30, 55, 71, 174, 252 — Magic-number paddings (14, 20, 12)

**Before**:
- L30: `.padding(14)` (free analyses pill)
- L55: `.padding(20)` (streak card)
- L71: `.padding(20)` (today estimates)
- L174: `.padding(20)` (insight card)
- L252: `.padding(12)` (MealRowCard)

**After**: `.padding(AppTheme.Layout.optionRowPadding)` (16) for pill + MealRowCard; `.padding(AppTheme.Layout.screenPadding)` (24) for the three cards.

**Open question**: if 24 feels too generous for cards inside the 24pt screen gutter, introduce `AppTheme.Layout.cardPadding = 20` and use it instead.

**Acceptance**: `grep -n '\.padding(14)\|\.padding(20)\|\.padding(12)' HomeView.swift` returns 0 matches.

---

### P1 HomeView.swift:157-158 — Spike chip padding `10`/`6` off-scale

**Before**:
```swift
.padding(.horizontal, 10)
.padding(.vertical, 6)
```

**After**:
```swift
.padding(.horizontal, 12)
.padding(.vertical, 8)
```

---

### P1 HomeView.swift:135 — Magic spacing `6` for spike distribution row

**Before**:
```swift
return VStack(alignment: .leading, spacing: 6) {
```

**After**:
```swift
return VStack(alignment: .leading, spacing: 8) {
```

---

### P1 HomeView.swift:239 — `cornerRadius: 12` on thumbnail

**Before**:
```swift
.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
```

**After**:
```swift
.clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
.accessibilityHidden(true)
```

---

### P2 HomeView.swift:62 — Curly quote in source `'`

**Before**: `Text("Today's estimates")`
**After**: `Text("Today's estimates")` (ASCII straight quote keeps strings tooling sane until localization).

---

### P2 HomeView.swift:80 — `Text("Recent")` is `title2` — same weight as page title

**Before**:
```swift
Text("Recent")
    .font(AppTheme.Typography.title2)
```

**After**:
```swift
Text("Recent")
    .font(AppTheme.Typography.headline)
    .foregroundStyle(AppTheme.label)
    .padding(.top, 8)
```

**Acceptance**: Only `Today` is a true page title; everything else demoted.

---

### P2 HomeView.swift:176 — `colorScheme`-conditioned opacity (0.22 / 0.35) magic numbers

**Decision**: keep current expression; add `// TODO(theme): introduce AppTheme.insightSurface(for:colorScheme) so opacities are tokenized.` Defer behavior change.

---

## SettingsView.swift (4 findings: 2 P0, 1 P1, 1 P2)

### P0 SettingsView.swift:23 — `.font(.caption)` is raw, not a token

**Before**:
```swift
Text(e).font(.caption).foregroundStyle(AppTheme.error)
```

**After**:
```swift
Text(e)
    .font(AppTheme.Typography.footnote)
    .foregroundStyle(AppTheme.error)
    .accessibilityLabel("Account error: \(e)")
```

**Acceptance**: Error text uses a token font, one step larger so it reads as an alert; has accessibility label naming it as an error.

---

### P0 SettingsView.swift:92-103 — Sign Out and Delete Account share section, "5.1.1(v)" jargon leaks to user copy

**Criterion**: Settings-specific rule 13 + #10 hardcoded copy.

**Before**:
```swift
Section {
    Button("Sign out") {
        Task {
            await sub.logOut()
            await auth.signOutFromSupabase()
            appState.signOutUser()
        }
    }
    Button("Delete account (5.1.1(v) flow)", role: .destructive) {
        showDeleteConfirm = true
    }
}
```

**After**:
```swift
Section {
    Button("Sign out") {
        Task {
            await sub.logOut()
            await auth.signOutFromSupabase()
            appState.signOutUser()
        }
    }
}

Section {
    Button(role: .destructive) {
        showDeleteConfirm = true
    } label: {
        Text("Delete account")
            .foregroundStyle(AppTheme.error)
    }
} footer: {
    Text("Permanently removes your account and meal history. This cannot be undone.")
        .font(AppTheme.Typography.footnote)
        .foregroundStyle(AppTheme.secondaryLabel)
}
```

**Acceptance**: Sign Out in own neutral section. Delete Account alone in final destructive section with footer explaining consequence; "5.1.1(v)" jargon gone.

---

### P1 SettingsView.swift:36 — Subscription status row uses default font

**Before**:
```swift
Text("Glu Gold: \(appState.isPremium ? "Active" : "Inactive")")
```

**After**:
```swift
HStack {
    Text("Glu Gold")
        .font(AppTheme.Typography.body)
    Spacer()
    Text(appState.isPremium ? "Active" : "Inactive")
        .font(AppTheme.Typography.body.weight(.semibold))
        .foregroundStyle(appState.isPremium ? AppTheme.brand : AppTheme.secondaryLabel)
}
```

**Acceptance**: Clear label/value layout, both tokens, active state color-anchored to brand.

---

### P2 SettingsView.swift:72 — Curly apostrophe in literal disclaimer

**Before**:
```swift
Text("Glu AI provides educational estimates only — not medical advice. Always follow your care team's plan.")
    .font(AppTheme.Typography.footnote)
    .foregroundStyle(AppTheme.secondaryLabel)
```

**After**:
```swift
Text(GluLegalCopy.healthContextDisclaimer)
    .font(AppTheme.Typography.footnote)
    .foregroundStyle(AppTheme.secondaryLabel)
```

(Introduces a new `GluLegalCopy` constant — peer of `GluMealAnalysisUserCopy`.)

---

## HistoryView.swift (4 findings: 1 P0, 3 P1)

### P0 HistoryView.swift:19-23 — Empty state is generic `ContentUnavailableView`, not designed first-run

**Criterion**: History-specific rule 14 — empty state must be warm message + primary action.

**Before**:
```swift
if meals.meals.isEmpty {
    ContentUnavailableView(
        "No meals yet",
        systemImage: "clock",
        description: Text("Saved meals from the Log tab appear here.")
    )
}
```

**After**:
```swift
if meals.meals.isEmpty {
    VStack(spacing: 16) {
        Spacer()
        Text("Your meal story starts here")
            .font(AppTheme.Typography.title2)
            .foregroundStyle(AppTheme.label)
            .multilineTextAlignment(.center)
        Text("Snap your next meal and we'll keep a private, spike-smart history right here.")
            .font(AppTheme.Typography.body)
            .foregroundStyle(AppTheme.secondaryLabel)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppTheme.Layout.screenPadding)
        Button("Log your first meal") {
            appState.selectedMainTab = 1
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, AppTheme.Layout.screenPadding)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

**Acceptance**: Warm hero message in the product's voice, secondary copy explaining what History becomes, primary button jumps to Log tab. Requires `@Environment(AppState.self) private var appState` at top of view.

---

### P1 HistoryView.swift:147 — `VStack(spacing: 2)` off-scale

**Before**: `VStack(alignment: .leading, spacing: 2)`
**After**: `VStack(alignment: .leading, spacing: 4)`

---

### P1 HistoryView.swift:155-156 — Pill paddings 5/2 off-scale

**Before**:
```swift
.padding(.horizontal, 5)
.padding(.vertical, 2)
```

**After**:
```swift
.padding(.horizontal, 8)
.padding(.vertical, 4)
```

---

### P1 HistoryView.swift:165 — `cornerRadius: 4` magic number

**Before**:
```swift
.clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
```

**Open choice**:
- **Option A**: extend `AppTheme.Layout` with `historyCellRadius = 4` and use `AppTheme.Layout.historyCellRadius`.
- **Option B**: edge-to-edge contact-sheet feel — `.clipShape(Rectangle())`.

**Acceptance**: Grid-cell radius is either a named Layout token or a clean rectangle.

---

### P2 HistoryView.swift:127 — Photo placeholder icon missing `.accessibilityHidden(true)`

**Before**:
```swift
} else {
    Rectangle()
        .fill(AppTheme.brandMuted)
        .overlay { Image(systemName: "photo").foregroundStyle(AppTheme.brand) }
}
```

**After**: add `.accessibilityHidden(true)` to the inner Image.

---

## PaywallView.swift (4 findings: 2 P0, 1 P1, 2 P2)

### P0 PaywallView.swift:41-48 — "Try 5 meals first" reinvents a button with off-scale padding

**Criterion**: #12 Reinventing components, #3 magic-number `padding(.vertical, 14)`, #5 touch target.

**Before**:
```swift
Button("Try 5 meals first") {
    dismissIntoFreeTier(source: "try_free")
}
.font(AppTheme.Typography.subhead.weight(.medium))
.padding(.vertical, 14)
.padding(.horizontal, 24)
.frame(maxWidth: .infinity)
```

**After**:
```swift
Button("Try 5 meals first") {
    dismissIntoFreeTier(source: "try_free")
}
.buttonStyle(LibrarySecondaryButtonStyle())
.frame(minHeight: AppTheme.Layout.minTap)
.padding(.horizontal, AppTheme.Layout.screenPadding)
.padding(.top, 8)
```

**Acceptance**: Free-tier escape hatch uses existing `LibrarySecondaryButtonStyle`, guaranteed 44pt tap target, no off-scale padding.

---

### P0 PaywallView.swift:49-53 — Restore Purchases missing on live RevenueCat path; Terms/Privacy stack with no separation

**Criterion**: Paywall-specific rule 15 — Restore Purchases must be visible per Apple Sub guidelines. Live RevenueCat path on lines 25-54 has no Restore button at all; only the offline-dev fallback at line 127 has it.

**Before**:
```swift
Link("Terms of Use", destination: AppLegalLinks.termsOfUse)
    .font(AppTheme.Typography.caption)
Link("Privacy Policy", destination: AppLegalLinks.privacyPolicy)
    .font(AppTheme.Typography.caption)
Spacer().frame(height: 8)
```

**After**:
```swift
Button("Restore purchases") {
    Task {
        try? await sub.restorePurchases()
        if sub.isPremium { onUnlocked() }
    }
}
.font(AppTheme.Typography.subhead)
.foregroundStyle(AppTheme.brand)
.frame(minHeight: AppTheme.Layout.minTap)

HStack(spacing: 16) {
    Link("Terms of Use", destination: AppLegalLinks.termsOfUse)
    Text("·").foregroundStyle(AppTheme.secondaryLabel)
    Link("Privacy Policy", destination: AppLegalLinks.privacyPolicy)
}
.font(AppTheme.Typography.caption)
.foregroundStyle(AppTheme.secondaryLabel)
.padding(.bottom, 8)
```

**Acceptance**: Restore Purchases visible on live RevenueCat paywall; Terms/Privacy share single horizontal row separated by middle-dot; secondary footer no longer left-stacked.

---

### P1 PaywallView.swift:137 — Sign Out (offline-dev path) lacks destructive role/color

**Before**:
```swift
Button("Sign out") {
    Task {
        analytics.track("paywall_dismissed", properties: ["via": "sign_out"])
        await sub.logOut()
        await auth.signOutFromSupabase()
        appState.signOutUser()
    }
}
.font(AppTheme.Typography.footnote)
.foregroundStyle(AppTheme.secondaryLabel)
```

**After**:
```swift
Button(role: .destructive) {
    Task {
        analytics.track("paywall_dismissed", properties: ["via": "sign_out"])
        await sub.logOut()
        await auth.signOutFromSupabase()
        appState.signOutUser()
    }
} label: {
    Text("Sign out")
        .font(AppTheme.Typography.footnote)
}
.foregroundStyle(AppTheme.error)
.frame(minHeight: AppTheme.Layout.minTap)
```

---

### P2 PaywallView.swift:107 — Hero copy is happy-talk

**Before**:
```swift
Text("Your spike-smart plan is ready")
    .font(AppTheme.Typography.title)
Text("Start Glu Gold for unlimited meal analysis — or try 5 meals first.")
    .font(AppTheme.Typography.subhead)
    .foregroundStyle(AppTheme.secondaryLabel)
    .multilineTextAlignment(.center)
```

**After**:
```swift
Text("Unlimited spike-smart meal analysis")
    .font(AppTheme.Typography.title)
    .multilineTextAlignment(.center)
Text("Glu Gold removes the 5-meal cap. Cancel anytime in the App Store.")
    .font(AppTheme.Typography.subhead)
    .foregroundStyle(AppTheme.secondaryLabel)
    .multilineTextAlignment(.center)
```

**Acceptance**: Hero is a concrete value prop (what you get + cancel terms), not a status sentence.

---

### P2 PaywallView.swift:148 — `.padding(24)` should resolve through `screenPadding`

**Before**: `.padding(24)`
**After**: `.padding(AppTheme.Layout.screenPadding)`

---

## MainTabView.swift (2 findings: 1 P1, 1 P2)

### P1 MainTabView.swift:12-31 — Selected vs unselected tab differs in tint only; default secondary doesn't contrast on pale backgrounds

**Criterion**: MainTab-specific rule 16.

**Before**:
```swift
TabView(selection: ...) {
    HomeView(...)
        .tabItem { Label("Home", systemImage: "house") }
        .tag(0)
    CoreActionView(...)
        .tabItem { Label("Log", systemImage: "camera.viewfinder") }
        .tag(1)
    HistoryView(...)
        .tabItem { Label("History", systemImage: "clock") }
        .tag(2)
    SettingsView(...)
        .tabItem { Label("Settings", systemImage: "gearshape") }
        .tag(3)
}
.tint(AppTheme.brand)
```

**After**:
```swift
TabView(selection: ...) {
    HomeView(...)
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(0)
    CoreActionView(...)
        .tabItem { Label("Log", systemImage: "camera.viewfinder") }
        .tag(1)
    HistoryView(...)
        .tabItem { Label("History", systemImage: "clock.fill") }
        .tag(2)
    SettingsView(...)
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        .tag(3)
}
.tint(AppTheme.brand)
.onAppear {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.secondaryLabel)
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor(AppTheme.secondaryLabel)
    ]
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
    trackMainTab(appState.selectedMainTab)
    Task { await meals.loadRemoteMeals() }
}
```

**Acceptance**: Filled SF Symbols give selected state a fill change AND tint change; unselected color anchored to `AppTheme.secondaryLabel`. Selected vs unselected differ in both color and fill, not just weight. Keep `camera.viewfinder` as-is (no `.fill` variant).

---

### P2 MainTabView.swift:42-55 — `trackMainTab` uses magic-number indices

**Before**:
```swift
private func trackMainTab(_ tab: Int) {
    switch tab {
    case 0: analytics.track("home_viewed", properties: nil)
    case 1: analytics.track("log_viewed", properties: nil)
    case 2: analytics.track("history_viewed", properties: nil)
    case 3: analytics.track("settings_viewed", properties: nil)
    default: break
    }
}
```

**After**:
```swift
enum MainTab: Int, CaseIterable {
    case home = 0, log, history, settings

    var analyticsEvent: String {
        switch self {
        case .home: return "home_viewed"
        case .log: return "log_viewed"
        case .history: return "history_viewed"
        case .settings: return "settings_viewed"
        }
    }
}

private func trackMainTab(_ tab: Int) {
    guard let mainTab = MainTab(rawValue: tab) else { return }
    analytics.track(mainTab.analyticsEvent, properties: nil)
}
```

**Acceptance**: Single source of truth; analytics event names cannot drift from tab indices on a future reorder; `HistoryView` empty-state CTA can use `MainTab.log.rawValue` instead of literal `1`.

---

STATUS: PLAN READY — no code changed; awaiting user review.

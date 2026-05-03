import SwiftUI
import UserNotifications

enum GluOnboardingPlan {
    static let noneOfTheseLabel = "None of these"

    /// Tier labels: **Gentle** / **Balanced** / **Focused** only (`design.md` §10).
    static func tier(responses: [String: [String]]) -> String {
        let strict = responses["strictness"]?.first ?? ""
        if strict.localizedCaseInsensitiveContains("Gentle") {
            return "Gentle"
        }
        if strict.localizedCaseInsensitiveContains("More direct") || strict.localizedCaseInsensitiveContains("direct") {
            return "Focused"
        }
        let dm = responses["dm_type"]?.first ?? ""
        if dm == "Type 1" {
            return "Focused"
        }
        let carbThink = responses["carb_think"]?.first ?? ""
        if carbThink == "Always" || carbThink == "Most meals" {
            return "Focused"
        }
        return "Balanced"
    }

    static func bullets(responses: [String: [String]]) -> [String] {
        let tier = tier(responses: responses)
        let tricky: String
        if let arr = responses["food_focus"], !arr.isEmpty {
            tricky = arr.joined(separator: ", ")
        } else {
            tricky = "your focus areas"
        }
        return [
            "Your starting tone is \(tier) — photo-log one meal today you usually find tricky (you noted \(tricky)).",
            "In every estimate, glance at fiber and added sugar — not just total carbs.",
            "Bring questions to your clinician; Glu AI is educational, not a prescription.",
        ]
    }
}

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(NoopAnalytics.self) private var analytics
    @State private var vm = OnboardingViewModel()
    @State private var didTrackStarted = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if !vm.steps.isEmpty {
                    ProgressView(value: Double(vm.index + 1), total: Double(vm.steps.count))
                        .tint(AppTheme.brand)
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.top, 8)
                    Text("Step \(vm.index + 1) of \(vm.steps.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.secondaryLabel)
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.bottom, 8)
                }

                if let step = vm.current {
                    OnboardingStepContent(
                        step: step,
                        vm: vm,
                        onSelectSingle: { choice in
                            vm.record(single: choice, stepId: step.id)
                        },
                        onSelectMulti: { set in
                            vm.record(multi: set, stepId: step.id)
                        },
                        onPrimary: { handlePrimary(step) },
                        onPlanRevealSecondary: {
                            analytics.track("onboarding_plan_reveal_secondary", properties: [
                                "label": step.secondaryCta ?? "",
                            ])
                            handlePrimary(step)
                        },
                        onSkipNotifications: { advanceAfterNotificationsSkipped() },
                        onCalculatingComplete: { handleCalculating() }
                    )
                } else {
                    Text("No steps").foregroundStyle(AppTheme.secondaryLabel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.index > 0, vm.current?.kind != .calculating {
                        Button("Back") {
                            vm.goBack()
                        }
                        .accessibilityLabel("Back to previous question")
                    }
                }
            }
        }
        .tint(AppTheme.brand)
        .onChange(of: vm.index) { _, v in
            appState.saveOnboardingIndex(v)
        }
        .onAppear {
            if !didTrackStarted {
                didTrackStarted = true
                analytics.track("onboarding_started", properties: ["steps": "\(vm.steps.count)"])
            }
        }
    }

    private func handleCalculating() {
        vm.advance()
    }

    private func advanceAfterNotificationsSkipped() {
        if vm.current?.kind == .notificationPriming {
            vm.advance()
        }
    }

    private func handlePrimary(_ step: OnboardingStepDefinition) {
        if step.kind == .planReveal {
            analytics.track("onboarding_completed", properties: ["tier": GluOnboardingPlan.tier(responses: vm.responses)])
            appState.setOnboardingCompleted()
            return
        }
        if vm.isLast {
            analytics.track("onboarding_completed", properties: nil)
            appState.setOnboardingCompleted()
        } else {
            vm.advance()
        }
    }
}

private struct OnboardingStepContent: View {
    let step: OnboardingStepDefinition
    var vm: OnboardingViewModel
    var onSelectSingle: (String) -> Void
    var onSelectMulti: ([String]) -> Void
    var onPrimary: () -> Void
    var onPlanRevealSecondary: () -> Void
    var onSkipNotifications: () -> Void
    var onCalculatingComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var singleSelection: String?
    @State private var multi: Set<String> = []
    @State private var calculatingLineIndex = 0

    private let calculatingLines = [
        "Balancing your goals…",
        "Pairing tips with your meal style…",
        "Preparing your starting plan…",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 0)

            Text(step.title)
                .font(AppTheme.Typography.title)
                .foregroundStyle(AppTheme.label)
            if let sub = step.subtitle, !sub.isEmpty {
                Text(sub)
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
            }

            switch step.kind {
            case .welcome:
                Label("Built for people managing diabetes", systemImage: "leaf.fill")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .labelStyle(.titleAndIcon)
                    .symbolRenderingMode(.hierarchical)
                    .tint(AppTheme.brand)
            case .singleChoice:
                if let opts = step.options {
                    ForEach(opts, id: \.self) { o in
                        row(title: o, selected: singleSelection == o) {
                            singleSelection = o
                            onSelectSingle(o)
                        }
                    }
                }
            case .multiChoice:
                if let opts = step.options {
                    ForEach(opts, id: \.self) { o in
                        let exclusiveNone = o == GluOnboardingPlan.noneOfTheseLabel
                        let sel = multi.contains(o)
                        row(title: o, selected: sel) {
                            toggleMulti(
                                option: o,
                                exclusiveNoneOption: exclusiveNone
                            )
                            onSelectMulti(Array(multi))
                        }
                    }
                }
            case .info:
                EmptyView()
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
                Button("Maybe later") {
                    onSkipNotifications()
                }
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.brand)
                .frame(maxWidth: .infinity, alignment: .leading)
            case .calculating:
                ProgressView()
                    .controlSize(.large)
                    .tint(AppTheme.brand)
                Text(calculatingLines[calculatingLineIndex % calculatingLines.count])
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.leading)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: calculatingLineIndex)
            case .planReveal:
                Text(GluOnboardingPlan.tier(responses: vm.responses))
                    .font(AppTheme.Typography.display)
                    .foregroundStyle(AppTheme.brand)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(GluOnboardingPlan.bullets(responses: vm.responses).enumerated()), id: \.offset) { _, line in
                        Text("• " + line)
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.label)
                    }
                }
                Text(step.subtitle ?? "")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.secondaryLabel)
            }

            Spacer(minLength: 0)

            if step.kind == .calculating {
                EmptyView()
            } else if step.kind == .notificationPriming {
                Button(step.cta) {
                    requestNotificationPermissionThenContinue()
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button {
                    if step.kind == .multiChoice {
                        onSelectMulti(Array(multi))
                    }
                    onPrimary()
                } label: {
                    Text(step.cta)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canContinue)
                if step.kind == .planReveal, let sec = step.secondaryCta, !sec.isEmpty {
                    Button(sec) {
                        onPlanRevealSecondary()
                    }
                    .buttonStyle(LibrarySecondaryButtonStyle())
                }
            }
        }
        .padding(AppTheme.Layout.screenPadding)
        .onAppear {
            if let prev = vm.responses[step.id]?.first, step.kind == .singleChoice {
                singleSelection = prev
            }
            if let arr = vm.responses[step.id], step.kind == .multiChoice {
                multi = Set(arr)
            }
            calculatingLineIndex = 0
            #if DEBUG
            print("onboarding_screen:", step.id, vm.index)
            #endif
        }
        .task(id: "\(step.id)-\(vm.index)") {
            guard step.kind == .calculating else { return }
            let lineTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_800_000_000)
                    await MainActor.run { calculatingLineIndex += 1 }
                }
            }
            try? await Task.sleep(for: .seconds(4.5))
            lineTask.cancel()
            onCalculatingComplete()
        }
    }

    private var multiAllowsEmpty: Bool {
        step.allowEmptySelection == true
    }

    private var canContinue: Bool {
        switch step.kind {
        case .welcome, .info, .notificationPriming, .calculating, .planReveal:
            return true
        case .singleChoice:
            return singleSelection != nil
        case .multiChoice:
            if multiAllowsEmpty { return true }
            return !multi.isEmpty
        }
    }

    private func toggleMulti(option o: String, exclusiveNoneOption: Bool) {
        if exclusiveNoneOption {
            if multi.contains(o) {
                multi.remove(o)
            } else {
                multi = [GluOnboardingPlan.noneOfTheseLabel]
            }
            return
        }
        if multi.contains(GluOnboardingPlan.noneOfTheseLabel) {
            multi.remove(GluOnboardingPlan.noneOfTheseLabel)
        }
        if multi.contains(o) {
            multi.remove(o)
        } else {
            multi.insert(o)
        }
    }

    private func requestNotificationPermissionThenContinue() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                        DispatchQueue.main.async {
                            onPrimary()
                        }
                    }
                } else {
                    onPrimary()
                }
            }
        }
    }

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
}

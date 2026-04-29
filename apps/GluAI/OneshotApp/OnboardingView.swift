import SwiftUI

enum GluOnboardingPlan {
    /// Plan tier from `prd-glu-ai/onboarding.md` screen 19.
    static func tier(responses: [String: [String]]) -> String {
        let strict = responses["strictness"]?.first ?? ""
        if strict.contains("More direct") || strict.contains("direct") {
            return "Max awareness"
        }
        let dm = responses["dm_type"]?.first ?? ""
        if dm == "Type 1" {
            return "Careful"
        }
        return "Balanced"
    }

    static func bullets(responses: [String: [String]]) -> [String] {
        let tricky: String
        if let arr = responses["food_focus"], !arr.isEmpty {
            tricky = arr.joined(separator: ", ")
        } else {
            tricky = "your focus areas"
        }
        return [
            "Photo-log one meal today you usually find tricky — you picked \(tricky).",
            "In every estimate, glance at fiber and added sugar — not just carbs.",
            "Bring questions to your clinician; Glu AI is educational, not a prescription.",
        ]
    }
}

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = OnboardingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    onCalculatingComplete: { handleCalculating() }
                )
            } else {
                Text("No steps").foregroundStyle(AppTheme.secondaryLabel)
            }
        }
        .tint(AppTheme.brand)
        .onChange(of: vm.index) { _, v in
            appState.saveOnboardingIndex(v)
        }
    }

    private func handleCalculating() {
        vm.advance()
    }

    private func handlePrimary(_ step: OnboardingStepDefinition) {
        if step.kind == .planReveal {
            appState.setOnboardingCompleted()
            return
        }
        if vm.isLast {
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
    var onCalculatingComplete: () -> Void

    @State private var singleSelection: String?
    @State private var multi: Set<String> = []

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
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("Built for people managing diabetes")
                        .font(AppTheme.Typography.subhead)
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
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
                        let sel = multi.contains(o)
                        row(title: o, selected: sel) {
                            if sel { multi.remove(o) } else { multi.insert(o) }
                            onSelectMulti(Array(multi))
                        }
                    }
                }
            case .info:
                EmptyView()
            case .notificationPriming:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.surface)
                    .frame(height: 72)
                    .overlay(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Glu AI")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppTheme.secondaryLabel)
                            Text("Alex, quick lunch log? 📸")
                                .font(AppTheme.Typography.subhead)
                        }
                        .padding(.horizontal, 16)
                    }
                Button("Maybe later") {}
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .calculating:
                ProgressView()
                    .scaleEffect(1.4)
                    .tint(AppTheme.brand)
                Text("Balancing your goals…\nPairing tips with your meal style…")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
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
            } else {
                Button(step.cta) { onPrimary() }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canContinue)
            }
        }
        .padding(24)
        .onAppear {
            if let prev = vm.responses[step.id]?.first, step.kind == .singleChoice {
                singleSelection = prev
            }
            if let arr = vm.responses[step.id], step.kind == .multiChoice {
                multi = Set(arr)
            }
            #if DEBUG
            print("onboarding_screen:", step.id, vm.index)
            #endif
        }
        .task(id: "\(step.id)-\(vm.index)") {
            guard step.kind == .calculating else { return }
            try? await Task.sleep(for: .seconds(4.5))
            onCalculatingComplete()
        }
    }

    private var canContinue: Bool {
        switch step.kind {
        case .welcome, .info, .notificationPriming, .calculating, .planReveal:
            return true
        case .singleChoice:
            return singleSelection != nil
        case .multiChoice:
            return !multi.isEmpty
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
}

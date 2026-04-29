import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = OnboardingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let step = vm.current {
                OnboardingStepContent(
                    step: step,
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
                Text("One-shot template")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
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
            case .info, .notificationPriming:
                EmptyView()
            case .calculating:
                ProgressView()
                    .scaleEffect(1.4)
                Text("Theatrical pause — same pattern as long Cal AI–style flows.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
            case .planReveal:
                Text("1,800")
                    .font(AppTheme.Typography.display)
                    .foregroundStyle(AppTheme.brand)
                Text("kcal / day (example). Replace with PRD numbers.")
                    .font(AppTheme.Typography.subhead)
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
            guard step.kind == .calculating else { return }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                onCalculatingComplete()
            }
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
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.brand) }
            }
            .padding(16)
            .background(selected ? AppTheme.surface.opacity(0.9) : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

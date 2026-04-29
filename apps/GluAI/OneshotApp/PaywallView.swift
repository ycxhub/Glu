import SwiftUI

/// Hard paywall UI from `prd-glu-ai/paywall.md`. RevenueCat + Superwall: replace `LocalSubscriptionService` when API keys exist.
struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthController.self) private var auth
    @Bindable var sub: LocalSubscriptionService
    var onUnlocked: () -> Void
    var analytics: NoopAnalytics
    @State private var annualSelected = true
    @State private var trialOn = true
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var err: String?
    @State private var showClose = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.brandMuted)
                    .frame(height: 140)
                    .overlay {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.brand)
                    }

                Text("Understand meals in seconds")
                    .font(AppTheme.Typography.title)
                    .multilineTextAlignment(.center)
                Text("Photo logging with rough calories, macros, and a spike-risk label — educational only, not medical care.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("4.8 · early ratings")
                        .font(AppTheme.Typography.subhead)
                }
                Text("“Logging finally feels doable.”")
                    .font(AppTheme.Typography.footnote)
                    .italic()
                    .foregroundStyle(AppTheme.secondaryLabel)

                tierCard(
                    title: "Annual",
                    badge: "BEST VALUE",
                    price: "$59.99/year",
                    subtitleText: "~$0.16/day · save vs monthly",
                    selected: annualSelected
                ) { annualSelected = true }

                tierCard(
                    title: "Monthly",
                    badge: nil,
                    price: "$12.99/month",
                    subtitleText: nil,
                    selected: !annualSelected
                ) { annualSelected = false }

                Toggle("Start with 3-day free trial", isOn: $trialOn)
                    .tint(AppTheme.brand)
                    .padding(.vertical, 4)

                if let e = err {
                    Text(e).font(AppTheme.Typography.footnote).foregroundStyle(AppTheme.error)
                }

                Button {
                    Task {
                        isPurchasing = true
                        err = nil
                        do {
                            try await sub.purchaseSelectedPlan()
                            analytics.track(
                                "trial_started",
                                properties: ["annual": annualSelected ? "1" : "0", "trial": trialOn ? "1" : "0"]
                            )
                            onUnlocked()
                        } catch {
                            err = error.localizedDescription
                        }
                        isPurchasing = false
                    }
                } label: {
                    Text(trialOn ? "Start Free Trial" : "Subscribe Now")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isPurchasing)

                HStack {
                    Text("Cancel anytime in Settings")
                    Text("·")
                    Button("Restore purchases") {
                        isRestoring = true
                        Task {
                            do {
                                try await sub.restorePurchases()
                            } catch {
                                err = error.localizedDescription
                            }
                            isRestoring = false
                        }
                    }
                    .disabled(isRestoring)
                }
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.secondaryLabel)

                Text(
                    "Subscription auto-renews unless canceled 24h before trial ends. Manage in Apple ID settings. By subscribing you agree to the Terms and Privacy Policy. Glu AI provides educational information only and is not a medical device."
                )
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.secondaryLabel)
                .multilineTextAlignment(.center)

                if showClose {
                    Button("Not now — sign out") {
                        analytics.track("paywall_dismissed", properties: ["action": "sign_out"])
                        auth.signOut()
                        appState.signOutUser()
                    }
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.secondaryLabel)
                }
            }
            .padding(24)
        }
        .overlay(alignment: .topLeading) {
            if showClose {
                Button {
                    analytics.track("paywall_dismissed", properties: ["via": "x"])
                    auth.signOut()
                    appState.signOutUser()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            await MainActor.run { showClose = true }
        }
        .onAppear {
            analytics.track("paywall_shown", properties: ["placement": "onboarding"])
            Task { await sub.preparePaywall() }
        }
    }

    private func tierCard(
        title: String,
        badge: String?,
        price: String,
        subtitleText: String?,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.brand.opacity(0.2))
                        .clipShape(Capsule())
                }
                Text(title).font(AppTheme.Typography.headline)
                Text(price).font(AppTheme.Typography.subhead)
                if let subtitleText {
                    Text(subtitleText).font(AppTheme.Typography.caption).foregroundStyle(AppTheme.secondaryLabel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(selected ? AppTheme.brandMuted : AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? AppTheme.brand : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

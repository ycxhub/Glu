import RevenueCat
import RevenueCatUI
import SwiftUI

/// Paywall: **RevenueCat dashboard paywall** via `RevenueCatUI.PaywallView` when an API key is present; offline fallback for local development.
///
/// Configure a paywall and **Glu Gold** entitlement in the [RevenueCat dashboard](https://www.revenuecat.com/docs/tools/paywalls).
struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthController.self) private var auth
    @Bindable var sub: RevenueCatSubscriptionService
    var onUnlocked: () -> Void
    var analytics: NoopAnalytics

    @State private var err: String?
    @State private var isRestoring = false

    private var useRevenueCatUI: Bool {
        guard let k = APIConfig.revenueCatAPIKey, !k.isEmpty, k != "REPLACE_ME" else { return false }
        return true
    }

    var body: some View {
        Group {
            if useRevenueCatUI {
                RevenueCatUI.PaywallView(displayCloseButton: true)
                    .onPurchaseCompleted { customerInfo in
                        handleCustomerInfo(customerInfo, source: "purchase")
                    }
                    .onRestoreCompleted { customerInfo in
                        handleCustomerInfo(customerInfo, source: "restore")
                    }
                    .onPurchaseFailure { error in
                        err = error.localizedDescription
                    }
                    .onRequestedDismissal {
                        Task { await dismissPaywallSignedOut() }
                    }
            } else {
                offlineDevPaywall
            }
        }
        .overlay(alignment: .top) {
            if let e = err {
                Text(e)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.error)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .onAppear {
            analytics.track(
                "paywall_shown",
                properties: [
                    "placement": "onboarding",
                    "ui": useRevenueCatUI ? "revenuecat_ui" : "offline_dev",
                ]
            )
            Task { await sub.preparePaywall() }
        }
    }

    private func handleCustomerInfo(_ customerInfo: CustomerInfo, source: String) {
        err = nil
        sub.updateFromCustomerInfo(customerInfo)
        analytics.track(
            "rc_customer_info",
            properties: [
                "source": source,
                "glu_gold": sub.isPremium ? "1" : "0",
                "trial": sub.isInTrialPeriod ? "1" : "0",
            ]
        )
        if sub.isPremium {
            onUnlocked()
        }
    }

    /// Close on RC paywall — align with previous UX: leave funnel via sign-out.
    private func dismissPaywallSignedOut() async {
        analytics.track("paywall_dismissed", properties: ["via": "close"])
        await sub.logOut()
        await auth.signOutFromSupabase()
        appState.signOutUser()
    }

    /// Minimal fallback when `REVENUECAT_API_KEY` is missing (Simulator / CI).
    private var offlineDevPaywall: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("RevenueCat API key missing")
                    .font(AppTheme.Typography.title)
                Text("Add REVENUECAT_API_KEY to AppSecrets.plist. entitlement: \(APIConfig.revenueCatEntitlementId)")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)

                Button("Unlock locally (QA)") {
                    Task {
                        try? await sub.purchaseSelectedPlan(annualPreferred: true)
                        if sub.isPremium { onUnlocked() }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Restore purchases") {
                    isRestoring = true
                    Task {
                        try? await sub.restorePurchases()
                        if sub.isPremium { onUnlocked() }
                        isRestoring = false
                    }
                }
                .disabled(isRestoring)

                Button("Sign out") {
                    Task { await dismissPaywallSignedOut() }
                }
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.secondaryLabel)
            }
            .padding(24)
        }
    }
}

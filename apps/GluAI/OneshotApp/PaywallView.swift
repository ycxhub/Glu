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
    @State private var inFlight = false
    @State private var showNoRestoreAlert = false
    @State private var trackedResolved = false

    private var useRevenueCatUI: Bool {
        guard let k = APIConfig.revenueCatAPIKey, !k.isEmpty, k != "REPLACE_ME" else { return false }
        return true
    }

    var body: some View {
        Group {
            if useRevenueCatUI {
                VStack(spacing: 0) {
                    RevenueCatUI.PaywallView(displayCloseButton: true)
                        .onPurchaseCompleted { customerInfo in
                            handleCustomerInfo(customerInfo, source: "purchase")
                        }
                        .onRestoreCompleted { customerInfo in
                            handleCustomerInfo(customerInfo, source: "restore")
                        }
                        .onPurchaseFailure { error in
                            show(error)
                        }
                        .onRequestedDismissal {
                            dismissIntoFreeTier(source: "close")
                        }

                    Button("Try \(APIConfig.freeTierQuota) meals first") {
                        dismissIntoFreeTier(source: "try_free")
                    }
                    .buttonStyle(LibrarySecondaryButtonStyle())
                    .disabled(inFlight)
                    .frame(minHeight: AppTheme.Layout.minTap)
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                    .padding(.top, 8)

                    Button("Restore purchases") {
                        restore()
                    }
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.brand)
                    .frame(minHeight: AppTheme.Layout.minTap)
                    .disabled(inFlight)

                    HStack(spacing: 16) {
                        Link("Terms of Use", destination: AppLegalLinks.termsOfUse)
                        Text("·").foregroundStyle(AppTheme.secondaryLabel)
                        Link("Privacy Policy", destination: AppLegalLinks.privacyPolicy)
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .padding(.bottom, 8)
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
                    .background(AppTheme.cardElevated)
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
            if sub.isResolved {
                trackResolvedIfNeeded()
            }
            Task { await sub.preparePaywall() }
        }
        .onChange(of: sub.isResolved) { _, resolved in
            if resolved {
                trackResolvedIfNeeded()
            }
        }
        .alert("No previous purchase found", isPresented: $showNoRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("No previous purchase was found on this Apple ID. Make sure you're signed in with the same Apple ID you used to subscribe.")
        }
    }

    private func handleCustomerInfo(_ customerInfo: CustomerInfo, source: String) {
        err = nil
        sub.updateFromCustomerInfo(customerInfo)
        analytics.track(
            "rc_customer_info",
            properties: [
                "source": source,
                "entitlement_id": Entitlement.gluGold,
                "entitlement_active": sub.isPremium ? "1" : "0",
                "trial": sub.isInTrialPeriod ? "1" : "0",
            ]
        )
        if sub.isPremium {
            onUnlocked()
        }
    }

    /// PRD: honest dismiss — enter **free mode** with 5 analyses (no silent sign-out).
    private func dismissIntoFreeTier(source: String) {
        analytics.track("paywall_dismissed", properties: ["via": source])
        appState.enterFreeTierQuota(APIConfig.freeTierQuota, staffRole: auth.staffRole, subscriptionAllowsAccess: sub.isPremium)
    }

    /// Minimal fallback when `REVENUECAT_API_KEY` is missing (Simulator / CI).
    private var offlineDevPaywall: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Your spike-smart plan is ready")
                    .font(AppTheme.Typography.title)
                Text("Start Glu Gold for unlimited meal analysis — or try 5 meals first.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)

                Button("Unlock locally (QA)") {
                    Task {
                        inFlight = true
                        defer { inFlight = false }
                        do {
                            try await sub.purchaseSelectedPlan(annualPreferred: true)
                            if sub.isPremium { onUnlocked() }
                        } catch {
                            show(error)
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(inFlight)

                Button("Try \(APIConfig.freeTierQuota) meals first") {
                    dismissIntoFreeTier(source: "try_free_dev")
                }
                .font(AppTheme.Typography.subhead)
                .disabled(inFlight)

                Button("Restore purchases") {
                    restore()
                }
                .disabled(inFlight)

                Button("Have a code?") {
                    Task { await sub.presentCodeRedemptionSheet() }
                }
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.brand)
                .disabled(inFlight)

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
            }
            .padding(AppTheme.Layout.screenPadding)
        }
    }

    private func restore() {
        guard !inFlight else { return }
        inFlight = true
        err = nil
        analytics.track("restore_started", properties: nil)
        Task {
            defer { inFlight = false }
            do {
                let outcome = try await sub.restorePurchases()
                switch outcome {
                case .restoredEntitlement:
                    analytics.track("restore_succeeded", properties: ["entitlement_active": "1"])
                    onUnlocked()
                case .noEntitlementFound:
                    analytics.track("restore_no_entitlement_found", properties: nil)
                    showNoRestoreAlert = true
                }
            } catch {
                show(error)
            }
        }
    }

    private func show(_ error: Error) {
        switch PaywallUserError(from: error) {
        case .silent:
            err = nil
        case .message(let message):
            err = message
        }
    }

    private func trackResolvedIfNeeded() {
        guard !trackedResolved else { return }
        trackedResolved = true
        analytics.track(
            "paywall_resolved",
            properties: [
                "eligible_for_trial": sub.isInTrialPeriod ? "1" : "0",
                "selected_package_default": "annual",
            ]
        )
    }
}

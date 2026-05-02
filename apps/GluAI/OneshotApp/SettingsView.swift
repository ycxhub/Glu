import RevenueCatUI
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    var api: APIClient
    @Bindable var auth: AuthController
    @Bindable var sub: RevenueCatSubscriptionService
    @State private var showDeleteConfirm = false
    @State private var busyDelete = false
    @State private var err: String?

    private var revenueCatConfigured: Bool {
        guard let k = APIConfig.revenueCatAPIKey, !k.isEmpty, k != "REPLACE_ME" else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let e = err {
                        Text(e).font(.caption).foregroundStyle(AppTheme.error)
                    }
                    if let u = auth.userId {
                        Text("User ID: \(u)")
                            .font(AppTheme.Typography.caption)
                    }
                    if let role = auth.staffRole {
                        Text("Staff role: \(role.rawValue)")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.secondaryLabel)
                    }
                }
                Section("Subscription") {
                    Text("Glu Gold: \(appState.isPremium ? "Active" : "Inactive")")
                    if sub.isInTrialPeriod {
                        Text("Trial active").font(AppTheme.Typography.caption).foregroundStyle(AppTheme.secondaryLabel)
                    }
                    if appState.choseFreeTier, !appState.isPremium {
                        Text("Free mode: \(appState.freeMealAnalysesRemaining) meal analyses left")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.secondaryLabel)
                            .accessibilityLabel("Free mode, \(appState.freeMealAnalysesRemaining) meal analyses remaining")
                    }
                    Button("Restore purchases") {
                        Task {
                            try? await sub.restorePurchases()
                            if sub.isPremium {
                                appState.setPremiumUnlocked()
                            }
                        }
                    }
                    if revenueCatConfigured {
                        NavigationLink("Subscription & billing help") {
                            CustomerCenterView()
                                .onCustomerCenterRestoreCompleted { customerInfo in
                                    sub.updateFromCustomerInfo(customerInfo)
                                    if sub.isPremium {
                                        appState.setPremiumUnlocked()
                                    }
                                }
                        }
                    }
                }
                Section("Preferences") {
                    Text("Meal reminders and nudges can be adjusted here in a future update.")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
                Section("Health context") {
                    Text("Glu AI provides educational estimates only — not medical advice. Always follow your care team’s plan.")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
                Section("Legal") {
                    Link("Terms of Use", destination: AppLegalLinks.termsOfUse)
                    Link("Privacy Policy", destination: AppLegalLinks.privacyPolicy)
                }
                #if DEBUG
                Section("Developer") {
                    Button("Reset onboarding (QA)") {
                        Task {
                            await sub.logOut()
                            await auth.signOutFromSupabase()
                            appState.resetOnboardingForQA()
                        }
                    }
                    .font(AppTheme.Typography.footnote)
                }
                #endif
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
            }
            .navigationTitle("Settings")
        }
        .alert("Delete your Glu account?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete account", role: .destructive) {
                Task { await deleteAccountFlow() }
            }
        } message: {
            Text(
                "This permanently deletes your Supabase account and associated meal logs. Subscriptions are managed in the App Store; cancel renewal there if needed."
            )
        }
    }

    private func deleteAccountFlow() async {
        guard let token = auth.accessToken, !token.isEmpty else {
            await MainActor.run {
                err = "Sign in again to delete your account."
            }
            return
        }
        await MainActor.run {
            busyDelete = true
            err = nil
        }
        do {
            try await api.deleteAccount(accessToken: token)
            await sub.logOut()
            await auth.signOutFromSupabase()
            await MainActor.run {
                appState.signOutUser()
                busyDelete = false
            }
        } catch {
            await MainActor.run {
                busyDelete = false
                if let m = error as? MealAnalyzeError, case .badStatus(let c) = m {
                    err = "Could not delete account (HTTP \(c)). Try again or sign out and contact support."
                } else {
                    err = GluMealAnalysisUserCopy.connectionFailed
                }
            }
        }
    }
}

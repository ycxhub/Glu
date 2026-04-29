import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Bindable var auth: AuthController
    @Bindable var sub: LocalSubscriptionService
    @State private var showDeleteConfirm = false
    @State private var err: String?

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
                }
                Section("Subscription") {
                    Text("Premium: \(appState.isPremium ? "Yes" : "No")")
                    Button("Restore purchases") {
                        Task { try? await sub.restorePurchases() }
                    }
                }
                Section("Developer") {
                    Button("Reset onboarding (QA)") {
                        auth.signOut()
                        appState.resetOnboardingForQA()
                    }
                    .font(AppTheme.Typography.footnote)
                }
                Section {
                    Button("Sign out") {
                        auth.signOut()
                        appState.signOutUser()
                    }
                    Button("Delete account (5.1.1(v) flow)", role: .destructive) {
                        showDeleteConfirm = true
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Delete all data locally?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                err = "Implement Supabase cascade + Storage + RC per prd-glu-ai/auth.md"
            }
        } message: {
            Text("This build only clears the session when you sign out. Server delete is TODO.")
        }
    }
}

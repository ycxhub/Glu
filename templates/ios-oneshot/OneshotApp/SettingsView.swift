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
                        Text("User: \(u)")
                    }
                }
                Section("Subscription") {
                    Text("Premium: \(appState.isPremium ? "Yes" : "No")")
                    Button("Restore") {
                        Task { try? await sub.restorePurchases() }
                    }
                }
                Section {
                    Button("Sign out", role: .none) {
                        appState.signOutUser()
                        auth.signOut()
                    }
                    Button("Delete account (5.1.1(v) flow)", role: .destructive) {
                        showDeleteConfirm = true
                    }
                }
            }
        }
        .alert("Delete all data locally?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                err = "TODO(oneshot): call Supabase cascade + RC + Storage from architecture.md"
            }
        } message: {
            Text("This template only clears the session. Implement server delete.")
        }
    }
}

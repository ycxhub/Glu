import SwiftUI

struct MainTabView: View {
    @Bindable var auth: AuthController
    var api: APIClient
    @Bindable var subs: LocalSubscriptionService
    var analytics: NoopAnalytics

    var body: some View {
        TabView {
            HomeView(
                userId: auth.userId,
                onOpenCore: { }
            )
            .tabItem { Label("Home", systemImage: "house") }

            CoreActionView(api: api, auth: auth, analytics: analytics)
                .tabItem { Label("Add", systemImage: "plus.circle") }

            SettingsView(auth: auth, sub: subs)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

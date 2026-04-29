import SwiftUI

struct MainTabView: View {
    @Bindable var auth: AuthController
    var api: APIClient
    @Bindable var subs: LocalSubscriptionService
    var analytics: NoopAnalytics
    @Bindable var meals: MealLogStore

    var body: some View {
        TabView {
            HomeView(meals: meals, userId: auth.userId, displayName: auth.displayName)
                .tabItem { Label("Home", systemImage: "house") }

            CoreActionView(api: api, auth: auth, analytics: analytics, meals: meals)
                .tabItem { Label("Log", systemImage: "camera.viewfinder") }

            HistoryView(meals: meals)
                .tabItem { Label("History", systemImage: "clock") }

            SettingsView(auth: auth, sub: subs)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(AppTheme.brand)
        .onAppear {
            analytics.track("home_viewed", properties: nil)
        }
    }
}

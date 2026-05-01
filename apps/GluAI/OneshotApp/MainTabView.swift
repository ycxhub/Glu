import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Bindable var auth: AuthController
    var api: APIClient
    @Bindable var subs: RevenueCatSubscriptionService
    var analytics: NoopAnalytics
    @Bindable var meals: MealLogStore

    var body: some View {
        TabView(selection: Binding(
            get: { appState.selectedMainTab },
            set: { appState.selectedMainTab = $0 }
        )) {
            HomeView(meals: meals, userId: auth.userId, displayName: auth.displayName)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            CoreActionView(api: api, auth: auth, subs: subs, analytics: analytics, meals: meals)
                .tabItem { Label("Log", systemImage: "camera.viewfinder") }
                .tag(1)

            HistoryView(meals: meals)
                .tabItem { Label("History", systemImage: "clock") }
                .tag(2)

            SettingsView(auth: auth, sub: subs)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .tint(AppTheme.brand)
        .onAppear {
            trackMainTab(appState.selectedMainTab)
            Task { await meals.loadRemoteMeals() }
        }
        .onChange(of: appState.selectedMainTab) { _, tab in
            trackMainTab(tab)
        }
    }

    private func trackMainTab(_ tab: Int) {
        switch tab {
        case 0:
            analytics.track("home_viewed", properties: nil)
        case 1:
            analytics.track("log_viewed", properties: nil)
        case 2:
            analytics.track("history_viewed", properties: nil)
        case 3:
            analytics.track("settings_viewed", properties: nil)
        default:
            break
        }
    }
}

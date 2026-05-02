import SwiftUI

/// Glu AI — SwiftUI shell; spec: `apps/GluAI/design.md` + `screens_updated.md`.
@main
struct OneshotAppApp: App {
    @State private var appState = AppState()
    @State private var analytics = NoopAnalytics()

    init() {
        RevenueCatSubscriptionService.configurePurchasesAtAppLaunch()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
                .environment(analytics)
        }
    }
}

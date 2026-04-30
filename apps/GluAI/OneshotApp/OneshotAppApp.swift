import SwiftUI

/// Glu AI — SwiftUI shell from `prd-glu-ai/` + `templates/ios-oneshot`.
@main
struct OneshotAppApp: App {
    @State private var appState = AppState()

    init() {
        RevenueCatSubscriptionService.configurePurchasesAtAppLaunch()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
        }
    }
}

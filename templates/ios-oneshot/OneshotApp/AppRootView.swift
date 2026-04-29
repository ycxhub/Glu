import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @State private var auth = AuthController()
    @State private var api = APIClient()
    @State private var subs = LocalSubscriptionService()
    @State private var analytics = NoopAnalytics()

    var body: some View {
        Group {
            switch appState.phase {
            case .onboarding:
                OnboardingView()
            case .auth:
                AuthView(
                    auth: auth,
                    onComplete: { uid in
                        appState.setSignedIn(userId: uid)
                    }
                )
            case .paywall:
                PaywallView(
                    sub: subs,
                    onUnlocked: {
                        appState.setPremiumUnlocked()
                    }
                )
            case .main:
                MainTabView(
                    auth: auth,
                    api: api,
                    subs: subs,
                    analytics: analytics
                )
            }
        }
        .environment(auth)
    }
}

import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @State private var auth = AuthController()
    @State private var api = APIClient()
    @State private var subs = LocalSubscriptionService()
    @State private var analytics = NoopAnalytics()
    @State private var mealStore = MealLogStore()

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
                        analytics.track("auth_completed", properties: ["provider": "apple_or_dev"])
                    }
                )
            case .paywall:
                PaywallView(
                    sub: subs,
                    onUnlocked: {
                        appState.setPremiumUnlocked()
                        analytics.track("trial_started", properties: ["product_id": "dev"])
                    },
                    analytics: analytics
                )
            case .main:
                MainTabView(
                    auth: auth,
                    api: api,
                    subs: subs,
                    analytics: analytics,
                    meals: mealStore
                )
            }
        }
        .environment(auth)
        .environment(mealStore)
    }
}

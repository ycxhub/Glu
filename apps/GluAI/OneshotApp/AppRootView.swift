import SwiftUI
import Supabase

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @State private var auth = AuthController()
    @State private var api = APIClient()
    @State private var subs = RevenueCatSubscriptionService()
    @State private var analytics = NoopAnalytics()
    @State private var mealStore = MealLogStore()
    @State private var supabaseClient: SupabaseClient? = APIConfig.makeSupabaseClient()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                switch appState.phase {
                case .onboarding:
                    OnboardingView()
                case .auth:
                    AuthView(
                        auth: auth,
                        supabase: supabaseClient,
                        onComplete: {
                            Task { await completeSignInFlow() }
                        }
                    )
                case .paywall:
                    PaywallView(
                        sub: subs,
                        onUnlocked: {
                            appState.setPremiumUnlocked()
                            analytics.track("trial_started", properties: ["product_id": "rc"])
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

            if auth.staffRole == .developer {
                DevNavigatorOverlay()
                    .padding(16)
            }
        }
        .environment(auth)
        .environment(mealStore)
        .onAppear {
            auth.attachSupabase(supabaseClient)
            subs.configure()
            mealStore.configureSync(client: supabaseClient, userId: auth.userId)
        }
        .task {
            await bootstrap()
        }
        .onChange(of: subs.isPremium) { _, active in
            appState.applyAccessRouting(
                onboardingCompleted: appState.isOnboardingCompleted,
                signedIn: auth.isSignedIn,
                staffRole: auth.staffRole,
                subscriptionAllowsAccess: active
            )
        }
        .onChange(of: auth.userId) { _, newId in
            mealStore.configureSync(client: supabaseClient, userId: newId)
        }
    }

    private func bootstrap() async {
        subs.configure()
        auth.attachSupabase(supabaseClient)

        guard let client = supabaseClient else {
            if let cached = appState.sessionUserId {
                auth.setMockSession(userId: cached, displayName: nil)
                await subs.refreshCustomerInfo()
                await subs.logIn(appUserId: cached)
                mealStore.configureSync(client: nil, userId: cached)
                await mealStore.loadRemoteMeals()
                appState.applyAccessRouting(
                    onboardingCompleted: appState.isOnboardingCompleted,
                    signedIn: true,
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
            }
            return
        }

        do {
            let session = try await client.auth.session
            auth.applySupabaseSession(session)
            appState.setSignedIn(userId: session.user.id.uuidString)
            await auth.fetchStaffRoleIfNeeded()
            await subs.logIn(appUserId: session.user.id.uuidString)
            await subs.refreshCustomerInfo()
            mealStore.configureSync(client: client, userId: auth.userId)
            await mealStore.loadRemoteMeals()
            appState.applyAccessRouting(
                onboardingCompleted: appState.isOnboardingCompleted,
                signedIn: true,
                staffRole: auth.staffRole,
                subscriptionAllowsAccess: subs.isPremium
            )
        } catch {
            if let cached = appState.sessionUserId {
                auth.setMockSession(userId: cached, displayName: nil)
                await subs.logIn(appUserId: cached)
                await subs.refreshCustomerInfo()
                mealStore.configureSync(client: client, userId: cached)
                appState.applyAccessRouting(
                    onboardingCompleted: appState.isOnboardingCompleted,
                    signedIn: true,
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
            }
        }
    }

    private func completeSignInFlow() async {
        guard let uid = auth.userId else { return }
        appState.setSignedIn(userId: uid)
        await auth.fetchStaffRoleIfNeeded()
        await subs.logIn(appUserId: uid)
        await subs.refreshCustomerInfo()
        mealStore.configureSync(client: supabaseClient, userId: uid)
        await mealStore.loadRemoteMeals()
        appState.applyAccessRouting(
            onboardingCompleted: appState.isOnboardingCompleted,
            signedIn: true,
            staffRole: auth.staffRole,
            subscriptionAllowsAccess: subs.isPremium
        )
    }
}

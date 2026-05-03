import Testing
import Foundation
@testable import Glu_AI

// MARK: - AppState Phase Routing Tests
//
// Phase state machine:
//
//   ┌──────────┐     ┌──────┐     ┌─────────┐     ┌──────┐
//   │Onboarding│────▶│ Auth │────▶│ Paywall │────▶│ Main │
//   └──────────┘     └──────┘     └─────────┘     └──────┘
//                        ▲                            │
//                        └────── signOut ──────────────┘
//

@Suite("AppState phase routing")
struct AppStatePhaseTests {

    // MARK: - Fresh launch

    @Test("Fresh launch starts at onboarding")
    func freshLaunchStartsOnboarding() {
        let defaults = UserDefaults.ephemeral()
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .onboarding)
    }

    @Test("Completed onboarding without sign-in goes to auth")
    func onboardingDoneGoesToAuth() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .auth)
    }

    @Test("Signed-in non-premium user without free tier goes to paywall")
    func signedInNoPremiumGoesToPaywall() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .paywall)
    }

    @Test("Signed-in premium user goes to main")
    func premiumGoesToMain() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.isPremium")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .main)
    }

    @Test("Signed-in free tier user with remaining analyses goes to main")
    func freeTierWithCreditsGoesToMain() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(3, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .main)
    }

    @Test("Free tier with zero remaining analyses goes to paywall")
    func freeTierExhaustedGoesToPaywall() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(0, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .paywall)
    }

    // MARK: - Transitions

    @Test("setOnboardingCompleted transitions from onboarding to auth")
    @MainActor
    func setOnboardingCompletedTransitions() {
        let defaults = UserDefaults.ephemeral()
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .onboarding)

        state.setOnboardingCompleted()
        #expect(state.phase == .auth)
        #expect(state.isOnboardingCompleted == true)
    }

    @Test("setSignedIn transitions from auth to paywall (non-premium)")
    @MainActor
    func setSignedInTransitionsToPaywall() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .auth)

        state.setSignedIn(userId: "user-456")
        #expect(state.phase == .paywall)
        #expect(state.sessionUserId == "user-456")
    }

    @Test("setPremiumUnlocked transitions to main and clears free tier")
    @MainActor
    func setPremiumUnlockedTransitions() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-789", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(3, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)

        state.setPremiumUnlocked()
        #expect(state.phase == .main)
        #expect(state.isPremium == true)
        #expect(state.choseFreeTier == false)
        #expect(state.freeMealAnalysesRemaining == 0)
    }

    @Test("signOutUser resets to auth phase")
    @MainActor
    func signOutResetsToAuth() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.isPremium")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .main)

        state.signOutUser()
        #expect(state.phase == .auth)
        #expect(state.sessionUserId == nil)
        #expect(state.isPremium == false)
    }

    // MARK: - Free tier quota

    @Test("enterFreeTierQuota sets credits and transitions to main")
    @MainActor
    func enterFreeTierSetsCredits() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        let state = AppState(userDefaults: defaults)
        #expect(state.phase == .paywall)

        state.enterFreeTierQuota(5, staffRole: nil, subscriptionAllowsAccess: false)
        #expect(state.phase == .main)
        #expect(state.choseFreeTier == true)
        #expect(state.freeMealAnalysesRemaining == 5)
    }

    @Test("recordSuccessfulFreeTierAnalysis decrements remaining count")
    @MainActor
    func recordAnalysisDecrements() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(3, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)

        state.recordSuccessfulFreeTierAnalysis(staffRole: nil, subscriptionAllowsAccess: false)
        #expect(state.freeMealAnalysesRemaining == 2)
    }

    @Test("recordSuccessfulFreeTierAnalysis skips decrement for premium users")
    @MainActor
    func recordAnalysisSkipsForPremium() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(3, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)

        state.recordSuccessfulFreeTierAnalysis(staffRole: nil, subscriptionAllowsAccess: true)
        #expect(state.freeMealAnalysesRemaining == 3)
    }

    @Test("recordSuccessfulFreeTierAnalysis skips decrement for admin staff")
    @MainActor
    func recordAnalysisSkipsForAdmin() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(3, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)

        state.recordSuccessfulFreeTierAnalysis(staffRole: .admin, subscriptionAllowsAccess: false)
        #expect(state.freeMealAnalysesRemaining == 3)
    }

    @Test("recordSuccessfulFreeTierAnalysis does not go below zero")
    @MainActor
    func recordAnalysisFloorAtZero() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.choseFreeTier")
        defaults.set(0, forKey: "gluai.freeAnalysesRemaining")
        let state = AppState(userDefaults: defaults)

        state.recordSuccessfulFreeTierAnalysis(staffRole: nil, subscriptionAllowsAccess: false)
        #expect(state.freeMealAnalysesRemaining == 0)
    }

    @Test("resetOnboardingForQA clears everything and returns to onboarding")
    @MainActor
    func resetOnboardingForQA() {
        let defaults = UserDefaults.ephemeral()
        defaults.set(true, forKey: "gluai.onboardingDone")
        defaults.set("user-123", forKey: "gluai.userId")
        defaults.set(true, forKey: "gluai.isPremium")
        let state = AppState(userDefaults: defaults)

        state.resetOnboardingForQA()
        #expect(state.phase == .onboarding)
        #expect(state.sessionUserId == nil)
        #expect(state.isPremium == false)
        #expect(state.isOnboardingCompleted == false)
        #expect(state.onboardingProgressIndex == 0)
    }
}

// MARK: - AccessEvaluator Tests

@Suite("AccessEvaluator canUseMainApp")
struct AccessEvaluatorTests {

    @Test("Admin staff always has access")
    func adminAlwaysHasAccess() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: .admin,
            subscriptionAllowsAccess: false,
            choseFreeTier: false,
            freeMealAnalysesRemaining: 0
        ) == true)
    }

    @Test("Developer staff always has access")
    func developerAlwaysHasAccess() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: .developer,
            subscriptionAllowsAccess: false,
            choseFreeTier: false,
            freeMealAnalysesRemaining: 0
        ) == true)
    }

    @Test("Subscriber has access")
    func subscriberHasAccess() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: nil,
            subscriptionAllowsAccess: true,
            choseFreeTier: false,
            freeMealAnalysesRemaining: 0
        ) == true)
    }

    @Test("Free tier with remaining analyses has access")
    func freeTierWithCreditsHasAccess() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: nil,
            subscriptionAllowsAccess: false,
            choseFreeTier: true,
            freeMealAnalysesRemaining: 3
        ) == true)
    }

    @Test("Free tier with zero analyses denied")
    func freeTierExhaustedDenied() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: nil,
            subscriptionAllowsAccess: false,
            choseFreeTier: true,
            freeMealAnalysesRemaining: 0
        ) == false)
    }

    @Test("No role, no subscription, no free tier denied")
    func nothingDenied() {
        #expect(AccessEvaluator.canUseMainApp(
            staffRole: nil,
            subscriptionAllowsAccess: false,
            choseFreeTier: false,
            freeMealAnalysesRemaining: 0
        ) == false)
    }
}

// MARK: - UserDefaults ephemeral helper

extension UserDefaults {
    /// In-memory defaults that don't persist — safe for parallel tests.
    static func ephemeral() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }
}

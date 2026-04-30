import Foundation
import SwiftUI

/// App phase: onboard → auth → paywall → main (`prd-glu-ai/auth.md` + `paywall.md`).
@Observable
final class AppState {
    enum Phase: Equatable {
        case onboarding
        case auth
        case paywall
        case main
    }

    var phase: Phase
    /// Used when `phase == .main` (`TabView` selection).
    var selectedMainTab: Int = 0
    /// Legacy cache for funnel / no-RevenueCat builds; prefer subscription service when wired.
    var isPremium: Bool
    var sessionUserId: String?
    var onboardingProgressIndex: Int

    private let userDefaults: UserDefaults

    var isOnboardingCompleted: Bool {
        userDefaults.bool(forKey: Keys.onboardingDone)
    }

    init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
        let premium = userDefaults.bool(forKey: Keys.premium)
        self.isPremium = premium
        let uid = userDefaults.string(forKey: Keys.userId)
        self.sessionUserId = uid
        self.onboardingProgressIndex = userDefaults.integer(forKey: Keys.onboardingIndex)
        let onboardingDone = userDefaults.bool(forKey: Keys.onboardingDone)
        if !onboardingDone {
            self.phase = .onboarding
        } else if uid == nil {
            self.phase = .auth
        } else if !premium {
            self.phase = .paywall
        } else {
            self.phase = .main
        }
    }

    // MARK: - Routing

    /// Single place to align root phase with onboarding, auth session, and paywall rules.
    func refreshRouting(
        onboardingCompleted: Bool,
        isSignedIn: Bool,
        canUseMainApp: Bool
    ) {
        if !onboardingCompleted {
            phase = .onboarding
            return
        }
        if !isSignedIn {
            phase = .auth
            return
        }
        if !canUseMainApp {
            phase = .paywall
            return
        }
        phase = .main
    }

    func setOnboardingCompleted() {
        userDefaults.set(true, forKey: Keys.onboardingDone)
        refreshRouting(
            onboardingCompleted: true,
            isSignedIn: sessionUserId != nil,
            canUseMainApp: isPremium
        )
    }

    func setSignedIn(userId: String) {
        userDefaults.set(userId, forKey: Keys.userId)
        sessionUserId = userId
        refreshRouting(
            onboardingCompleted: userDefaults.bool(forKey: Keys.onboardingDone),
            isSignedIn: true,
            canUseMainApp: isPremium
        )
    }

    /// Call after RevenueCat / StoreKit success; until then `LocalSubscriptionService` + dev paywall use this.
    func setPremiumUnlocked() {
        userDefaults.set(true, forKey: Keys.premium)
        isPremium = true
        refreshRouting(
            onboardingCompleted: userDefaults.bool(forKey: Keys.onboardingDone),
            isSignedIn: sessionUserId != nil,
            canUseMainApp: true
        )
    }

    func applyAccessRouting(
        onboardingCompleted: Bool,
        signedIn: Bool,
        staffRole: StaffRole?,
        subscriptionAllowsAccess: Bool
    ) {
        let canMain = AccessEvaluator.canUseMainApp(
            staffRole: staffRole,
            subscriptionAllowsAccess: subscriptionAllowsAccess
        )
        let staffUnlocks = staffRole == .admin || staffRole == .developer
        isPremium = subscriptionAllowsAccess || staffUnlocks
        userDefaults.set(subscriptionAllowsAccess || staffUnlocks, forKey: Keys.premium)
        refreshRouting(
            onboardingCompleted: onboardingCompleted,
            isSignedIn: signedIn,
            canUseMainApp: canMain
        )
    }

    func saveOnboardingIndex(_ i: Int) {
        onboardingProgressIndex = i
        userDefaults.set(i, forKey: Keys.onboardingIndex)
    }

    func signOutUser() {
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.set(false, forKey: Keys.premium)
        sessionUserId = nil
        isPremium = false
        phase = .auth
    }

    /// Reset onboarding for QA (Settings) — clears session so the funnel runs cleanly.
    func resetOnboardingForQA() {
        userDefaults.set(false, forKey: Keys.onboardingDone)
        userDefaults.set(0, forKey: Keys.onboardingIndex)
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.set(false, forKey: Keys.premium)
        sessionUserId = nil
        isPremium = false
        onboardingProgressIndex = 0
        phase = .onboarding
    }

    // MARK: - Developer navigation

    func devJumpToPhase(_ target: Phase) {
        switch target {
        case .onboarding:
            userDefaults.set(false, forKey: Keys.onboardingDone)
            phase = .onboarding
        case .auth:
            phase = .auth
        case .paywall:
            phase = .paywall
        case .main:
            phase = .main
        }
    }

    fileprivate enum Keys {
        static let premium = "gluai.isPremium"
        static let userId = "gluai.userId"
        static let onboardingDone = "gluai.onboardingDone"
        static let onboardingIndex = "gluai.onboardingIndex"
    }
}

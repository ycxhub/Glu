import Foundation
import SwiftUI

/// App phase: onboard → auth → paywall → main (`prd-glu-ai-redesign`).
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
    /// Subscriber / trial / staff — **not** the same as “chose free tier”.
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
        } else {
            let chose = userDefaults.bool(forKey: Keys.choseFreeTier)
            let left = userDefaults.integer(forKey: Keys.freeAnalyses)
            let canMain = premium || (chose && left > 0)
            self.phase = canMain ? .main : .paywall
        }
    }

    // MARK: - Free tier (PRD: 5 analyses)

    var choseFreeTier: Bool {
        userDefaults.bool(forKey: Keys.choseFreeTier)
    }

    var freeMealAnalysesRemaining: Int {
        userDefaults.integer(forKey: Keys.freeAnalyses)
    }

    /// After paywall dismiss — labeled “Try 5 meals first”.
    func enterFreeTierQuota(_ count: Int = 5, staffRole: StaffRole?, subscriptionAllowsAccess: Bool) {
        userDefaults.set(true, forKey: Keys.choseFreeTier)
        userDefaults.set(count, forKey: Keys.freeAnalyses)
        applyAccessRouting(
            onboardingCompleted: isOnboardingCompleted,
            signedIn: sessionUserId != nil,
            staffRole: staffRole,
            subscriptionAllowsAccess: subscriptionAllowsAccess
        )
    }

    /// After a successful AI analysis. Does **not** change phase mid-session (user may finish saving the 5th meal).
    func recordSuccessfulFreeTierAnalysis(staffRole: StaffRole?, subscriptionAllowsAccess: Bool) {
        guard !subscriptionAllowsAccess else { return }
        if let staffRole, staffRole == .admin || staffRole == .developer { return }
        guard userDefaults.bool(forKey: Keys.choseFreeTier) else { return }
        var r = userDefaults.integer(forKey: Keys.freeAnalyses)
        guard r > 0 else { return }
        r -= 1
        userDefaults.set(r, forKey: Keys.freeAnalyses)
    }

    /// Call when user attempts a new analysis with **0** credits (e.g. reopen Log) or on cold launch via `applyAccessRouting`.
    func refreshPhaseForAccess(staffRole: StaffRole?, subscriptionAllowsAccess: Bool) {
        applyAccessRouting(
            onboardingCompleted: isOnboardingCompleted,
            signedIn: sessionUserId != nil,
            staffRole: staffRole,
            subscriptionAllowsAccess: subscriptionAllowsAccess
        )
    }

    func canStartNewMealAnalysis(staffRole: StaffRole?, subscriptionAllowsAccess: Bool) -> Bool {
        AccessEvaluator.canUseMainApp(
            staffRole: staffRole,
            subscriptionAllowsAccess: subscriptionAllowsAccess,
            choseFreeTier: userDefaults.bool(forKey: Keys.choseFreeTier),
            freeMealAnalysesRemaining: userDefaults.integer(forKey: Keys.freeAnalyses)
        )
    }

    // MARK: - Routing

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
            canUseMainApp: isPremium || (choseFreeTier && freeMealAnalysesRemaining > 0)
        )
    }

    func setSignedIn(userId: String) {
        userDefaults.set(userId, forKey: Keys.userId)
        sessionUserId = userId
        refreshRouting(
            onboardingCompleted: userDefaults.bool(forKey: Keys.onboardingDone),
            isSignedIn: true,
            canUseMainApp: isPremium || (choseFreeTier && freeMealAnalysesRemaining > 0)
        )
    }

    /// RevenueCat / StoreKit success — clears free-tier flags for a clean subscriber state.
    func setPremiumUnlocked() {
        userDefaults.set(false, forKey: Keys.choseFreeTier)
        userDefaults.set(0, forKey: Keys.freeAnalyses)
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
        let staffUnlocks = staffRole == .admin || staffRole == .developer
        isPremium = subscriptionAllowsAccess || staffUnlocks
        userDefaults.set(subscriptionAllowsAccess || staffUnlocks, forKey: Keys.premium)

        let chose = userDefaults.bool(forKey: Keys.choseFreeTier)
        let left = userDefaults.integer(forKey: Keys.freeAnalyses)
        let canMain = AccessEvaluator.canUseMainApp(
            staffRole: staffRole,
            subscriptionAllowsAccess: subscriptionAllowsAccess,
            choseFreeTier: chose,
            freeMealAnalysesRemaining: left
        )
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
        userDefaults.set(false, forKey: Keys.choseFreeTier)
        userDefaults.removeObject(forKey: Keys.freeAnalyses)
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
        userDefaults.set(false, forKey: Keys.choseFreeTier)
        userDefaults.removeObject(forKey: Keys.freeAnalyses)
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
        static let choseFreeTier = "gluai.choseFreeTier"
        static let freeAnalyses = "gluai.freeAnalysesRemaining"
    }
}

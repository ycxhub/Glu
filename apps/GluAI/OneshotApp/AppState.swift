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
    var isPremium: Bool
    var sessionUserId: String?
    var onboardingProgressIndex: Int

    private let userDefaults: UserDefaults

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

    func setOnboardingCompleted() {
        userDefaults.set(true, forKey: Keys.onboardingDone)
        phase = .auth
    }

    func setSignedIn(userId: String) {
        userDefaults.set(userId, forKey: Keys.userId)
        sessionUserId = userId
        if isPremium {
            phase = .main
        } else {
            phase = .paywall
        }
    }

    /// Call after RevenueCat / StoreKit success; until then `LocalSubscriptionService` + dev paywall use this.
    func setPremiumUnlocked() {
        userDefaults.set(true, forKey: Keys.premium)
        isPremium = true
        phase = .main
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

    fileprivate enum Keys {
        static let premium = "gluai.isPremium"
        static let userId = "gluai.userId"
        static let onboardingDone = "gluai.onboardingDone"
        static let onboardingIndex = "gluai.onboardingIndex"
    }
}

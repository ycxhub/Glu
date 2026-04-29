import Foundation
import SwiftUI

/// Coarse app phase: cold start → onboard → sign in → paywall (if not premium) → main tabs.
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

    /// Dev / placeholder: flips paywall for template smoke tests. Replace with RC entitlement.
    func setPremiumUnlocked() {
        userDefaults.set(true, forKey: Keys.premium)
        isPremium = true
        phase = .main
    }

    func saveOnboardingIndex(_ i: Int) {
        onboardingProgressIndex = i
        userDefaults.set(i, forKey: Keys.onboardingIndex)
    }

    /// Clear session; optional template sign-out from Settings.
    func signOutUser() {
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.set(false, forKey: Keys.premium)
        sessionUserId = nil
        isPremium = false
        phase = .auth
    }

    private enum Keys {
        static let premium = "oneshot.isPremium"
        static let userId = "oneshot.userId"
        static let onboardingDone = "oneshot.onboardingDone"
        static let onboardingIndex = "oneshot.onboardingIndex"
    }
}

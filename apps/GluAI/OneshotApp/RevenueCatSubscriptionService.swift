import Foundation
import Observation
import RevenueCat

/// Subscription access for Glu AI — entitlement **`Glu Gold`** in RevenueCat ([install docs](https://www.revenuecat.com/docs/getting-started/installation/ios)).
@MainActor
@Observable
final class RevenueCatSubscriptionService: SubscriptionControlling {
    /// True when **`Glu Gold`** is active (includes intro/trial while entitlement is active).
    private(set) var isPremium: Bool = false

    /// True when the user is in an introductory / trial period (if detectable on the entitlement).
    private(set) var isInTrialPeriod: Bool = false

    private static var purchasesSDKConfigured = false

    /// Call once from `@main` `App` `init()` so `RevenueCatUI` paywalls and Customer Center work immediately.
    static func configurePurchasesAtAppLaunch() {
        guard !purchasesSDKConfigured else { return }
        guard let key = APIConfig.revenueCatAPIKey, !key.isEmpty, key != "REPLACE_ME" else {
            return
        }
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: key)
        purchasesSDKConfigured = true
    }

    /// Idempotent — safe from `onAppear` after launch configuration.
    func configure() {
        Self.configurePurchasesAtAppLaunch()
    }

    func updateFromCustomerInfo(_ info: CustomerInfo) {
        let eid = APIConfig.revenueCatEntitlementId
        let ent = info.entitlements[eid]
        isPremium = ent?.isActive == true
        if let ent {
            isInTrialPeriod = ent.periodType == .trial
        } else {
            isInTrialPeriod = false
        }
    }

    /// Async helper for SwiftUI / debugging — same rule as ``isPremium``.
    func checkGluGoldAccess() async -> Bool {
        await refreshCustomerInfo()
        return isPremium
    }

    func refreshCustomerInfo() async {
        configure()
        guard APIConfig.revenueCatAPIKey != nil else { return }
        do {
            let info = try await Purchases.shared.customerInfo()
            updateFromCustomerInfo(info)
        } catch {
            #if DEBUG
            print("RevenueCat customerInfo failed:", error)
            #endif
        }
    }

    func logIn(appUserId: String) async {
        configure()
        guard APIConfig.revenueCatAPIKey != nil else { return }
        do {
            let (info, _) = try await Purchases.shared.logIn(appUserId)
            updateFromCustomerInfo(info)
        } catch {
            #if DEBUG
            print("RevenueCat logIn failed:", error)
            #endif
        }
    }

    func logOut() async {
        guard APIConfig.revenueCatAPIKey != nil else {
            isPremium = false
            isInTrialPeriod = false
            return
        }
        do {
            let info = try await Purchases.shared.logOut()
            updateFromCustomerInfo(info)
        } catch {
            isPremium = false
            isInTrialPeriod = false
        }
    }

    func restorePurchases() async throws {
        configure()
        guard APIConfig.revenueCatAPIKey != nil else { return }
        let info = try await Purchases.shared.restorePurchases()
        updateFromCustomerInfo(info)
    }

    func preparePaywall() async {
        configure()
        guard APIConfig.revenueCatAPIKey != nil else { return }
        _ = try? await Purchases.shared.offerings()
    }

    func purchaseSelectedPlan(annualPreferred: Bool) async throws {
        configure()
        guard let key = APIConfig.revenueCatAPIKey, !key.isEmpty, key != "REPLACE_ME" else {
            isPremium = true
            isInTrialPeriod = false
            return
        }
        let offerings = try await Purchases.shared.offerings()
        guard let current = offerings.current else {
            throw RCError.noOfferings
        }
        let pkg = Self.package(from: current, annualPreferred: annualPreferred)
        guard let pkg else { throw RCError.noPackage }
        let result = try await Purchases.shared.purchase(package: pkg)
        updateFromCustomerInfo(result.customerInfo)
        if !isPremium {
            throw RCError.notEntitled
        }
    }

    /// Resolves packages by RevenueCat **package identifier** (`yearly` / `monthly`), then standard annual/monthly slots.
    private static func package(from offering: Offering, annualPreferred: Bool) -> Package? {
        if annualPreferred {
            return offering.package(identifier: "yearly")
                ?? offering.annual
                ?? offering.availablePackages.first(where: { $0.identifier.lowercased().contains("year") })
        }
        return offering.package(identifier: "monthly")
            ?? offering.monthly
            ?? offering.availablePackages.first(where: { $0.identifier.lowercased().contains("month") })
    }

    enum RCError: LocalizedError {
        case noOfferings
        case noPackage
        case notEntitled

        var errorDescription: String? {
            switch self {
            case .noOfferings:
                return "No subscription offerings loaded. Link App Store products in RevenueCat and set a current offering."
            case .noPackage:
                return "No package for this plan. In RevenueCat, add packages with identifiers `yearly` and `monthly` (or use standard annual/monthly types)."
            case .notEntitled:
                return "Purchase finished but \(APIConfig.revenueCatEntitlementId) is not active yet. Try Restore purchases."
            }
        }
    }
}

import Foundation
import Observation
import RevenueCat
import StoreKit

/// Subscription access for Glu AI — the canonical RevenueCat entitlement lives in `Entitlement.gluGold`.
@MainActor
@Observable
final class RevenueCatSubscriptionService: NSObject, SubscriptionControlling {
    /// True when Glu Gold is active (includes intro/trial while entitlement is active).
    private(set) var isPremium: Bool = false

    /// True when the user is in an introductory / trial period (if detectable on the entitlement).
    private(set) var isInTrialPeriod: Bool = false
    private(set) var isResolved: Bool = false
    private(set) var pendingPromotedProductIdentifier: String?

    private static var purchasesSDKConfigured = false
    private var refreshTask: Task<CustomerInfo?, Never>?
    private var streamTask: Task<Void, Never>?

    private var hasUsableAPIKey: Bool {
        guard let key = APIConfig.revenueCatAPIKey?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !key.isEmpty && key != "REPLACE_ME"
    }

    /// Call once from `@main` `App` `init()` so `RevenueCatUI` paywalls and Customer Center work immediately.
    static func configurePurchasesAtAppLaunch() {
        guard !purchasesSDKConfigured else { return }
        guard let key = APIConfig.revenueCatAPIKey, !key.isEmpty, key != "REPLACE_ME" else {
            return
        }
        #if DEBUG
        Purchases.logLevel = .debug
        if !key.hasPrefix("appl_") {
            print(
                """
                [RevenueCat] REVENUECAT_API_KEY should be the iOS *public* SDK key (prefix appl_). \
                test_ / goog_ / amzn_ keys cause CONFIGURATION_ERROR (code 23) on iOS when loading products. \
                Key prefix: \(String(key.prefix(12)))…
                """
            )
        }
        #else
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: key)
        purchasesSDKConfigured = true
    }

    /// Idempotent — safe from `onAppear` after launch configuration.
    func configure() {
        Self.configurePurchasesAtAppLaunch()
        if !hasUsableAPIKey {
            isResolved = true
        } else {
            Purchases.shared.delegate = self
            startObservingCustomerInfo()
        }
    }

    func updateFromCustomerInfo(_ info: CustomerInfo) {
        let ent = info.gluGoldEntitlement ?? info.entitlements[APIConfig.revenueCatEntitlementId]
        isPremium = ent?.isActive == true
        if let ent {
            isInTrialPeriod = ent.periodType == .trial
        } else {
            isInTrialPeriod = false
        }
        isResolved = true
    }

    /// Async helper for SwiftUI / debugging — same rule as ``isPremium``.
    func checkGluGoldAccess() async -> Bool {
        await refreshCustomerInfo()
        return isPremium
    }

    func refreshCustomerInfo() async {
        configure()
        guard hasUsableAPIKey else {
            isResolved = true
            return
        }
        if let refreshTask {
            if let info = await refreshTask.value {
                updateFromCustomerInfo(info)
            }
            return
        }
        let task = Task<CustomerInfo?, Never> {
            do {
                return try await Purchases.shared.customerInfo()
            } catch {
                #if DEBUG
                print("RevenueCat customerInfo failed:", error)
                #endif
                return nil
            }
        }
        refreshTask = task
        let info = await task.value
        refreshTask = nil
        if let info {
            updateFromCustomerInfo(info)
        } else {
            isResolved = true
        }
    }

    func logIn(appUserId: String) async {
        configure()
        guard hasUsableAPIKey else {
            isResolved = true
            return
        }
        do {
            let (info, created) = try await Purchases.shared.logIn(appUserId)
            #if DEBUG
            print("RevenueCat logIn created alias:", created)
            #endif
            updateFromCustomerInfo(info)
        } catch {
            #if DEBUG
            print("RevenueCat logIn failed:", error)
            #endif
            isResolved = true
        }
    }

    func logOut() async {
        guard hasUsableAPIKey else {
            isPremium = false
            isInTrialPeriod = false
            isResolved = true
            return
        }
        do {
            let info = try await Purchases.shared.logOut()
            updateFromCustomerInfo(info)
        } catch {
            isPremium = false
            isInTrialPeriod = false
            isResolved = true
        }
    }

    func restorePurchases() async throws -> RestoreOutcome {
        configure()
        guard hasUsableAPIKey else {
            isResolved = true
            return isPremium ? .restoredEntitlement : .noEntitlementFound
        }
        let info = try await Purchases.shared.restorePurchases()
        updateFromCustomerInfo(info)
        return info.hasActiveGluGold ? .restoredEntitlement : .noEntitlementFound
    }

    func preparePaywall() async {
        configure()
        guard hasUsableAPIKey else { return }
        _ = try? await offeringsWithRetry()
    }

    func purchaseSelectedPlan(annualPreferred: Bool) async throws {
        configure()
        guard let key = APIConfig.revenueCatAPIKey, !key.isEmpty, key != "REPLACE_ME" else {
            isPremium = true
            isInTrialPeriod = false
            return
        }
        let offerings = try await offeringsWithRetry()
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
            return offering.package(identifier: "$rc_annual")
                ?? offering.package(identifier: "yearly")
                ?? offering.annual
                ?? offering.availablePackages.first(where: { $0.identifier.lowercased().contains("year") })
        }
        return offering.package(identifier: "$rc_monthly")
            ?? offering.package(identifier: "monthly")
            ?? offering.monthly
            ?? offering.availablePackages.first(where: { $0.identifier.lowercased().contains("month") })
    }

    func presentCodeRedemptionSheet() async {
        configure()
        guard hasUsableAPIKey else { return }
        Purchases.shared.presentCodeRedemptionSheet()
        await refreshCustomerInfo()
    }

    private func startObservingCustomerInfo() {
        guard streamTask == nil else { return }
        streamTask = Task { @MainActor [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                self?.updateFromCustomerInfo(info)
            }
        }
    }

    private func offeringsWithRetry() async throws -> Offerings {
        var delay: UInt64 = 500_000_000
        var lastError: Error?
        for attempt in 1 ... 3 {
            do {
                return try await Purchases.shared.offerings()
            } catch {
                lastError = error
                if attempt < 3 {
                    try? await Task.sleep(nanoseconds: delay)
                    delay *= 2
                }
            }
        }
        throw lastError ?? RCError.noOfferings
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

extension RevenueCatSubscriptionService: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        readyForPromotedProduct product: StoreProduct,
        purchase startPurchase: @escaping StartPurchaseBlock
    ) {
        Task { @MainActor [weak self] in
            self?.pendingPromotedProductIdentifier = product.productIdentifier
        }
        startPurchase { [weak self] _, customerInfo, error, _ in
            Task { @MainActor in
                if let customerInfo {
                    self?.updateFromCustomerInfo(customerInfo)
                } else if let error {
                    #if DEBUG
                    print("RevenueCat promoted purchase failed:", error)
                    #endif
                }
                self?.pendingPromotedProductIdentifier = nil
            }
        }
    }
}

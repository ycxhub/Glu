import Foundation
import os
import RevenueCat

enum Entitlement {
    static let gluGold = "Glu Gold"
    static let gluGoldSlug = "glu_gold"
}

extension CustomerInfo {
    var gluGoldEntitlement: EntitlementInfo? {
        if let entitlement = entitlements[Entitlement.gluGold] {
            return entitlement
        }
        if let slugEntitlement = entitlements[Entitlement.gluGoldSlug] {
            Logger(subsystem: "com.ycxlabs.gluai", category: "RevenueCat")
                .warning("RevenueCat entitlement resolved only through slug fallback.")
            return slugEntitlement
        }
        return nil
    }

    var hasActiveGluGold: Bool {
        gluGoldEntitlement?.isActive == true
    }
}

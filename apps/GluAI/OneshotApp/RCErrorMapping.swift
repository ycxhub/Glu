import Foundation
import RevenueCat

enum PaywallUserError: Equatable {
    case silent
    case message(String)

    init(from error: Error) {
        let nsError = error as NSError
        guard nsError.domain == ErrorCode.errorDomain,
              let code = ErrorCode(rawValue: nsError.code)
        else {
            self = .message(String(localized: "Something went wrong. Please try again."))
            return
        }

        switch code {
        case .purchaseCancelledError:
            self = .silent
        case .paymentPendingError:
            self = .message(String(localized: "Waiting for approval."))
        case .networkError:
            self = .message(String(localized: "Connection issue. Try again."))
        case .storeProblemError:
            self = .message(String(localized: "The App Store is unavailable. Try again later."))
        case .productNotAvailableForPurchaseError:
            self = .message(String(localized: "This subscription is not available in your region."))
        case .receiptAlreadyInUseError:
            self = .message(String(localized: "This Apple ID is already linked to another Glu account."))
        default:
            self = .message(String(localized: "Something went wrong. Please try again."))
        }
    }
}

enum RestoreOutcome: Equatable {
    case restoredEntitlement
    case noEntitlementFound
}

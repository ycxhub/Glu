import Foundation
import Observation
import Supabase

// MARK: - Analytics (`prd-glu-ai/architecture.md`)

protocol AnalyticsService: AnyObject {
    func track(_ name: String, properties: [String: String]?)
}

@Observable
final class NoopAnalytics: AnalyticsService {
    func track(_ name: String, properties: [String: String]?) {
        #if DEBUG
        print("analytics:", name, properties ?? [:])
        #endif
    }
}

// MARK: - API (Supabase Edge proxy — no LLM keys in app)

enum APIConfig {
    private static let appSecrets: [String: String] = {
        guard let url = Bundle.main.url(forResource: "AppSecrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any]
        else { return [:] }
        return dict.compactMapValues { $0 as? String }
    }()

    /// Base URL (`https://…supabase.co`). Prefer `AppSecrets.plist` (see `AppSecrets.plist.example`); Info.plist keys optional.
    static var supabaseURL: String? {
        if let full = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String {
            let u = full.trimmingCharacters(in: .whitespacesAndNewlines)
            if !u.isEmpty { return u }
        }
        if let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL_HOST") as? String {
            let h = host.trimmingCharacters(in: .whitespacesAndNewlines)
            if !h.isEmpty { return "https://\(h)" }
        }
        if let h = appSecrets["SUPABASE_URL_HOST"]?.trimmingCharacters(in: .whitespacesAndNewlines), !h.isEmpty {
            return "https://\(h)"
        }
        return nil
    }

    /// Publishable key (`sb_publishable_…`) or legacy anon JWT; never use `sb_secret_…` or `service_role` in the app.
    static var supabaseAnonKey: String? {
        let fromInfo = (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String)
        if let k = fromInfo?.trimmingCharacters(in: .whitespacesAndNewlines), !k.isEmpty { return k }
        if let k = appSecrets["SUPABASE_PUBLISHABLE_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines), !k.isEmpty { return k }
        if let k = appSecrets["SUPABASE_ANON_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines), !k.isEmpty { return k }
        return nil
    }

    static var analyzeMealPath: String {
        (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANALYZE_MEAL_PATH") as? String)
            ?? "functions/v1/analyze-meal"
    }

    /// RevenueCat public SDK key (same app). Omit or placeholder to run without StoreKit / dashboard.
    static var revenueCatAPIKey: String? {
        if let k = appSecrets["REVENUECAT_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines), !k.isEmpty { return k }
        if let k = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String,
           !k.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return k.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    /// Must match the entitlement identifier in RevenueCat (Glu Gold).
    static var revenueCatEntitlementId: String {
        if let k = appSecrets["REVENUECAT_ENTITLEMENT_ID"]?.trimmingCharacters(in: .whitespacesAndNewlines), !k.isEmpty {
            return k
        }
        if let k = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_ENTITLEMENT_ID") as? String,
           !k.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return k.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Glu Gold"
    }

    /// Shared anon-key client for auth + PostgREST. Nil when URL/key missing (mock / offline).
    static func makeSupabaseClient() -> SupabaseClient? {
        guard
            let raw = supabaseURL?.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            let url = URL(string: raw),
            let key = supabaseAnonKey,
            !key.isEmpty
        else { return nil }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}

/// Public legal URLs for in-app links (`legal/privacy-policy.md`, App Store Connect).
enum AppLegalLinks {
    /// Live privacy policy for Glu AI.
    static let privacyPolicy = URL(string: "https://hard75.com/glu-ai/privacy-policy")!
    /// Apple’s standard license for auto‑renewable subscriptions until a dedicated Glu terms page is published.
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}

enum MealAnalyzeError: LocalizedError {
    case noURL
    case badStatus(Int)
    case decode

    var errorDescription: String? {
        switch self {
        case .noURL:
            return "Missing Supabase URL. Check AppSecrets.plist."
        case .badStatus(let code):
            if code == 401 {
                return "Meal analysis was unauthorized (401). Redeploy the analyze-meal function with verify_jwt disabled for publishable keys, or check your publishable key in AppSecrets."
            }
            return "Could not analyze meal (HTTP \(code))."
        case .decode:
            return "Could not read the analysis response."
        }
    }
}

/// Calm, PRD-aligned copy for meal analysis failures (`screens_updated.md` §19). Prefer over `localizedDescription` in UI.
enum GluMealAnalysisUserCopy {
    static let analysisFailed = "We couldn’t analyze this photo. Try a clearer image or choose another one."
    static let connectionFailed = "We couldn’t reach Glu right now. Check your connection and try again."
    static let lowConfidenceEstimate = "I’m not fully sure about this estimate. You can adjust it before saving."
    static let noFoodDetected = "I couldn’t clearly identify the meal. Try another angle with the food centered."

    static func message(for error: Error) -> String {
        if let urlErr = error as? URLError {
            switch urlErr.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost,
                 .cannotFindHost, .timedOut, .dnsLookupFailed, .internationalRoamingOff,
                 .dataNotAllowed:
                return connectionFailed
            default:
                break
            }
        }
        if let meal = error as? MealAnalyzeError {
            switch meal {
            case .badStatus(let code):
                if (500 ... 599).contains(code) { return connectionFailed }
                return analysisFailed
            case .decode, .noURL:
                return analysisFailed
            }
        }
        return analysisFailed
    }
}

@MainActor
@Observable
final class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// POST image to Edge Function; falls back to mock when `SUPABASE_URL` unset (`prd-glu-ai/ai.md`).
    func analyzeMeal(imageJPEG: Data, userId: String, accessToken: String?) async throws -> MealAIOutput {
        guard let rawBase = APIConfig.supabaseURL?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) else {
            try await Task.sleep(nanoseconds: 400_000_000)
            return .mock()
        }
        let pathPart = APIConfig.analyzeMealPath.hasPrefix("/")
            ? APIConfig.analyzeMealPath
            : "/" + APIConfig.analyzeMealPath
        guard let functionURL = URL(string: rawBase + pathPart) else {
            throw MealAnalyzeError.noURL
        }

        var req = URLRequest(url: functionURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let key = APIConfig.supabaseAnonKey {
            req.setValue(key, forHTTPHeaderField: "apikey")
        }
        if let t = accessToken {
            req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        } else if let key = APIConfig.supabaseAnonKey {
            // Publishable key must match `apikey`; Bearer duplicates it for gateways that expect Authorization (not a JWT).
            req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        let b64 = imageJPEG.base64EncodedString()
        let body: [String: Any] = [
            "image_base64": b64,
            "user_id": userId,
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, res) = try await session.data(for: req)
        guard let http = res as? HTTPURLResponse else { throw MealAnalyzeError.badStatus(-1) }
        guard (200 ..< 300).contains(http.statusCode) else { throw MealAnalyzeError.badStatus(http.statusCode) }
        do {
            return try JSONDecoder().decode(MealAIOutput.self, from: data)
        } catch {
            // Some functions wrap payload as { "data": { ...schema } }
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let inner = obj["data"] as? [String: Any],
               let innerData = try? JSONSerialization.data(withJSONObject: inner) {
                return try JSONDecoder().decode(MealAIOutput.self, from: innerData)
            }
            throw MealAnalyzeError.decode
        }
    }
}

// MARK: - Auth (`prd-glu-ai/auth.md`)

@MainActor
@Observable
final class AuthController {
    var isSignedIn: Bool = false
    var userId: String?
    var displayName: String?
    /// JWT for Supabase Edge (`Authorization: Bearer`).
    var accessToken: String?
    /// From `user_staff_roles`; assign only in Supabase SQL.
    var staffRole: StaffRole?

    private weak var supabaseRef: SupabaseClient?

    func attachSupabase(_ client: SupabaseClient?) {
        supabaseRef = client
    }

    func applySupabaseSession(_ session: Session, preferredDisplayName: String? = nil) {
        isSignedIn = true
        userId = session.user.id.uuidString
        accessToken = session.accessToken
        if let p = preferredDisplayName, !p.isEmpty {
            displayName = p
        } else {
            displayName = session.user.email
        }
    }

    func setMockSession(userId: String, displayName: String? = nil) {
        isSignedIn = true
        self.userId = userId
        self.displayName = displayName
        accessToken = nil
        staffRole = nil
    }

    func fetchStaffRoleIfNeeded() async {
        guard let client = supabaseRef, let uidStr = userId, let uid = UUID(uuidString: uidStr) else {
            staffRole = nil
            return
        }
        staffRole = await StaffRoleService.fetchStaffRole(client: client, userId: uid)
    }

    func signOut() {
        isSignedIn = false
        userId = nil
        displayName = nil
        accessToken = nil
        staffRole = nil
    }

    /// Ends Supabase session then clears local auth state.
    func signOutFromSupabase() async {
        if let client = supabaseRef {
            try? await client.auth.signOut()
        }
        signOut()
    }
}

// MARK: - Subscriptions (RevenueCat — see `RevenueCatSubscriptionService.swift`)

@MainActor
protocol SubscriptionControlling: AnyObject {
    var isPremium: Bool { get }
    var isInTrialPeriod: Bool { get }
    func restorePurchases() async throws
    func preparePaywall() async
    func purchaseSelectedPlan(annualPreferred: Bool) async throws
}

extension SubscriptionControlling {
    var isInTrialPeriod: Bool { false }
}

// MARK: - Meal analysis gateway

@MainActor
@Observable
final class AIGatewayService {
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func analyzeMealPhoto(jpegData: Data, userId: String, accessToken: String?) async throws -> MealAIOutput {
        try await api.analyzeMeal(imageJPEG: jpegData, userId: userId, accessToken: accessToken)
    }
}

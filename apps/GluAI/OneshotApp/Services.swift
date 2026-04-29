import Foundation
import Observation

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
}

enum MealAnalyzeError: Error {
    case noURL
    case badStatus(Int)
    case decode
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
            // Edge `verify_jwt` accepts the project anon JWT when no user session exists yet.
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

    func setSession(userId: String, displayName: String? = nil) {
        isSignedIn = true
        self.userId = userId
        self.displayName = displayName
    }

    func signOut() {
        isSignedIn = false
        userId = nil
        displayName = nil
    }
}

// MARK: - Subscriptions (RevenueCat + Superwall — stub until dashboards wired)

@MainActor
protocol SubscriptionControlling: AnyObject {
    var isPremium: Bool { get }
    func restorePurchases() async throws
    func preparePaywall() async
    func purchaseSelectedPlan() async throws
}

@MainActor
@Observable
final class LocalSubscriptionService: SubscriptionControlling {
    var isPremium: Bool = false

    func restorePurchases() async throws {}

    func preparePaywall() async {}

    /// Dev / until RevenueCat: flips premium for funnel testing.
    func purchaseSelectedPlan() async throws {
        isPremium = true
    }
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

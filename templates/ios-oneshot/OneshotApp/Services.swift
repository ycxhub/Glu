import Foundation
import Observation

// MARK: - Analytics (replace Mixpanel; keep protocol for tests)

protocol AnalyticsService: AnyObject {
    func track(_ name: String, properties: [String: String]?)
}

@Observable
final class NoopAnalytics: AnalyticsService {
    func track(_ name: String, properties: [String: String]?) {
        #if DEBUG
        print("analytics: \(name)", properties ?? [:])
        #endif
    }
}

// MARK: - API (Supabase + Edge Function proxy) — no LLM API keys in the app

enum APIConfig {
    /// Set `SUPABASE_URL` in build settings or Info.plist for real calls.
    static var supabaseURL: URL? {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else { return nil }
        return URL(string: s)
    }
}

struct AIAnalyzeRequest: Encodable {
    let inputText: String?
    let imageBase64: String?
    let userId: String
}

struct AIAnalyzeResponse: Decodable {
    let resultJSON: [String: String]?
    let model: String?
}

/// Calls your Edge Function from `architecture.md` / `ai.md` — no OpenAI keys in the binary.
@MainActor
@Observable
final class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func postAIAnalyze(_ body: AIAnalyzeRequest) async throws -> AIAnalyzeResponse {
        if APIConfig.supabaseURL == nil {
            return AIAnalyzeResponse(
                resultJSON: ["message": "mock — set SUPABASE_URL in build settings for real proxy"],
                model: "template-mock"
            )
        }
        throw URLError(.badURL) // TODO(oneshot): Supabase function + JWT
    }
}

// MARK: - Auth (Sign in with Apple + Google + Supabase — see README)

@MainActor
@Observable
final class AuthController {
    var isSignedIn: Bool = false
    var userId: String?

    /// Replace with `ASAuthorizationController` + `supabase.auth.signInWithIdToken` when the SDK is added.
    func signInWithApplePlaceholder() {
        isSignedIn = true
        userId = "mock-" + String(UUID().uuidString.prefix(8))
    }

    func signOut() {
        isSignedIn = false
        userId = nil
    }
}

// MARK: - Subscriptions (RevenueCat + Superwall; protocol + local stub — add SDKs per PRD)

@MainActor
protocol SubscriptionControlling: AnyObject {
    var isPremium: Bool { get }
    func restorePurchases() async throws
    func preparePaywall() async
}

@MainActor
@Observable
final class LocalSubscriptionService: SubscriptionControlling {
    var isPremium: Bool = false

    func restorePurchases() async throws { }

    func preparePaywall() async { }
}

@MainActor
@Observable
final class AIGatewayService {
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func processPhotoPlaceholder(userId: String) async -> String? {
        let res = try? await api.postAIAnalyze(
            AIAnalyzeRequest(inputText: nil, imageBase64: nil, userId: userId)
        )
        return res?.resultJSON?["message"]
    }
}

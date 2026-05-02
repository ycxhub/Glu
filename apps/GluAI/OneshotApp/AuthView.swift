import AuthenticationServices
import CryptoKit
import Security
import SwiftUI
import Supabase

struct AuthView: View {
    @Bindable var auth: AuthController
    var supabase: SupabaseClient?
    var analytics: NoopAnalytics
    var onComplete: () -> Void
    @State private var err: String?
    @State private var currentNonce: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Save your plan")
                .font(AppTheme.Typography.title)
            Text("Sign in with Apple to keep your personalized plan and meal history synced across devices.")
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let e = err {
                Text(e).font(AppTheme.Typography.footnote).foregroundStyle(AppTheme.error)
            }

            SignInWithAppleButton(.signIn) { request in
                let nonce = Self.randomNonce()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = Self.sha256(nonce)
            } onCompletion: { result in
                Task { await handleAppleResult(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 24)

            #if DEBUG
            Button("Continue with Google (wire SDK)") {
                err = "Add Google Sign-In + Supabase per auth.md"
            }
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.brand)

            Button("Use mock account (simulator)") {
                err = nil
                let id = "mock-" + String(UUID().uuidString.prefix(8))
                auth.setMockSession(userId: id, displayName: "Preview User")
                analytics.track("auth_completed", properties: ["method": "mock"])
                onComplete()
            }
            .font(AppTheme.Typography.footnote)
            .foregroundStyle(AppTheme.secondaryLabel)
            #endif

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .onAppear {
            analytics.track("auth_started", properties: nil)
        }
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .failure(let error):
            await MainActor.run {
                err = error.localizedDescription
                analytics.track("auth_failed", properties: ["reason": "apple"])
            }
        case .success(let authorization):
            guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential else {
                await MainActor.run {
                    err = "Unexpected credential type."
                    analytics.track("auth_failed", properties: ["reason": "credential"])
                }
                return
            }
            let appleName = [cred.fullName?.givenName, cred.fullName?.familyName]
                .compactMap(\.self)
                .joined(separator: " ")
            guard let tokenData = cred.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8)
            else {
                await MainActor.run {
                    err = "Missing identity token from Apple."
                    analytics.track("auth_failed", properties: ["reason": "token"])
                }
                return
            }
            guard let client = supabase else {
                await MainActor.run {
                    auth.setMockSession(
                        userId: cred.user,
                        displayName: appleName.isEmpty ? nil : appleName
                    )
                    err = "Supabase not configured — using Apple user id locally only."
                    analytics.track("auth_completed", properties: ["method": "apple_local"])
                    onComplete()
                }
                return
            }
            let nonce = currentNonce
            await MainActor.run { err = nil }
            do {
                let session = try await client.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .apple,
                        idToken: idToken,
                        nonce: nonce
                    )
                )
                await MainActor.run {
                    auth.applySupabaseSession(
                        session,
                        preferredDisplayName: appleName.isEmpty ? nil : appleName
                    )
                    analytics.track("auth_completed", properties: ["method": "apple"])
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    err = error.localizedDescription
                    analytics.track("auth_failed", properties: ["reason": "supabase"])
                }
            }
        }
    }

    private static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private static func randomNonce(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        precondition(SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}

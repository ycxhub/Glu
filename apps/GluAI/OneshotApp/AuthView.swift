import AuthenticationServices
import SwiftUI

struct AuthView: View {
    @Bindable var auth: AuthController
    var onComplete: (String) -> Void
    @State private var err: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Save your plan")
                .font(AppTheme.Typography.title)
            Text("Create an account to sync meals and streaks across devices. Wire Supabase `signInWithIdToken` when the SDK is added.")
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let e = err {
                Text(e).font(AppTheme.Typography.footnote).foregroundStyle(AppTheme.error)
            }

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let cred = authorization.credential as? ASAuthorizationAppleIDCredential {
                        let id = cred.user
                        let name = [cred.fullName?.givenName, cred.fullName?.familyName]
                            .compactMap(\.self)
                            .joined(separator: " ")
                        auth.setSession(userId: id, displayName: name.isEmpty ? nil : name)
                        onComplete(id)
                    } else {
                        err = "Unexpected credential type."
                    }
                case .failure(let error):
                    err = error.localizedDescription
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 24)

            Button("Continue with Google (wire SDK)") {
                err = "Add Google Sign-In + Supabase per auth.md"
            }
            .font(AppTheme.Typography.subhead)
            .foregroundStyle(AppTheme.brand)

            Button("Use mock account (simulator)") {
                err = nil
                let id = "mock-" + String(UUID().uuidString.prefix(8))
                auth.setSession(userId: id, displayName: "Preview User")
                onComplete(id)
            }
            .font(AppTheme.Typography.footnote)
            .foregroundStyle(AppTheme.secondaryLabel)

            Spacer()
        }
        .padding()
    }
}

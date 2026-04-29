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
            Text("Create an account to sync. Replace with real Sign in with Apple + Supabase.")
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.secondaryLabel)
                .multilineTextAlignment(.center)
            if let e = err {
                Text(e).font(.caption).foregroundStyle(AppTheme.error)
            }
            Button {
                err = nil
                auth.signInWithApplePlaceholder()
                if let id = auth.userId {
                    onComplete(id)
                }
            } label: {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Continue (placeholder)")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            Spacer()
        }
        .padding()
    }
}

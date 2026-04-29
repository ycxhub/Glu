import SwiftUI

struct PaywallView: View {
    @Bindable var sub: LocalSubscriptionService
    var onUnlocked: () -> Void
    @State private var isRestoring = false
    @State private var err: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Start your 3-day trial")
                    .font(AppTheme.Typography.title)
                Text("Hard paywall placeholder — add RevenueCat + Superwall per paywall.md.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.surface)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best value")
                            .font(.caption2.weight(.semibold))
                            .padding(6)
                            .background(AppTheme.brand.opacity(0.2))
                            .clipShape(Capsule())
                        Text("Annual")
                            .font(.headline)
                        Text("$59.99 / year (example)")
                            .font(AppTheme.Typography.subhead)
                    }
                    .padding(20)
                }
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                if let e = err {
                    Text(e).font(.caption).foregroundStyle(AppTheme.error)
                }
                Button {
                    onUnlocked()
                } label: {
                    Text("Start free trial (dev)")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
                Button("Restore purchases") {
                    isRestoring = true
                    Task { @MainActor in
                        do {
                            try await sub.restorePurchases()
                        } catch {
                            err = error.localizedDescription
                        }
                        isRestoring = false
                    }
                }
                .font(.subheadline)
                .disabled(isRestoring)
                Spacer(minLength: 20)
            }
            .padding(24)
        }
    }
}

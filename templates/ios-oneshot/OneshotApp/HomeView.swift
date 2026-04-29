import SwiftUI

struct HomeView: View {
    var userId: String?
    var onOpenCore: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today")
                    .font(AppTheme.Typography.title)
                if let u = userId {
                    Text("User: \(u)")
                        .font(AppTheme.Typography.subhead)
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.surface)
                    .frame(height: 160)
                    .overlay {
                        VStack(alignment: .leading) {
                            Text("0")
                                .font(AppTheme.Typography.display)
                            Text("Hero metric (from app.md)")
                                .font(AppTheme.Typography.subhead)
                                .foregroundStyle(AppTheme.secondaryLabel)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(24)
                    }
                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

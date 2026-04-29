import SwiftUI

/// Design tokens — map from `prd-*/design.md` during oneshot-ios-implement.
enum AppTheme {
    static let brand = Color(red: 0.18, green: 0.72, blue: 0.55)
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let error = Color(.systemRed)

    struct Typography {
        static let display = Font.system(size: 48, weight: .bold, design: .default)
        static let title = Font.system(size: 28, weight: .bold)
        static let body = Font.system(size: 17, weight: .regular)
        static let subhead = Font.system(size: 15, weight: .regular)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.brand)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

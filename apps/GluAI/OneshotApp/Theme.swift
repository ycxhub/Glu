import SwiftUI
import UIKit

/// Glu AI tokens from `prd-glu-ai/design.md`.
enum AppTheme {
    static let brand = Color(red: 10 / 255, green: 122 / 255, blue: 106 / 255)
    static let brandMuted = Color(red: 230 / 255, green: 245 / 255, blue: 243 / 255)
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let error = Color(.systemRed)
    static let spikeLow = Color(red: 48 / 255, green: 209 / 255, blue: 88 / 255)
    static let spikeMedium = Color(red: 255 / 255, green: 159 / 255, blue: 10 / 255)
    static let spikeHigh = Color(red: 255 / 255, green: 69 / 255, blue: 58 / 255)

    struct Typography {
        static let display = Font.system(size: 48, weight: .bold, design: .default)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let subhead = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 11, weight: .regular)
    }

    static func spikeColor(for risk: String) -> Color {
        switch risk.lowercased() {
        case "low": return spikeLow
        case "high": return spikeHigh
        default: return spikeMedium
        }
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

struct SpikeRiskPill: View {
    let risk: String

    var body: some View {
        Text(risk.capitalized)
            .font(AppTheme.Typography.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.spikeColor(for: risk).opacity(0.18))
            .foregroundStyle(AppTheme.spikeColor(for: risk))
            .clipShape(Capsule())
            .accessibilityLabel("Spike risk: \(risk)")
    }
}

struct MealResultDetailView: View {
    let entry: MealEntry
    var onDelete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                HStack {
                    Text("\(entry.output.calories) kcal")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.brand)
                    Spacer()
                    SpikeRiskPill(risk: entry.output.spikeRisk)
                }
                macroGrid(output: entry.output)
                Text(entry.output.rationale)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.label)
                Text(entry.output.disclaimer)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.secondaryLabel)
                Button("Delete meal", role: .destructive, action: onDelete)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .navigationTitle("Meal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func macroGrid(output: MealAIOutput) -> some View {
        let rows: [(String, String)] = [
            ("Carbs", String(format: "%.0f g", output.carbsG)),
            ("Fiber", String(format: "%.0f g", output.fiberG)),
            ("Sugar", String(format: "%.0f g", output.sugarG)),
            ("Protein", String(format: "%.0f g", output.proteinG)),
            ("Fat", String(format: "%.0f g", output.fatG)),
        ]
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, r in
                HStack {
                    Text(r.0).foregroundStyle(AppTheme.secondaryLabel)
                    Spacer()
                    Text(r.1).font(AppTheme.Typography.headline)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

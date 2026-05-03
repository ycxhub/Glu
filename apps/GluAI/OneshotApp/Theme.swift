import SwiftUI
import UIKit

// MARK: - Pastel Precision (`design.md` §§4–6)

private enum PastelHex {
    static let cream = UIColor(red: 1, green: 0.973, blue: 0.929, alpha: 1)
    static let powderBlue = UIColor(red: 0.918, green: 0.961, blue: 1, alpha: 1)
    static let softMint = UIColor(red: 0.918, green: 0.973, blue: 0.941, alpha: 1)
    static let warmIvory = UIColor(red: 1, green: 0.988, blue: 0.965, alpha: 1)
    static let calmTeal = UIColor(red: 10 / 255, green: 122 / 255, blue: 106 / 255, alpha: 1)
    static let paleTeal = UIColor(red: 0.902, green: 0.961, blue: 0.953, alpha: 1)
    static let seafoam = UIColor(red: 0.659, green: 0.902, blue: 0.812, alpha: 1)
    static let apricot = UIColor(red: 1, green: 0.827, blue: 0.714, alpha: 1)
    static let lemonChiffon = UIColor(red: 1, green: 0.957, blue: 0.722, alpha: 1)
    static let softPeach = UIColor(red: 1, green: 0.882, blue: 0.780, alpha: 1)
    static let lavender = UIColor(red: 0.851, green: 0.780, blue: 0.969, alpha: 1)
    static let periwinkle = UIColor(red: 0.749, green: 0.780, blue: 0.969, alpha: 1)
    static let blush = UIColor(red: 0.973, green: 0.784, blue: 0.863, alpha: 1)
    static let slatePlum = UIColor(red: 53 / 255, green: 49 / 255, blue: 69 / 255, alpha: 1)
    static let dustyLavender = UIColor(red: 122 / 255, green: 116 / 255, blue: 138 / 255, alpha: 1)
    static let mistDivider = UIColor(red: 0.918, green: 0.894, blue: 0.855, alpha: 1)
    static let mutedRose = UIColor(red: 0.851, green: 0.478, blue: 0.541, alpha: 1)
    static let spikeLow = UIColor(red: 111 / 255, green: 214 / 255, blue: 165 / 255, alpha: 1)
    static let spikeMedium = UIColor(red: 232 / 255, green: 169 / 255, blue: 77 / 255, alpha: 1)
    static let spikeHigh = UIColor(red: 217 / 255, green: 122 / 255, blue: 138 / 255, alpha: 1)

    // Dark (`design.md` §24) — quiet journal, not pure black
    static let darkBase = UIColor(red: 0.11, green: 0.10, blue: 0.14, alpha: 1)
    static let darkDashboard = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1)
    static let darkCard = UIColor(red: 0.16, green: 0.15, blue: 0.20, alpha: 1)
    static let darkLabel = UIColor(red: 0.94, green: 0.93, blue: 0.96, alpha: 1)
    static let darkSecondary = UIColor(red: 0.68, green: 0.65, blue: 0.76, alpha: 1)
}

enum AppTheme {
    enum Layout {
        static let screenPadding: CGFloat = 24
        static let cardPadding: CGFloat = 20
        static let cardRadius: CGFloat = 16
        static let buttonRadius: CGFloat = 14
        static let optionRowPadding: CGFloat = 16
        static let minTap: CGFloat = 44
        static let historyGridGap: CGFloat = 3
        static let historyCellRadius: CGFloat = 8
    }

    /// Calm teal — trust anchor, CTAs (`#0A7A6A`)
    static let brand = Color(PastelHex.calmTeal)
    static let brandMuted = Color(PastelHex.paleTeal)

    /// Cream / vanilla base (light), deep charcoal base (dark)
    static let background = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkBase : PastelHex.cream
        }
    )

    /// Home / Today atmosphere — powder blue (light), midnight blue (dark)
    static let dashboardSurface = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkDashboard : PastelHex.powderBlue
        }
    )

    /// Secondary wellness cards
    static let secondarySurface = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkCard : PastelHex.softMint
        }
    )

    /// Elevated cards, sheets
    static let cardElevated = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkCard : PastelHex.warmIvory
        }
    )

    /// Surface for rows / grouped content
    static let surface = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkCard : PastelHex.warmIvory
        }
    )

    /// Primary label — slate plum (light), cream/mist (dark); never pastel body
    static let label = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkLabel : PastelHex.slatePlum
        }
    )

    static let secondaryLabel = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark ? PastelHex.darkSecondary : PastelHex.dustyLavender
        }
    )

    static let divider = Color(
        uiColor: UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.12)
                : PastelHex.mistDivider
        }
    )

    /// Muted rose — true errors only (`#D97A8A`)
    static let error = Color(PastelHex.mutedRose)

    static let macroCarbs = Color(PastelHex.softPeach)
    static let macroProtein = Color(PastelHex.apricot)
    static let macroFat = Color(PastelHex.lemonChiffon)
    static let insightLavender = Color(PastelHex.lavender)
    static let celebrationBlush = Color(PastelHex.blush)
    static let seafoamAccent = Color(PastelHex.seafoam)
    static let periwinkleAccent = Color(PastelHex.periwinkle)

    static let spikeLow = Color(PastelHex.spikeLow)
    static let spikeMedium = Color(PastelHex.spikeMedium)
    static let spikeHigh = Color(PastelHex.spikeHigh)

    struct Typography {
        /// Large stats — tracks Dynamic Type via `largeTitle` metrics (design target ~48 pt).
        static var display: Font {
            let pt = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: 48)
            return Font.system(size: pt, weight: .bold, design: .default)
        }
        static let title = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let subhead = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
    }

    static func spikeColor(for risk: String) -> Color {
        switch risk.lowercased() {
        case "low": return spikeLow
        case "high": return spikeHigh
        default: return spikeMedium
        }
    }

    /// Readable `secondaryLabel` on top of spike pill backgrounds (small pills only).
    static func spikePillForeground(for risk: String) -> Color {
        switch risk.lowercased() {
        case "low": return Color(PastelHex.slatePlum)
        case "high": return Color(PastelHex.slatePlum)
        default: return Color(PastelHex.slatePlum)
        }
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppTheme.Layout.minTap)
            .padding(.vertical, 14)
            .background(AppTheme.brand)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

/// Dominant camera CTA (Log tab)
struct CameraHeroButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(AppTheme.brand)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
            .shadow(
                color: AppTheme.brand.opacity(reduceMotion ? 0 : 0.25),
                radius: reduceMotion ? 0 : 8,
                y: reduceMotion ? 0 : 4
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

/// Secondary library action — outline / subdued
struct LibrarySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.subhead.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppTheme.Layout.minTap)
            .background(AppTheme.surface)
            .foregroundStyle(AppTheme.label)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Spike pill (small semantic signal — not full-screen alarm)

struct SpikeRiskPill: View {
    let risk: String

    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var pillBackgroundOpacity: Double {
        if reduceTransparency { return 0.4 }
        return contrast == .increased ? 0.32 : 0.22
    }

    var body: some View {
        let labelText = risk.capitalized
        Text(labelText)
            .font(AppTheme.Typography.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.spikeColor(for: risk).opacity(pillBackgroundOpacity))
            .foregroundStyle(AppTheme.spikePillForeground(for: risk))
            .clipShape(Capsule())
            .accessibilityLabel("Spike-risk estimate: \(labelText). Educational estimate only.")
    }
}

// MARK: - Meal detail (shared layout stub — extended in meal flow files as needed)

struct MealResultDetailView: View {
    let entry: MealEntry
    var onDelete: () -> Void
    var onEditEstimate: (() -> Void)?

    @State private var confirmDelete = false

    init(entry: MealEntry, onDelete: @escaping () -> Void, onEditEstimate: (() -> Void)? = nil) {
        self.entry = entry
        self.onDelete = onDelete
        self.onEditEstimate = onEditEstimate
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                }
                HStack {
                    Text("\(entry.output.calories) kcal")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.brand)
                    Spacer()
                    SpikeRiskPill(risk: entry.output.spikeRisk)
                }
                .accessibilityElement(children: .combine)
                macroGrid(output: entry.output)
                Text(entry.output.rationale)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.label)
                Text(entry.output.disclaimer)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.secondaryLabel)
                if let edit = onEditEstimate {
                    Button("Edit estimate", action: edit)
                        .buttonStyle(LibrarySecondaryButtonStyle())
                }
                Button("Delete meal", role: .destructive) {
                    confirmDelete = true
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppTheme.Layout.minTap)
            }
            .padding(AppTheme.Layout.screenPadding)
        }
        .navigationTitle("Meal")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this meal from your history?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        }
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
                    Text(r.1)
                        .font(AppTheme.Typography.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .padding(.horizontal, AppTheme.Layout.optionRowPadding)
                .padding(.vertical, 8)
                .background(Self.macroRowTint(for: r.0).opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
            }
        }
        .padding(AppTheme.Layout.optionRowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
    }

    private static func macroRowTint(for label: String) -> Color {
        switch label {
        case "Carbs": return AppTheme.macroCarbs
        case "Protein": return AppTheme.macroProtein
        case "Fat": return AppTheme.macroFat
        case "Fiber": return AppTheme.seafoamAccent
        case "Sugar": return AppTheme.insightLavender
        default: return AppTheme.divider
        }
    }
}

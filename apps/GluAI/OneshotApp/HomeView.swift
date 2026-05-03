import SwiftUI
import UIKit

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var meals: MealLogStore
    var userId: String?
    var displayName: String?

    @State private var selectedMeal: MealEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting())
                            .font(AppTheme.Typography.title2)
                            .foregroundStyle(AppTheme.secondaryLabel)
                        Text("Today")
                            .font(AppTheme.Typography.title)
                    }

                    if let free = freeAnalysesLine {
                        Text(free)
                            .font(AppTheme.Typography.subhead.weight(.medium))
                            .foregroundStyle(AppTheme.brand)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppTheme.Layout.optionRowPadding)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                            .accessibilityLabel("Free meal analyses remaining, \(appState.freeMealAnalysesRemaining) of 5")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(meals.streakDays)")
                                .font(AppTheme.Typography.display)
                                .foregroundStyle(AppTheme.brand)
                            Text("day streak")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.label)
                        }
                        Text("\(meals.todayMeals.count) meals logged today")
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.secondaryLabel)
                    }
                    .padding(AppTheme.Layout.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(meals.streakDays) day streak. \(meals.todayMeals.count) meals logged today.")

                    if !meals.todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's estimates")
                                .font(AppTheme.Typography.headline)
                            HStack(alignment: .firstTextBaseline, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(todayCalories)")
                                        .font(AppTheme.Typography.title)
                                        .foregroundStyle(AppTheme.label)
                                    Text("kcal \u{00b7} \(String(format: "%.0f", todayCarbs)) g carbs")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(AppTheme.secondaryLabel)
                                }
                                Spacer(minLength: 0)
                            }
                            spikeDistributionRow
                        }
                        .padding(AppTheme.Layout.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.dashboardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                    }

                    insightCard

                    Text("Recent")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.label)
                        .padding(.top, 8)

                    if meals.todayMeals.isEmpty && meals.hasLoadedOnce {
                        VStack(spacing: 16) {
                            Text("Log your first meal")
                                .font(AppTheme.Typography.title2)
                                .foregroundStyle(AppTheme.label)
                                .multilineTextAlignment(.center)
                            Text("Snap a photo and Glu will estimate calories, macros, and spike-risk context.")
                                .font(AppTheme.Typography.body)
                                .foregroundStyle(AppTheme.secondaryLabel)
                                .multilineTextAlignment(.center)
                            Button("Open Camera") {
                                appState.selectedMainTab = 1
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(AppTheme.Layout.cardPadding)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                    } else {
                        ForEach(meals.todayMeals.prefix(5)) { m in
                            Button {
                                selectedMeal = m
                            } label: {
                                MealRowCard(entry: m)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(AppTheme.Layout.screenPadding)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMeal) { entry in
                NavigationStack {
                    MealResultDetailView(
                        entry: entry,
                        onDelete: {
                            meals.delete(id: entry.id)
                            selectedMeal = nil
                        },
                        onEditEstimate: nil
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { selectedMeal = nil }
                        }
                    }
                }
            }
        }
    }

    private var spikeDistributionRow: some View {
        let c = spikeCounts
        return VStack(alignment: .leading, spacing: 8) {
            Text("Spike-risk labels today (educational)")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.secondaryLabel)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    spikeChip("Low", c.low, AppTheme.spikeLow)
                    spikeChip("Med", c.med, AppTheme.spikeMedium)
                    spikeChip("High", c.high, AppTheme.spikeHigh)
                }
                VStack(alignment: .leading, spacing: 8) {
                    spikeChip("Low", c.low, AppTheme.spikeLow)
                    spikeChip("Med", c.med, AppTheme.spikeMedium)
                    spikeChip("High", c.high, AppTheme.spikeHigh)
                }
            }
        }
    }

    private func spikeChip(_ label: String, _ count: Int, _ color: Color) -> some View {
        Text("\(label) · \(count)")
            .font(AppTheme.Typography.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.2))
            .foregroundStyle(AppTheme.label)
            .clipShape(Capsule())
            .accessibilityLabel("\(label) spike-risk label, \(count) meals logged today")
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insight")
                .font(AppTheme.Typography.headline)
            Text(insightText)
                .font(AppTheme.Typography.subhead)
                .foregroundStyle(AppTheme.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.insightLavender.opacity(colorScheme == .dark ? 0.22 : 0.35))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
    }

    private var todayCalories: Int {
        meals.todayMeals.reduce(0) { $0 + $1.output.calories }
    }

    private var todayCarbs: Double {
        meals.todayMeals.reduce(0) { $0 + $1.output.carbsG }
    }

    private var spikeCounts: (low: Int, med: Int, high: Int) {
        var l = 0, m = 0, h = 0
        for e in meals.todayMeals {
            switch e.output.spikeRisk.lowercased() {
            case "low": l += 1
            case "high": h += 1
            default: m += 1
            }
        }
        return (l, m, h)
    }

    private var insightText: String {
        guard let last = meals.meals.first else {
            return "Log a meal to see estimates and spike-risk context for your day — educational only, not medical advice."
        }
        return "Last save: about \(last.output.calories) kcal with a \(last.output.spikeRisk) spike-risk estimate. Review fiber and carbs in History anytime."
    }

    private func greeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        let sal = (h < 12) ? "Good morning" : ((h < 17) ? "Good afternoon" : "Good evening")
        if let n = displayName?.split(separator: " ").first {
            return "\(sal), \(n)"
        }
        return sal
    }

    private var freeAnalysesLine: String? {
        guard appState.choseFreeTier, !appState.isPremium else { return nil }
        let n = appState.freeMealAnalysesRemaining
        return "\(n) free meal analyses remaining"
    }
}

private struct MealRowCard: View {
    let entry: MealEntry

    private var combinedAccessibilityLabel: String {
        let rationale = entry.output.rationale
        let snippet = rationale.count > 160 ? String(rationale.prefix(160)) + "…" : rationale
        return "\(entry.output.calories) calories, \(entry.timeString). Spike-risk estimate: \(entry.output.spikeRisk). \(snippet)"
    }

    var body: some View {
        HStack(spacing: 12) {
            if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.output.calories) kcal · \(entry.timeString)")
                    .font(AppTheme.Typography.headline)
                Text(entry.output.rationale)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .lineLimit(2)
            }
            Spacer()
            SpikeRiskPill(risk: entry.output.spikeRisk)
        }
        .padding(AppTheme.Layout.optionRowPadding)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(combinedAccessibilityLabel)
        .accessibilityHint("Opens meal estimate")
        .accessibilityAddTraits(.isButton)
    }
}

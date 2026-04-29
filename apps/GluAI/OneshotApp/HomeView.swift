import SwiftUI
import UIKit

struct HomeView: View {
    @Bindable var meals: MealLogStore
    var userId: String?
    var displayName: String?

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

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(meals.streakDays)")
                                .font(AppTheme.Typography.display)
                                .foregroundStyle(AppTheme.brand)
                            Text("day logging streak")
                                .font(AppTheme.Typography.subhead)
                                .foregroundStyle(AppTheme.secondaryLabel)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(meals.todayMeals.count)")
                                .font(AppTheme.Typography.display)
                                .foregroundStyle(AppTheme.label)
                            Text("meals today")
                                .font(AppTheme.Typography.subhead)
                                .foregroundStyle(AppTheme.secondaryLabel)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Text("Recent")
                        .font(AppTheme.Typography.title2)

                    if meals.todayMeals.isEmpty {
                        Text("Log your first meal from the Log tab.")
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.secondaryLabel)
                    } else {
                        ForEach(meals.todayMeals.prefix(5)) { m in
                            MealRowCard(entry: m)
                        }
                    }
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func greeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        let sal = (h < 12) ? "Good morning" : ((h < 17) ? "Good afternoon" : "Good evening")
        if let n = displayName?.split(separator: " ").first {
            return "\(sal), \(n)"
        }
        return sal
    }
}

private struct MealRowCard: View {
    let entry: MealEntry

    var body: some View {
        HStack(spacing: 12) {
            if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

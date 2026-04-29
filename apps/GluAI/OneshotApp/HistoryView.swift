import SwiftUI
import UIKit

struct HistoryView: View {
    @Bindable var meals: MealLogStore
    @State private var selected: MealEntry?

    var body: some View {
        NavigationStack {
            Group {
                if meals.meals.isEmpty {
                    ContentUnavailableView(
                        "No meals yet",
                        systemImage: "clock",
                        description: Text("Saved meals from the Log tab appear here.")
                    )
                } else {
                    List {
                        ForEach(meals.meals) { m in
                            Button {
                                selected = m
                            } label: {
                                HistoryRow(entry: m)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { idx in
                            for i in idx {
                                meals.delete(id: meals.meals[i].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $selected) { entry in
                NavigationStack {
                    MealResultDetailView(entry: entry, onDelete: {
                        meals.delete(id: entry.id)
                        selected = nil
                    })
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { selected = nil }
                        }
                    }
                }
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: MealEntry

    var body: some View {
        HStack(spacing: 12) {
            if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.brandMuted)
                    .frame(width: 56, height: 56)
                    .overlay { Image(systemName: "photo").foregroundStyle(AppTheme.brand) }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.output.calories) kcal")
                    .font(AppTheme.Typography.headline)
                Text(entry.timeString)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
            }
            Spacer()
            SpikeRiskPill(risk: entry.output.spikeRisk)
        }
        .padding(.vertical, 4)
    }
}

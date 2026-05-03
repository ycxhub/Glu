import SwiftUI
import UIKit

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Bindable var meals: MealLogStore
    @State private var selected: MealEntry?
    @State private var entryToEdit: MealEntry?

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Layout.historyGridGap),
        GridItem(.flexible(), spacing: AppTheme.Layout.historyGridGap),
        GridItem(.flexible(), spacing: AppTheme.Layout.historyGridGap),
    ]

    var body: some View {
        NavigationStack {
            Group {
                if meals.meals.isEmpty && meals.hasLoadedOnce {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("Your meal story starts here")
                            .font(AppTheme.Typography.title2)
                            .foregroundStyle(AppTheme.label)
                            .multilineTextAlignment(.center)
                        Text("Snap your next meal and we'll keep a private, spike-smart history right here.")
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Layout.screenPadding)
                        Button("Log your first meal") {
                            appState.selectedMainTab = 1
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: AppTheme.Layout.historyGridGap) {
                            ForEach(meals.meals) { m in
                                HistoryGridCell(entry: m) {
                                    selected = m
                                }
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        meals.delete(id: m.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $selected) { entry in
                NavigationStack {
                    MealResultDetailView(
                        entry: entry,
                        onDelete: {
                            meals.delete(id: entry.id)
                            selected = nil
                        },
                        onEditEstimate: {
                            entryToEdit = entry
                            selected = nil
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { selected = nil }
                        }
                    }
                }
            }
            .sheet(item: $entryToEdit) { ent in
                NavigationStack {
                    GluMealEstimateSheet(
                        snapshot: ent.output,
                        envelope: ent.envelope,
                        imageData: ent.thumbnailData,
                        onSave: { out in
                            Task {
                                let merged = ent.envelope?.updatingUserEstimate(out)
                                    ?? GluMealEnvelope.legacy(from: out)
                                let updated = MealEntry(
                                    id: ent.id,
                                    createdAt: ent.createdAt,
                                    thumbnailData: ent.thumbnailData,
                                    output: out,
                                    envelope: merged
                                )
                                await meals.replaceEntry(updated)
                            }
                            entryToEdit = nil
                        },
                        onDiscard: {
                            entryToEdit = nil
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { entryToEdit = nil }
                        }
                    }
                }
            }
        }
    }
}

private struct HistoryGridCell: View {
    let entry: MealEntry
    var onTap: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    private var spikeLetter: String {
        switch entry.output.spikeRisk.lowercased() {
        case "low": return "L"
        case "high": return "H"
        default: return "M"
        }
    }

    var body: some View {
        Button(action: onTap) {
            GeometryReader { geo in
                let side = geo.size.width
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let d = entry.thumbnailData, let ui = UIImage(data: d) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Rectangle()
                                .fill(AppTheme.brandMuted)
                                .overlay { Image(systemName: "photo").foregroundStyle(AppTheme.brand).accessibilityHidden(true) }
                        }
                    }
                    .frame(width: side, height: side)
                    .clipped()

                    Group {
                        if reduceTransparency {
                            Color.black.opacity(contrast == .increased ? 0.52 : 0.45)
                                .frame(width: side, height: side)
                        } else {
                            LinearGradient(
                                colors: [.black.opacity(0.55), .clear],
                                startPoint: .bottom,
                                endPoint: .center
                            )
                            .frame(width: side, height: side)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(entry.output.calories)")
                            .font(AppTheme.Typography.caption.weight(.bold))
                            .foregroundStyle(.white)
                        HStack(spacing: 4) {
                            Text(spikeLetter)
                                .font(AppTheme.Typography.caption.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.black.opacity(reduceTransparency ? 0.5 : 0.35)))
                            Text("spike")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding(8)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.historyCellRadius, style: .continuous))
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(entry.output.calories) calories, spike-risk estimate \(entry.output.spikeRisk), logged \(entry.timeString)"
        )
    }
}

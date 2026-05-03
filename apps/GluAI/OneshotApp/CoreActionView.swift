import SwiftUI
import PhotosUI
import UIKit

private struct MealEstimateSession: Identifiable {
    let id = UUID()
    var output: MealAIOutput
    var envelope: GluMealEnvelope?
    let imageData: Data?
    /// When set, `meal_logs` row already exists on the server (finalize RPC).
    let serverMealId: UUID?
    let serverRowExists: Bool
    let chargedAnalysis: Bool
}

struct CoreActionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var api: APIClient
    @Bindable var auth: AuthController
    @Bindable var subs: RevenueCatSubscriptionService
    var analytics: NoopAnalytics
    @Bindable var meals: MealLogStore

    @State private var pickerItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var busy = false
    @State private var previewImage: UIImage?
    @State private var statusRotateIndex = 0
    @State private var estimateSession: MealEstimateSession?
    @State private var err: String?

    private let analyzingLines = [
        "Reading your plate…",
        "Estimating portions…",
        "Approximating carbs and calories…",
        "Scoring spike-risk (educational only)…",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Log a meal")
                    .font(AppTheme.Typography.title)
                Text(
                    "Pick or snap a photo. Glu AI returns a spike-risk estimate and nutrition guesses — educational only, not medical advice."
                )
                .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)

                if let freeLine = freeAnalysesLabel {
                    Text(freeLine)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.brand)
                        .accessibilityLabel("Free meal analyses remaining, \(appState.freeMealAnalysesRemaining) of 5")
                }

                if !canAnalyze {
                    VStack(spacing: 12) {
                        Text("You've used your 5 free meal analyses.")
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.label)
                            .multilineTextAlignment(.center)
                        Button("Continue with Glu Gold") {
                            appState.refreshPhaseForAccess(
                                staffRole: auth.staffRole,
                                subscriptionAllowsAccess: subs.isPremium
                            )
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(AppTheme.Layout.cardPadding)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                }

                VStack(spacing: 12) {
                    Button {
                        beginCaptureCamera()
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CameraHeroButtonStyle())
                    .disabled(!canAnalyze || busy)
                    .accessibilityLabel("Camera")
                    .accessibilityHint("Take a new meal photo")

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Photo library", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LibrarySecondaryButtonStyle())
                    .disabled(!canAnalyze || busy)
                    .accessibilityLabel("Photo library")
                    .accessibilityHint("Choose an existing meal photo")
                }

                if busy {
                    VStack(spacing: 16) {
                        if let img = previewImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                        }
                        ProgressView()
                            .tint(AppTheme.brand)
                        Text(analyzingLines[statusRotateIndex % analyzingLines.count])
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: statusRotateIndex)
                    }
                    .onAppear {
                        statusRotateIndex = 0
                    }
                    .task(id: busy) {
                        guard busy else { return }
                        while !Task.isCancelled {
                            try? await Task.sleep(nanoseconds: 2_400_000_000)
                            await MainActor.run {
                                statusRotateIndex += 1
                            }
                        }
                    }
                }

                if let e = err {
                    Text(e)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.error)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
            }
            .padding(AppTheme.Layout.screenPadding)
            .navigationTitle("Log")
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, img in
                guard let img else { return }
                Task { await runAnalyze(image: img) }
            }
            .onChange(of: pickerItem) { _, new in
                Task { await loadPicker(new) }
            }
            .sheet(item: $estimateSession) { session in
                NavigationStack {
                    GluMealEstimateSheet(
                        snapshot: session.output,
                        envelope: session.envelope,
                        imageData: session.imageData,
                        onSave: { saved in
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            let mergedEnv = session.envelope?.updatingUserEstimate(saved)
                                ?? GluMealEnvelope.legacy(from: saved)
                            let thumb = session.imageData.flatMap { UIImage(data: $0)?.jpegData(compressionQuality: 0.5) }
                            let entry = MealEntry(
                                id: session.serverMealId ?? UUID(),
                                createdAt: Date(),
                                thumbnailData: thumb,
                                output: saved,
                                envelope: mergedEnv
                            )
                            if session.serverRowExists {
                                meals.add(entry)
                                Task { await meals.replaceEntry(entry) }
                            } else {
                                meals.add(entry)
                                Task { await meals.persistInsert(entry) }
                            }
                            analytics.track("meal_saved", properties: ["spike": saved.spikeRisk])
                            estimateSession = nil
                        },
                        onDiscard: {
                            if let sid = session.serverMealId {
                                Task { await meals.deleteServerOnly(id: sid) }
                            }
                            estimateSession = nil
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { estimateSession = nil }
                                .accessibilityHint("Dismisses the estimate without saving")
                        }
                    }
                }
            }
            .onAppear {
                appState.refreshPhaseForAccess(
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
            }
        }
    }

    private var canAnalyze: Bool {
        appState.canStartNewMealAnalysis(staffRole: auth.staffRole, subscriptionAllowsAccess: subs.isPremium)
    }

    private var freeAnalysesLabel: String? {
        guard appState.choseFreeTier, !appState.isPremium else { return nil }
        let left = appState.freeMealAnalysesRemaining
        return "\(left) free meal analyses left"
    }

    private func beginCaptureCamera() {
        guard canAnalyze else {
            appState.refreshPhaseForAccess(
                staffRole: auth.staffRole,
                subscriptionAllowsAccess: subs.isPremium
            )
            return
        }
        showCamera = true
    }

    private func loadPicker(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard canAnalyze else {
            await MainActor.run {
                appState.refreshPhaseForAccess(
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
            }
            return
        }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let ui = UIImage(data: data) else { return }
        await runAnalyze(image: ui)
    }

    private func runAnalyze(image: UIImage) async {
        guard canAnalyze else {
            await MainActor.run {
                appState.refreshPhaseForAccess(
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
            }
            return
        }

        guard let jpeg = gluJPEGDataForAnalysis(image) else {
            await MainActor.run { err = GluMealAnalysisUserCopy.analysisFailed }
            return
        }
        let idempotencyKey = UUID().uuidString
        let installId = GluInstallId.string()
        await MainActor.run {
            showCamera = false
            busy = true
            err = nil
            previewImage = image
            statusRotateIndex = 0
            capturedImage = nil
            pickerItem = nil
        }
        analytics.track("meal_capture_started", properties: nil)
        analytics.track("meal_analysis_started", properties: nil)
        let gateway = AIGatewayService(api: api)
        do {
            let result = try await gateway.analyzeMealPhoto(
                jpegData: jpeg,
                accessToken: auth.accessToken,
                idempotencyKey: idempotencyKey,
                installId: installId
            )
            await MainActor.run {
                appState.applyMealAnalysisQuotaFromServer(
                    result.quota,
                    staffRole: auth.staffRole,
                    subscriptionAllowsAccess: subs.isPremium
                )
                let usedServerRemaining = result.quota?.ok == true && result.quota?.remainingFree != nil
                if !usedServerRemaining, result.charged {
                    appState.recordSuccessfulFreeTierAnalysis(
                        staffRole: auth.staffRole,
                        subscriptionAllowsAccess: subs.isPremium
                    )
                }
                let state = result.analysisState
                if state == "no_food" {
                    err = GluMealAnalysisUserCopy.noFoodDetected
                    busy = false
                    previewImage = nil
                    analytics.track("meal_analysis_no_food", properties: nil)
                    return
                }
                if state == "analysis_failed" {
                    err = GluMealAnalysisUserCopy.analysisFailed
                    busy = false
                    previewImage = nil
                    analytics.track("meal_analysis_failed", properties: ["state": state])
                    return
                }
                let env = result.envelope ?? GluMealEnvelope.legacy(from: result.userEstimate)
                let serverRow = result.mealId != nil
                estimateSession = MealEstimateSession(
                    output: result.userEstimate,
                    envelope: env,
                    imageData: jpeg,
                    serverMealId: result.mealId,
                    serverRowExists: serverRow,
                    chargedAnalysis: result.charged
                )
                busy = false
                previewImage = nil
                analytics.track("meal_analysis_completed", properties: [
                    "spike": result.userEstimate.spikeRisk,
                    "state": state,
                ])
            }
        } catch {
            await MainActor.run {
                err = GluMealAnalysisUserCopy.message(for: error)
                busy = false
                previewImage = nil
                analytics.track("meal_analysis_failed", properties: ["error": String(describing: error)])
            }
        }
    }
}

// MARK: - Image bounds (client-side downscale)

private func gluDownscaleImageForAnalysis(_ image: UIImage) -> UIImage {
    let maxSide: CGFloat = 1280
    let longest = max(image.size.width, image.size.height)
    guard longest > maxSide else { return image }
    let scale = maxSide / longest
    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    let r = UIGraphicsImageRenderer(size: newSize)
    return r.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

private func gluJPEGDataForAnalysis(_ image: UIImage) -> Data? {
    let img = gluDownscaleImageForAnalysis(image)
    var q: CGFloat = 0.72
    for _ in 0 ..< 8 {
        guard let d = img.jpegData(compressionQuality: q) else { return nil }
        if d.count < 1_800_000 { return d }
        q -= 0.1
        if q < 0.18 { break }
    }
    return img.jpegData(compressionQuality: 0.18)
}

// MARK: - Meal Estimate (shared — new meal + history edit)

struct GluMealEstimateSheet: View {
    let snapshot: MealAIOutput
    let envelope: GluMealEnvelope?
    let imageData: Data?
    var onSave: (MealAIOutput) -> Void
    var onDiscard: () -> Void

    @State private var draft: MealAIOutput
    @State private var mode: Mode = .summary
    @State private var showDiscardConfirm = false

    enum Mode {
        case summary
        case editing
    }

    init(
        snapshot: MealAIOutput,
        envelope: GluMealEnvelope? = nil,
        imageData: Data?,
        onSave: @escaping (MealAIOutput) -> Void,
        onDiscard: @escaping () -> Void
    ) {
        self.snapshot = snapshot
        self.envelope = envelope
        self.imageData = imageData
        self.onSave = onSave
        self.onDiscard = onDiscard
        _draft = State(initialValue: snapshot)
    }

    private var isDirty: Bool { draft != snapshot }

    /// Empty breakdown + zero energy usually means the model saw no meal; surface §19 copy.
    private var showNoFoodHint: Bool {
        draft.items.isEmpty && draft.calories == 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let d = imageData, let ui = UIImage(data: d) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                }

                if let env = envelope {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spike lesson")
                            .font(AppTheme.Typography.headline)
                        SpikeRiskPill(risk: env.spike_lesson.risk_band)
                        Text(env.spike_lesson.headline)
                            .font(AppTheme.Typography.subhead)
                            .foregroundStyle(AppTheme.label)
                        Text(env.spike_lesson.coaching)
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.secondaryLabel)
                    }
                    .padding(AppTheme.Layout.optionRowPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.dashboardSurface, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                }

                HStack(alignment: .firstTextBaseline) {
                    Text("\(draft.calories) kcal")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.brand)
                    Text(String(format: "%.0f%% conf", draft.confidence * 100))
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.secondaryLabel)
                        .accessibilityLabel(String(format: "Confidence %.0f percent", draft.confidence * 100))
                    Spacer()
                    SpikeRiskPill(risk: draft.spikeRisk)
                }
                .accessibilityElement(children: .combine)

                macroGrid



                if showNoFoodHint {
                    Text(GluMealAnalysisUserCopy.noFoodDetected)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.secondaryLabel)
                        .padding(AppTheme.Layout.optionRowPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.dashboardSurface, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                        .accessibilityLabel(GluMealAnalysisUserCopy.noFoodDetected)
                } else if draft.confidence < 0.55 {
                    Text(GluMealAnalysisUserCopy.lowConfidenceEstimate)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.secondaryLabel)
                        .padding(AppTheme.Layout.optionRowPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.dashboardSurface, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
                        .accessibilityLabel(GluMealAnalysisUserCopy.lowConfidenceEstimate)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(draft.rationale)
                        .font(AppTheme.Typography.body)
                    Text(draft.disclaimer)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if mode == .summary {
                    assumptionsSection(readOnly: true)
                } else {
                    assumptionsSection(readOnly: false)
                }

                if mode == .summary {
                    Button("Save meal", action: { onSave(draft) })
                        .buttonStyle(PrimaryButtonStyle())
                    Button("Edit estimate") {
                        mode = .editing
                    }
                    .buttonStyle(LibrarySecondaryButtonStyle())
                    Button("Discard", role: .cancel) {
                        if isDirty {
                            showDiscardConfirm = true
                        } else {
                            onDiscard()
                        }
                    }
                    .buttonStyle(LibrarySecondaryButtonStyle())
                } else {
                    Button("Apply edits") {
                        draft.recomputeTotalsFromLineItems()
                        mode = .summary
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(AppTheme.Layout.screenPadding)
        }
        .navigationTitle("Meal Estimate")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Discard this estimate?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive, action: onDiscard)
        } message: {
            Text("You’ll lose changes and this meal won’t be saved.")
        }
    }

    private var macroGrid: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 8) {
            GridRow {
                macroCell("Carbs", "\(Int(draft.carbsG)) g")
                macroCell("Fiber", "\(Int(draft.fiberG)) g")
            }
            GridRow {
                macroCell("Sugar", "\(Int(draft.sugarG)) g")
                macroCell("Protein", "\(Int(draft.proteinG)) g")
            }
            GridRow {
                macroCell("Fat", "\(Int(draft.fatG)) g")
                macroCell("Items", "\(draft.items.count)")
            }
        }
    }

    private func macroCell(_ k: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(k).font(AppTheme.Typography.caption).foregroundStyle(AppTheme.secondaryLabel)
            Text(v)
                .font(AppTheme.Typography.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(macroKeyTint(k).opacity(k == "Items" ? 0.28 : 0.38))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.buttonRadius, style: .continuous))
    }

    private func macroKeyTint(_ key: String) -> Color {
        switch key {
        case "Carbs": return AppTheme.macroCarbs
        case "Protein": return AppTheme.macroProtein
        case "Fat": return AppTheme.macroFat
        case "Fiber": return AppTheme.seafoamAccent
        case "Sugar": return AppTheme.insightLavender
        case "Items": return AppTheme.brandMuted
        default: return AppTheme.divider
        }
    }

    @ViewBuilder
    private func assumptionsSection(readOnly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Line items")
                .font(AppTheme.Typography.headline)
            if draft.items.isEmpty {
                Text("No line items — totals are model-level only.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
            }
            ForEach($draft.items) { item in
                MealLineEditCard(
                    item: item,
                    readOnly: readOnly,
                    onRemove: {
                        let rid = item.wrappedValue.id
                        draft.items.removeAll { $0.id == rid }
                        draft.recomputeTotalsFromLineItems()
                    }
                )
            }
            if !readOnly {
                Button {
                    draft.items.append(MealLineItem(name: "Food item", portionGuess: "1 serving", calories: 0, carbsG: 0))
                } label: {
                    Label("Add item", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

private struct MealLineEditCard: View {
    @Binding var item: MealLineItem
    var readOnly: Bool
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if readOnly {
                Text(item.name.isEmpty ? "Item" : item.name)
                    .font(AppTheme.Typography.headline)
                Text(item.portionGuess)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.secondaryLabel)
                Text("\(item.calories) kcal · \(Int(item.carbsG)) g carbs")
                    .font(AppTheme.Typography.subhead)
            } else {
                TextField("Name", text: $item.name)
                    .textFieldStyle(.roundedBorder)
                TextField("Portion / quantity", text: $item.portionGuess)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    TextField("kcal", value: $item.calories, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    TextField("Carbs (g)", value: $item.carbsG, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                Button("Remove item", role: .destructive, action: onRemove)
                    .font(AppTheme.Typography.footnote)
                    .frame(minHeight: AppTheme.Layout.minTap)
                    .accessibilityLabel("Remove \(item.name.isEmpty ? "item" : item.name)")
            }
        }
        .padding(AppTheme.Layout.optionRowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous))
    }
}

// MARK: - Camera

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.sourceType = .camera
        p.delegate = context.coordinator
        return p
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

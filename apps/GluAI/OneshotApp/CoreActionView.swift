import SwiftUI
import PhotosUI
import UIKit

private struct IdentifiableResult: Identifiable {
    let id = UUID()
    let output: MealAIOutput
    let imageData: Data?
}

struct CoreActionView: View {
    var api: APIClient
    @Bindable var auth: AuthController
    var analytics: NoopAnalytics
    @Bindable var meals: MealLogStore

    @State private var pickerItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var busy = false
    @State private var pendingResult: IdentifiableResult?
    @State private var err: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Log a meal")
                    .font(AppTheme.Typography.title)
                Text("Pick or snap a photo. Glu AI returns rough calories, macros, and a spike-risk label — educational only.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brand)

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Library", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if busy {
                    ProgressView("Analyzing…")
                        .tint(AppTheme.brand)
                }
                if let e = err {
                    Text(e)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.error)
                        .multilineTextAlignment(.center)
                }
                Spacer(minLength: 0)
            }
            .padding(24)
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
            .sheet(item: $pendingResult) { wrap in
                NavigationStack {
                    ResultSheet(
                        imageData: wrap.imageData,
                        output: wrap.output,
                        onSave: {
                            let thumb = wrap.imageData.flatMap { UIImage(data: $0)?.jpegData(compressionQuality: 0.5) }
                            let entry = MealEntry(
                                id: UUID(),
                                createdAt: Date(),
                                thumbnailData: thumb,
                                output: wrap.output
                            )
                            meals.add(entry)
                            analytics.track("meal_saved", properties: ["spike": wrap.output.spikeRisk])
                            pendingResult = nil
                        },
                        onDiscard: {
                            pendingResult = nil
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { pendingResult = nil }
                        }
                    }
                }
            }
        }
    }

    private func loadPicker(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let ui = UIImage(data: data) else { return }
        await runAnalyze(image: ui)
    }

    private func runAnalyze(image: UIImage) async {
        let uid = auth.userId ?? "unknown"
        guard let jpeg = image.jpegData(compressionQuality: 0.72) else {
            err = "Could not read image."
            return
        }
        showCamera = false
        busy = true
        err = nil
        capturedImage = nil
        pickerItem = nil
        analytics.track("meal_capture_started", properties: nil)
        analytics.track("meal_analysis_started", properties: nil)
        let gateway = AIGatewayService(api: api)
        do {
            let out = try await gateway.analyzeMealPhoto(jpegData: jpeg, userId: uid, accessToken: nil)
            await MainActor.run {
                pendingResult = IdentifiableResult(output: out, imageData: jpeg)
                busy = false
                analytics.track("meal_analysis_completed", properties: ["spike": out.spikeRisk])
            }
        } catch {
            await MainActor.run {
                err = error.localizedDescription
                busy = false
                analytics.track("meal_analysis_failed", properties: ["error": String(describing: error)])
            }
        }
    }
}

private struct ResultSheet: View {
    var imageData: Data?
    let output: MealAIOutput
    var onSave: () -> Void
    var onDiscard: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let d = imageData, let ui = UIImage(data: d) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                HStack {
                    Text("\(output.calories) kcal")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.brand)
                    Spacer()
                    SpikeRiskPill(risk: output.spikeRisk)
                }
                Grid(horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        macroCell("Carbs", "\(Int(output.carbsG)) g")
                        macroCell("Fiber", "\(Int(output.fiberG)) g")
                    }
                    GridRow {
                        macroCell("Sugar", "\(Int(output.sugarG)) g")
                        macroCell("Protein", "\(Int(output.proteinG)) g")
                    }
                    GridRow {
                        macroCell("Fat", "\(Int(output.fatG)) g")
                        macroCell("Confidence", String(format: "%.0f%%", output.confidence * 100))
                    }
                }
                Text(output.rationale)
                    .font(AppTheme.Typography.body)
                Text(output.disclaimer)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.secondaryLabel)
                Button("Save meal", action: onSave)
                    .buttonStyle(PrimaryButtonStyle())
                Button("Discard", role: .cancel, action: onDiscard)
            }
            .padding(24)
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func macroCell(_ k: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(k).font(AppTheme.Typography.caption).foregroundStyle(AppTheme.secondaryLabel)
            Text(v).font(AppTheme.Typography.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

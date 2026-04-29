import SwiftUI
import PhotosUI

struct CoreActionView: View {
    var api: APIClient
    @Bindable var auth: AuthController
    var analytics: NoopAnalytics

    @State private var item: PhotosPickerItem?
    @State private var output: String?
    @State private var busy = false
    @State private var err: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Core action")
                    .font(AppTheme.Typography.title)
                Text("Use PhotosPicker, then your Edge Function. Wire `ai.md` in AIGatewayService.")
                    .font(AppTheme.Typography.subhead)
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .multilineTextAlignment(.center)
                PhotosPicker(selection: $item, matching: .images) {
                    Label("Pick a photo (template)", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                if busy { ProgressView() }
                if let o = output {
                    Text(o).font(.body)
                }
                if let e = err {
                    Text(e).font(.caption).foregroundStyle(AppTheme.error)
                }
            }
            .padding(24)
        }
        .onChange(of: item) { _, new in
            Task { await process(new) }
        }
    }

    private func process(_ new: PhotosPickerItem?) async {
        guard new != nil else { return }
        let uid = auth.userId ?? "unknown"
        busy = true
        err = nil
        output = nil
        analytics.track("core_action_started", properties: nil)
        let gateway = AIGatewayService(api: api)
        let r = await gateway.processPhotoPlaceholder(userId: uid)
        await MainActor.run {
            output = r
            busy = false
            analytics.track("core_action_completed", properties: ["userId": uid])
        }
    }
}

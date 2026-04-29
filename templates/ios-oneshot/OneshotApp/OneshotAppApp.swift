import SwiftUI

/// Oneshot iOS template — replace `Oneshot` display name, bundle id, and wire Supabase/RC/Superwall per PRD.
@main
struct OneshotAppApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
        }
    }
}

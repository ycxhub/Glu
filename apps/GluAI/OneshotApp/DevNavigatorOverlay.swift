import SwiftUI

/// Floating entry for `developer` staff role: jump to any funnel phase or main tab.
struct DevNavigatorOverlay: View {
    @Environment(AppState.self) private var appState
    @State private var open = false

    var body: some View {
        Button {
            open = true
        } label: {
            Text("dev")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.purple.gradient)
                .clipShape(Capsule())
                .shadow(radius: 4)
        }
        .accessibilityLabel("Developer navigation")
        .sheet(isPresented: $open) {
            NavigationStack {
                List {
                    Section("Funnel") {
                        Button("Onboarding") {
                            appState.devJumpToPhase(.onboarding)
                            open = false
                        }
                        Button("Auth") {
                            appState.devJumpToPhase(.auth)
                            open = false
                        }
                        Button("Paywall") {
                            appState.devJumpToPhase(.paywall)
                            open = false
                        }
                        Button("Main app") {
                            appState.devJumpToPhase(.main)
                            open = false
                        }
                    }
                    Section("Main tabs") {
                        Button("Home") {
                            appState.selectedMainTab = 0
                            appState.devJumpToPhase(.main)
                            open = false
                        }
                        Button("Log") {
                            appState.selectedMainTab = 1
                            appState.devJumpToPhase(.main)
                            open = false
                        }
                        Button("History") {
                            appState.selectedMainTab = 2
                            appState.devJumpToPhase(.main)
                            open = false
                        }
                        Button("Settings") {
                            appState.selectedMainTab = 3
                            appState.devJumpToPhase(.main)
                            open = false
                        }
                    }
                }
                .navigationTitle("Developer routes")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { open = false }
                    }
                }
            }
        }
    }
}

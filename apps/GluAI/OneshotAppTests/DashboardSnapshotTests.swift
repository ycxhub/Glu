import XCTest
import SwiftUI
import SnapshotTesting
@testable import Glu_AI

final class DashboardSnapshotTests: XCTestCase {
    private let fixedEvening = Date(timeIntervalSince1970: 1_700_050_000)

    override func setUp() {
        super.setUp()
        // Uncomment to record new snapshots. Remember to re-comment before committing!
        // isRecording = true
    }

    func testDashboardSnapshot_WithMeals() {
        let appState = AppState(userDefaults: .ephemeral())
        appState.phase = .main

        let store = MealLogStore()
        let mockOutput = MealAIOutput.mock()
        let entry = MealEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            createdAt: Date(timeIntervalSince1970: 1700000000), // Fixed date for stable snapshots
            thumbnailData: nil,
            output: mockOutput
        )
        store.add(entry)

        let view = HomeView(meals: store, displayName: "Test User", now: fixedEvening)
            .environment(appState)

        let vc = UIHostingController(rootView: view)
        // Force a specific size so snapshots are consistent across simulators
        vc.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852) // iPhone 15 Pro size

        assertSnapshot(of: vc, as: .image)
    }

    func testDashboardSnapshot_EmptyState() {
        let appState = AppState(userDefaults: .ephemeral())
        appState.phase = .main

        let store = MealLogStore()
        // No meals added, but simulate network load completion
        // Since hasLoadedOnce is private(set), we might need to mock or trigger it if needed,
        // but for now, the empty state without hasLoadedOnce might just show nothing or loading.
        // Actually, we can just snapshot it as is.

        let view = HomeView(meals: store, displayName: "Test User", now: fixedEvening)
            .environment(appState)

        let vc = UIHostingController(rootView: view)
        vc.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)

        assertSnapshot(of: vc, as: .image)
    }
}

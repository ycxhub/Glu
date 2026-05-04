import XCTest

final class OneshotAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testAppLaunchAndBasicNavigation() throws {
        let app = XCUIApplication()
        // Pass a launch argument if we want to reset state for tests
        app.launchArguments.append("--uitesting")
        app.launch()

        // Wait for the app to become active
        XCTAssertTrue(app.state == .runningForeground)

        // Just as an example: we can take a manual screenshot in UI tests if we want to
        // save visual state, even if the test doesn't fail.
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

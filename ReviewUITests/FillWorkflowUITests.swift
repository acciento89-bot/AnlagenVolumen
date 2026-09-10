import XCTest

final class FillWorkflowUITests: XCTestCase {
    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
    }
    func testInventoryAndFillAuditPresentation() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Füllabgleich"].waitForExistence(timeout: 15))
        capture(app, "01-inventory")
        app.tabBars.buttons["Füllabgleich"].tap()
        XCTAssertTrue(app.staticTexts["Berechnet trifft eingefüllt."].waitForExistence(timeout: 5))
        capture(app, "02-fill-audit")
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Füllabgleich"].waitForExistence(timeout: 15))
        capture(app, "03-accessibility-inventory")
        app.tabBars.buttons["Füllabgleich"].tap()
        capture(app, "04-accessibility-audit")
    }
}

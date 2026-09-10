import XCTest

final class FillWorkflowUITests: XCTestCase {
    private func capture(_ app: XCUIApplication, _ name: String) {
        Thread.sleep(forTimeInterval: 1)
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
    }
    func testInventoryAndFillAuditPresentation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
        app.launch()
        XCTAssertTrue(app.buttons["Füllabgleich"].waitForExistence(timeout: 15))
        capture(app, "01-inventory")
        let addFirst = app.buttons["Erstes Bauteil hinzufügen"]
        if addFirst.exists {
            for _ in 0..<5 where !addFirst.isHittable { app.swipeUp() }
            addFirst.tap()
            let add = app.scrollViews.buttons["Hinzufügen"]
            XCTAssertTrue(add.waitForExistence(timeout: 5))
            for _ in 0..<5 where !add.isHittable { app.swipeUp() }
            add.tap()
        }
        app.buttons["Füllabgleich"].tap()
        XCTAssertTrue(app.staticTexts["Berechnet trifft eingefüllt."].waitForExistence(timeout: 5))
        capture(app, "02-fill-audit")
        let addFill = app.buttons["Füllabgleich erfassen"]
        for _ in 0..<6 where !addFill.isHittable { app.swipeUp() }
        XCTAssertTrue(addFill.isEnabled)
        addFill.tap()
        let end = app.textFields["Zählerstand nach Befüllung, l"]
        XCTAssertTrue(end.waitForExistence(timeout: 5))
        end.tap(); end.typeText("10")
        let confirmation = app.switches["Anlage war anfangs leer; Inventar und Messung umfassen dieselben Anlagenteile"]
        for _ in 0..<5 where !confirmation.isHittable { app.swipeUp() }
        // SwiftUI exposes the complete labelled row as a switch; hit the actual control.
        confirmation.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        XCTAssertEqual(confirmation.value as? String, "1")
        XCTAssertTrue(app.buttons["Speichern"].isEnabled)
        capture(app, "03-fill-editor")
        app.buttons["Speichern"].tap()
        app.terminate(); app.launch()
        app.buttons["Füllabgleich"].tap()
        let saved = app.staticTexts["10 l eingefüllt"]
        for _ in 0..<6 where !saved.isHittable { app.swipeUp() }
        XCTAssertTrue(saved.exists)
        capture(app, "04-persisted-fill")
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["Füllabgleich"].waitForExistence(timeout: 15))
        capture(app, "03-accessibility-inventory")
        app.buttons["Füllabgleich"].tap()
        capture(app, "04-accessibility-audit")
    }
}

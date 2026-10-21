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
        XCTAssertTrue(app.buttons["Füllabgleich"].firstMatch.waitForExistence(timeout: 15))
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
        app.buttons["Füllabgleich"].firstMatch.tap()
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
        // Ask XCTest to activate the switch; the labelled row has different widths in tablet sheets.
        capture(app, "03-before-system-boundary-confirmation")
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "fill-confirmation-hierarchy"; hierarchy.lifetime = .keepAlways; add(hierarchy)
        confirmation.tap()
        let enabled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "1"), object: confirmation)
        XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 5), .completed)
        XCTAssertEqual(confirmation.value as? String, "1")
        XCTAssertTrue(app.buttons["Speichern"].isEnabled)
        capture(app, "03-fill-editor")
        app.buttons["Speichern"].tap()
        app.terminate(); app.launch()
        app.buttons["Füllabgleich"].firstMatch.tap()
        let saved = app.staticTexts["10 l eingefüllt"]
        for _ in 0..<6 where !saved.isHittable { app.swipeUp() }
        XCTAssertTrue(saved.exists)
        capture(app, "04-persisted-fill")
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["Füllabgleich"].firstMatch.waitForExistence(timeout: 15))
        capture(app, "03-accessibility-inventory")
        app.buttons["Füllabgleich"].firstMatch.tap()
        capture(app, "04-accessibility-audit")
    }
}

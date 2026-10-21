import XCTest

final class AlternativeWorkflowUITests: XCTestCase {
    private func capture(_ app:XCUIApplication,_ name:String){
        let image=XCTAttachment(screenshot:app.screenshot());image.name=name;image.lifetime = .keepAlways;add(image)
    }
    func testIndependentVariantAddSaveReopenAndShare(){
        continueAfterFailure=false
        let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(de)","-AppleLocale","de_DE"];app.launch()
        let tab=app.buttons["Varianten"].firstMatch
        XCTAssertTrue(tab.waitForExistence(timeout:20));tab.tap()
        app.buttons["Variante anlegen"].tap()
        XCTAssertTrue(app.textFields["alternative-name"].waitForExistence(timeout:10))
        let addComponent=app.buttons["Bauteil hinzufügen"]
        for _ in 0..<6 where !addComponent.isHittable {app.swipeUp()}
        XCTAssertTrue(addComponent.isHittable);addComponent.tap()
        let add=app.buttons["Hinzufügen"].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout:10))
        for _ in 0..<5 where !add.isHittable {app.swipeUp()}
        XCTAssertTrue(add.isHittable);add.tap()
        let save=app.navigationBars.buttons["Speichern"]
        XCTAssertTrue(save.waitForExistence(timeout:10));XCTAssertTrue(save.isEnabled)
        capture(app,"01-independent-proposal");save.tap()
        XCTAssertTrue(app.buttons.containing(.staticText,identifier:"Neue Variante").firstMatch.waitForExistence(timeout:10))
        app.terminate();app.launch();app.buttons["Varianten"].firstMatch.tap()
        let saved=app.buttons.containing(.staticText,identifier:"Neue Variante").firstMatch
        XCTAssertTrue(saved.waitForExistence(timeout:10));saved.tap()
        XCTAssertTrue(app.textFields["alternative-name"].waitForExistence(timeout:10))
        capture(app,"02-reopened-proposal")
        let share=app.buttons["Vergleich teilen"]
        for _ in 0..<6 where !share.isHittable {app.swipeUp()}
        XCTAssertTrue(share.isHittable);share.tap()
        XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout:10) || app.buttons["Kopieren"].waitForExistence(timeout:5))
        capture(app,"03-comparison-share")
    }
}

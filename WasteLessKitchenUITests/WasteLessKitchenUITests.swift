import XCTest

final class WasteLessKitchenUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingCompletion() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-ui-testing-reset"]
        app.launch()

        XCTAssertTrue(app.buttons["ContinueOnboarding"].waitForExistence(timeout: 4))
        app.buttons["ContinueOnboarding"].tap()
        app.buttons["ContinueOnboarding"].tap()
        app.buttons["ContinueOnboarding"].tap()
        app.buttons["FinishOnboarding"].tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 4))
    }

    func testScanConfirmAndInventoryFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-skip-onboarding", "-ui-testing-reset"]
        app.launch()

        app.buttons["Scan food"].tap()
        app.buttons["DemoScan"].tap()
        XCTAssertTrue(app.buttons["ConfirmDetectedItems"].waitForExistence(timeout: 5))
        app.buttons["ConfirmDetectedItems"].tap()

        app.tabBars.buttons["Inventory"].tap()
        XCTAssertTrue(app.navigationBars["Inventory"].waitForExistence(timeout: 3))
    }

    func testManualItemEntry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-skip-onboarding", "-ui-testing-reset"]
        app.launch()

        app.tabBars.buttons["Inventory"].tap()
        app.buttons["Add item manually"].tap()
        app.textFields["ManualItemName"].tap()
        app.textFields["ManualItemName"].typeText("Fresh Mint")
        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["Fresh Mint"].waitForExistence(timeout: 3))
    }

    func testCookingModeStepNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-skip-onboarding", "-ui-testing-reset"]
        app.launch()

        XCTAssertTrue(app.buttons["StartCookingMode"].waitForExistence(timeout: 4))
        app.buttons["StartCookingMode"].tap()
        XCTAssertTrue(app.staticTexts["CookingInstruction"].waitForExistence(timeout: 3))
        app.buttons["NextCookingStep"].tap()
        app.buttons["PreviousCookingStep"].tap()
    }
}

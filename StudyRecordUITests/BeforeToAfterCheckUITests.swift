//
//  BeforeToAfterCheckUITests.swift
//  StudyRecordUITests
//
//  Created by 千葉陽乃 on 2025/10/21.
//

import XCTest

final class BeforeToAfterCheckUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UI_TEST_MODE")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testNavigatesToAfterCheckViewWhenDoneButtonTapped() throws {
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Doneボタンが表示されません")

        doneButton.tap()

        let completionTitle = app.staticTexts["afterCheckCompletionTitle"]
        XCTAssertTrue(completionTitle.waitForExistence(timeout: 3), "AfterCheckView が表示されません")
    }
}

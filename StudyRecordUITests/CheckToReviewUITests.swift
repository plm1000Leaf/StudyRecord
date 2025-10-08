//
//  StudyRecordUITests.swift
//  StudyRecordUITests
//
//  Created by 千葉陽乃 on 2025/10/06.
//

// StudyRecordUITests/CheckToReviewUITests.swift
import XCTest

final class CheckToReviewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCheckToReviewTransition() throws {
        // 1️⃣ Check画面にいることを確認
        XCTAssertTrue(app.staticTexts["BeforeCheckView"].waitForExistence(timeout: 3))

        // 2️⃣ 「記録」ボタンをタップ（AccessibilityIdentifierで識別）
        app.buttons["checkButton"].tap()

        // 3️⃣ 遷移完了まで待つ
        let reviewTitle = app.staticTexts["AfterCheckView"]
        XCTAssertTrue(reviewTitle.waitForExistence(timeout: 3))

        // 4️⃣ Review画面で特定の要素を確認
        XCTAssertTrue(app.staticTexts["今日の振り返り"].exists, "Review画面が正しく表示されていません")
    }
}

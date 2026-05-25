//
//  CreateJournalRobot.swift
//  fieldnoteUITests
//
//  Robot pattern for Create Journal sheet
//

import XCTest

final class CreateJournalRobot: BaseRobot {
    private let screen: CreateJournalScreen

    override init(app: XCUIApplication) {
        self.screen = CreateJournalScreen(app: app)
        super.init(app: app)
    }

    /// Enter a journal name in the text field
    @discardableResult
    func enterName(_ name: String) -> Self {
        screen.nameField.enterText(name)
        return self
    }

    /// Tap the Create button
    @discardableResult
    func tapCreate() -> Self {
        screen.createButton.tap()
        return self
    }

    /// Tap the Cancel button
    @discardableResult
    func tapCancel() -> Self {
        // Swipe down to dismiss sheet
        app.swipeDown()
        return self
    }

    /// Verify the sheet is displayed
    @discardableResult
    func verifySheetIsVisible() -> Self {
        XCTAssertTrue(screen.nameLabel.exists, "Create journal sheet should be visible")
        XCTAssertTrue(screen.sheetTitle.exists, "Sheet title should be visible")
        return self
    }

    /// Verify the Create button is enabled/disabled
    @discardableResult
    func verifyCreateButtonEnabled(_ enabled: Bool) -> Self {
        XCTAssertEqual(screen.createButton.isEnabled, enabled, "Create button enabled state should be \(enabled)")
        return self
    }
}

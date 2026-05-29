//
//  EditLogRobot.swift
//  EcoJournalUITests
//
//  Robot pattern for Edit Log screen
//

import XCTest

final class EditLogRobot: BaseRobot {
    private let screen: EditLogScreen

    override init(app: XCUIApplication) {
        self.screen = EditLogScreen(app: app)
        super.init(app: app)
    }

    @discardableResult
    func tapSave() -> Self {
        screen.saveButton.tap()
        return self
    }
}

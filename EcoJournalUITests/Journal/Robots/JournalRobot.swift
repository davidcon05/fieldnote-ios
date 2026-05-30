//
//  JournalRobot.swift
//  EcoJournalUITests
//
//  Robot pattern for Journal tab container
//

import XCTest

final class JournalRobot: BaseRobot {
    private let screen: JournalScreen

    override init(app: XCUIApplication) {
        self.screen = JournalScreen(app: app)
        super.init(app: app)
    }

    /// Verify the journal tab view is visible
    @discardableResult
    func verifyJournalTabView() -> Self {
        XCTAssertTrue(screen.tabBar.exists, "Tab bar should be visible")
        return self
    }

    /// Tap the Logs tab
    @discardableResult
    func tapLogsTab() -> Self {
        XCTAssertTrue(screen.logsTab.waitForExistence(timeout: 10), "Logs tab should be visible before tapping")
        screen.logsTab.tap()
        // Wait for navigation to complete
        Thread.sleep(forTimeInterval: 1)
        return self
    }

    /// Tap the New Log tab
    @discardableResult
    func tapNewLogTab() -> Self {
        screen.newLogTab.tap()
        return self
    }

    /// Tap the Map tab
    @discardableResult
    func tapMapTab() -> Self {
        screen.mapTab.tap()
        return self
    }

    /// Navigate back to dashboard
    @discardableResult
    func navigateBack() -> Self {
        screen.backButton.tap()
        return self
    }
}

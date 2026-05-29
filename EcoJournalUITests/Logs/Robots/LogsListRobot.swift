//
//  LogsListRobot.swift
//  EcoJournalUITests
//
//  Robot pattern for Logs List screen interactions
//

import XCTest

final class LogsListRobot: BaseRobot {
    private let screen: LogsListScreen

    override init(app: XCUIApplication) {
        self.screen = LogsListScreen(app: app)
        super.init(app: app)
    }

    // MARK: - Actions

    @discardableResult
    func searchFor(_ text: String) -> Self {
        screen.searchField.enterText(text)
        return self
    }

    @discardableResult
    func tapFilter() -> Self {
        screen.filterButton.tap()
        return self
    }

    @discardableResult
    func selectLog(title: String) -> Self {
        screen.logCardByTitle(title).tap()
        return self
    }

    // MARK: - Verifications

    @discardableResult
    func verifyEmptyState() -> Self {
        XCTAssertTrue(screen.emptyStateIcon.exists, "Empty state icon should exist")
        XCTAssertTrue(screen.emptyStateTitle.exists, "Empty state title should exist")
        XCTAssertTrue(screen.emptyStateMessage.exists, "Empty state message should exist")
        return self
    }

    @discardableResult
    func verifyLogExists(title: String) -> Self {
        XCTAssertTrue(screen.logCardByTitle(title).exists, "Log '\(title)' should exist")
        return self
    }

    @discardableResult
    func verifyLogDoesNotExist(title: String) -> Self {
        XCTAssertFalse(screen.logCardByTitle(title).exists, "Log '\(title)' should not exist")
        return self
    }

    @discardableResult
    func verifyHeaderTitle(_ title: String) -> Self {
        XCTAssertTrue(screen.headerTitle.label.contains(title), "Header should contain '\(title)'")
        return self
    }
}

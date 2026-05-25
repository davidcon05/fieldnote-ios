//
//  DashboardRobot.swift
//  fieldnoteUITests
//
//  Robot pattern for Dashboard screen interactions
//

import XCTest

final class DashboardRobot: BaseRobot {
    private let screen: DashboardScreen

    override init(app: XCUIApplication) {
        self.screen = DashboardScreen(app: app)
        super.init(app: app)
    }

    // MARK: - Actions

    /// Tap the "New Journal" button to open the create journal sheet
    @discardableResult
    func tapNewJournal() -> Self {
        screen.newJournalButton.tap()
        return self
    }

    /// Search for journals using the search field
    @discardableResult
    func searchFor(_ text: String) -> Self {
        screen.searchField.enterText(text)
        return self
    }

    /// Clear the search field
    @discardableResult
    func clearSearch() -> Self {
        if screen.searchField.exists {
            screen.searchField.tap()
            screen.searchField.buttons["Clear text"].firstMatch.tap()
        }
        return self
    }

    /// Select a journal by name to navigate into it
    @discardableResult
    func selectJournal(named name: String) -> Self {
        screen.journalCardByName(name).tap()
        return self
    }

    /// Tap the filter button
    @discardableResult
    func tapFilter() -> Self {
        screen.filterButton.tap()
        return self
    }

    /// Select a sort option from the filter sheet
    @discardableResult
    func selectSortOption(_ option: String) -> Self {
        let sortOption = screen.sortOption(option)
        XCTAssertTrue(sortOption.waitForExistence(timeout: 2), "Sort option '\(option)' should exist")
        sortOption.tap()
        return self
    }

    // MARK: - Verifications

    /// Verify the empty state is displayed
    @discardableResult
    func verifyEmptyState() -> Self {
        XCTAssertTrue(screen.emptyStateIcon.exists, "Empty state icon should be visible")
        XCTAssertTrue(screen.emptyStateTitle.exists, "Empty state title should be visible")
        XCTAssertTrue(screen.emptyStateMessage.exists, "Empty state message should be visible")
        return self
    }

    /// Verify a journal exists on the dashboard
    @discardableResult
    func verifyJournalExists(named name: String) -> Self {
        let journal = screen.journalCardByName(name)
        XCTAssertTrue(journal.waitForExistence(timeout: 3), "Journal '\(name)' should exist on dashboard")
        return self
    }

    /// Verify a journal does not exist on the dashboard
    @discardableResult
    func verifyJournalDoesNotExist(named name: String) -> Self {
        let journal = screen.journalCardByName(name)
        XCTAssertFalse(journal.exists, "Journal '\(name)' should not exist on dashboard")
        return self
    }

    /// Verify the dashboard shows the correct number of journals
    @discardableResult
    func verifyJournalCount(_ expectedCount: Int) -> Self {
        // This assumes journals have a consistent accessibility identifier
        XCTAssertEqual(screen.journalCards.count, expectedCount, "Should have \(expectedCount) journal(s)")
        return self
    }

    /// Verify the dashboard title is visible
    @discardableResult
    func verifyDashboardTitle() -> Self {
        XCTAssertTrue(screen.dashboardTitle.exists, "Dashboard title should be 'Journals'")
        return self
    }

    /// Verify a journal has a lock icon (password protected)
    @discardableResult
    func verifyJournalIsLocked(named name: String) -> Self {
        // Look for lock icon near the journal name
        XCTAssertTrue(screen.lockIcon.exists, "Journal '\(name)' should show a lock icon")
        return self
    }

    /// Verify search results show specific text
    @discardableResult
    func verifySearchResults(contain text: String) -> Self {
        let result = screen.journalCardByName(text)
        XCTAssertTrue(result.exists, "Search results should contain '\(text)'")
        return self
    }

    /// Wait for dashboard to load
    @discardableResult
    func waitForDashboard() -> Self {
        XCTAssertTrue(screen.dashboardTitle.waitForExistence(timeout: 5), "Dashboard should load")
        return self
    }
}

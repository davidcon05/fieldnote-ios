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
        // Look for the clear button (xmark icon) within the app
        let clearButton = app.buttons["xmark.circle.fill"].firstMatch
        if clearButton.exists {
            clearButton.tap()
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

    // MARK: - Dropdown Autocomplete Actions

    /// Tap a search suggestion from the dropdown
    @discardableResult
    func tapSearchSuggestion(_ suggestionText: String) -> Self {
        let suggestion = screen.searchSuggestion(suggestionText)
        XCTAssertTrue(suggestion.waitForExistence(timeout: 2), "Search suggestion '\(suggestionText)' should exist")
        suggestion.tap()
        return self
    }

    // MARK: - Dropdown Autocomplete Verifications

    /// Verify that a search suggestion appears in the dropdown
    @discardableResult
    func verifySearchSuggestionExists(_ suggestionText: String) -> Self {
        let suggestion = screen.searchSuggestion(suggestionText)

        // Debug: Print what we're looking for and what we found
        print("=== DEBUG: Looking for suggestion '\(suggestionText)' ===")
        print("Looking for identifier: 'searchSuggestion.\(suggestionText)'")
        print("Suggestion exists: \(suggestion.exists)")

        // List all current suggestions
        let allSuggestions = screen.searchSuggestions
        print("Total suggestions found: \(allSuggestions.count)")
        for i in 0..<min(allSuggestions.count, 5) {
            let sug = allSuggestions.element(boundBy: i)
            print("  Suggestion \(i): identifier='\(sug.identifier)', label='\(sug.label)'")
        }
        print("===============================================")

        XCTAssertTrue(suggestion.exists, "Search suggestion '\(suggestionText)' should be visible in dropdown")
        return self
    }

    /// Verify that a search suggestion does not appear in the dropdown
    @discardableResult
    func verifySearchSuggestionDoesNotExist(_ suggestionText: String) -> Self {
        let suggestion = screen.searchSuggestion(suggestionText)
        XCTAssertFalse(suggestion.exists, "Search suggestion '\(suggestionText)' should not be visible")
        return self
    }

    /// Verify that the dropdown shows the expected number of suggestions
    @discardableResult
    func verifyDropdownSuggestionCount(_ expectedCount: Int) -> Self {
        let suggestions = screen.searchSuggestions
        XCTAssertEqual(suggestions.count, expectedCount, "Dropdown should show \(expectedCount) suggestion(s)")
        return self
    }

    /// Verify the dropdown is visible
    @discardableResult
    func verifyDropdownIsVisible() -> Self {
        // Wait a moment for dropdown animation
        sleep(1)

        let suggestions = screen.searchSuggestions

        // Debug: Print all buttons to see what's available
        print("=== DEBUG: Searching for dropdown suggestions ===")
        print("Found \(suggestions.count) suggestions matching 'searchSuggestion.' prefix")

        // Print all buttons with their identifiers
        let allButtons = app.buttons.allElementsBoundByIndex
        print("Total buttons in view: \(allButtons.count)")
        for (index, button) in allButtons.prefix(20).enumerated() {
            print("Button \(index): identifier='\(button.identifier)', label='\(button.label)', exists=\(button.exists)")
        }
        print("==============================================")

        XCTAssertGreaterThan(suggestions.count, 0, "Dropdown should be visible with at least one suggestion")
        return self
    }

    /// Verify the dropdown is hidden
    @discardableResult
    func verifyDropdownIsHidden() -> Self {
        let suggestions = screen.searchSuggestions
        XCTAssertEqual(suggestions.count, 0, "Dropdown should be hidden")
        return self
    }
}

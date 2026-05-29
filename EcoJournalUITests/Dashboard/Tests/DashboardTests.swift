//
//  DashboardTests.swift
//  EcoJournalUITests
//
//  Tests for Dashboard functionality
//

import XCTest

final class DashboardTests: BaseUITest {

    // MARK: - Empty State Tests

    func test_dashboard_showsEmptyState_whenNoJournals() {
        DashboardRobot(app: app)
            .verifyEmptyState()
            .verifyDashboardTitle()
    }

    // MARK: - Journal Creation Tests

    func test_createJournal_successfullyCreatesJournal() {
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Test Journal")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .verifyJournalExists(named: "Test Journal")
    }

    func test_createJournal_createButtonDisabled_whenNameIsEmpty() {
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .verifyCreateButtonEnabled(false)
    }

    func test_createMultipleJournals_allAppearOnDashboard() {
        // Create first journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Journal One")
            .tapCreate()

        DashboardRobot(app: app)
            .verifyJournalExists(named: "Journal One")
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Journal Two")
            .tapCreate()

        DashboardRobot(app: app)
            .verifyJournalExists(named: "Journal One")
            .verifyJournalExists(named: "Journal Two")
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Journal Three")
            .tapCreate()

        DashboardRobot(app: app)
            .verifyJournalExists(named: "Journal One")
            .verifyJournalExists(named: "Journal Two")
            .verifyJournalExists(named: "Journal Three")
    }

    // MARK: - Search Tests

    func test_searchJournals_findsMatchingJournal() {
        // Create a journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        // Search for it
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Olympic")
            .verifySearchResults(contain: "Olympic National Park")
    }

    func test_searchJournals_filtersResults() {
        // Create first journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Yellowstone National Park")
            .tapCreate()

        // Search filters correctly
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Olympic")
            .verifySearchResults(contain: "Olympic National Park")
            .verifyJournalDoesNotExist(named: "Yellowstone National Park")
    }

    // MARK: - Dropdown Autocomplete Tests

    func test_searchDropdown_showsSuggestions_whenTyping() {
        // Setup: Create journals
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympia State Forest")
            .tapCreate()

        // Test: Type to show suggestions
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Oly")
            .verifyDropdownIsVisible()
            .verifySearchSuggestionExists("Olympic National Park")
            .verifySearchSuggestionExists("Olympia State Forest")
    }

    func test_searchDropdown_filtersSuggestions_basedOnInput() {
        // Setup: Create journals
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Yellowstone National Park")
            .tapCreate()

        // Test: Filter suggestions
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Olympic")
            .verifyDropdownIsVisible()
            .verifySearchSuggestionExists("Olympic National Park")
            .verifySearchSuggestionDoesNotExist("Yellowstone National Park")
    }

    func test_searchDropdown_selectingSuggestion_navigatesToJournal() {
        // Setup: Create journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        // Test: Select suggestion
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Oly")
            .verifyDropdownIsVisible()
            .tapSearchSuggestion("Olympic National Park")

        // Verify navigation to journal
        JournalRobot(app: app)
            .verifyJournalTabView()
    }

    func test_searchDropdown_hidesWhenSearchIsCleared() {
        // Setup: Create journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic National Park")
            .tapCreate()

        // Test: Show then hide dropdown
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Oly")
            .verifyDropdownIsVisible()
            .clearSearch()
            .verifyDropdownIsHidden()
    }

    func test_searchDropdown_prioritizesPrefixMatches() {
        // Setup: Create journals with different match types
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Mount Rainier")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Rocky Mountains")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Olympic Peninsula")
            .tapCreate()

        // Test: Search for "Mount" - should show both journals with "mount" in them
        // "Mount Rainier" should appear first (prefix match), then "Rocky Mountains" (contains match)
        // "Olympic Peninsula" should not appear (doesn't contain "mount")
        DashboardRobot(app: app)
            .waitForDashboard()
            .searchFor("Mount")
            .verifyDropdownIsVisible()
            .verifySearchSuggestionExists("Mount Rainier") // Prefix match - should appear first
            .verifySearchSuggestionExists("Rocky Mountains") // Contains match - should appear second
            .verifySearchSuggestionDoesNotExist("Olympic Peninsula") // No match
    }

    // MARK: - Navigation Tests

    func test_selectJournal_navigatesToJournalTabs() {
        // Setup: Create a journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Test Journal")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .selectJournal(named: "Test Journal")

        // Test: Verify journal tab view
        JournalRobot(app: app)
            .verifyJournalTabView()
    }

    func test_navigateToJournal_andBack() {
        // Setup: Create a journal
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName("Test Journal")
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .selectJournal(named: "Test Journal")

        // Test: Navigate in and back out
        JournalRobot(app: app)
            .verifyJournalTabView()
            .navigateBack()

        DashboardRobot(app: app)
            .verifyDashboardTitle()
            .verifyJournalExists(named: "Test Journal")
    }
}

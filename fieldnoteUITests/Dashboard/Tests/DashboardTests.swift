//
//  DashboardTests.swift
//  fieldnoteUITests
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

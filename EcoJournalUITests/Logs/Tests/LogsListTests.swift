//
//  LogsListTests.swift
//  EcoJournalUITests
//
//  Tests for Logs List functionality
//

import XCTest

final class LogsListTests: BaseUITest {

    // MARK: - Test Helpers

    /// Helper to create a journal and navigate to its Logs tab
    private func navigateToLogsTab(journalName: String = "Test Journal") {
        DashboardRobot(app: app)
            .tapNewJournal()

        CreateJournalRobot(app: app)
            .enterName(journalName)
            .tapCreate()

        DashboardRobot(app: app)
            .waitForDashboard()
            .selectJournal(named: journalName)

        JournalRobot(app: app)
            .tapLogsTab()
    }

    /// Helper to create a log entry
    private func createLog(title: String, notes: String = "Test notes") {
        JournalRobot(app: app)
            .tapNewLogTab()

        NewLogRobot(app: app)
            .enterTitle(title)
            .enterNotes(notes)
            .tapFinalizeEntry()
    }

    // MARK: - Empty State Tests

    func test_logsList_showsEmptyState_whenNoLogs() {
        navigateToLogsTab()

        LogsListRobot(app: app)
            .verifyEmptyState()
    }

    // MARK: - Log Display Tests

    // TODO: Re-enable these tests once mock data infrastructure is in place
    // These tests require GPS/location services which don't work reliably in UI tests
    // without proper mocking. See docs/ui-testing-parallelization-requirements.md

    // func test_logsList_displaysLog_afterCreation() {
    //     navigateToLogsTab()
    //
    //     createLog(title: "First Observation")
    //
    //     LogsListRobot(app: app)
    //         .verifyLogExists(title: "First Observation")
    // }

    // func test_logsList_displaysMultipleLogs() {
    //     navigateToLogsTab()
    //
    //     createLog(title: "Morning Hike")
    //     createLog(title: "Afternoon Birds")
    //     createLog(title: "Evening Sunset")
    //
    //     LogsListRobot(app: app)
    //         .verifyLogExists(title: "Morning Hike")
    //         .verifyLogExists(title: "Afternoon Birds")
    //         .verifyLogExists(title: "Evening Sunset")
    // }

    // MARK: - Search Tests

    // func test_logsList_searchFindsMatchingLog() {
    //     navigateToLogsTab()
    //
    //     createLog(title: "Eagle Sighting")
    //     createLog(title: "Bear Tracks")
    //
    //     LogsListRobot(app: app)
    //         .searchFor("Eagle")
    //         .verifyLogExists(title: "Eagle Sighting")
    // }

    // MARK: - Navigation Tests

    // func test_logsList_navigateToLogDetail() {
    //     navigateToLogsTab()
    //
    //     createLog(title: "Detail Test Log")
    //
    //     LogsListRobot(app: app)
    //         .selectLog(title: "Detail Test Log")
    //
    //     LogDetailRobot(app: app)
    //         .verifyTitle("Detail Test Log")
    // }

    // func test_logsList_navigateToLogDetailAndBack() {
    //     navigateToLogsTab()
    //
    //     createLog(title: "Navigation Test")
    //
    //     LogsListRobot(app: app)
    //         .selectLog(title: "Navigation Test")
    //
    //     LogDetailRobot(app: app)
    //         .verifyTitle("Navigation Test")
    //         .navigateBack()
    //
    //     LogsListRobot(app: app)
    //         .verifyLogExists(title: "Navigation Test")
    // }
}

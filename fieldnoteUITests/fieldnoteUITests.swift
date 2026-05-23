//
//  fieldnoteUITests.swift
//  fieldnoteUITests
//
//  Created by David Contreras on 5/5/26.
//

import XCTest

final class fieldnoteUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        // Clear app state before each test (equivalent to Maestro's clearState: true)
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Test Suite (Matching Maestro tests)

    func test_verifyDashboardEmptyState() throws {
        _ = app.exists
        var journals: XCUIElement { app.staticTexts["No Journals Yet"].firstMatch }
        var startAdding: XCUIElement { app.staticTexts["Start by adding a new journal"].firstMatch }
        var newJournal: XCUIElement { app.staticTexts["New Journal"].firstMatch }
        
        XCTAssertTrue(journals.exists)
        XCTAssertTrue(startAdding.exists)
        XCTAssertTrue(newJournal.exists)
    }

    func test_verifyCreateJournal() throws {
        _ = app.exists
        var newJournal: XCUIElement { app.buttons["New Journal"].firstMatch }
        
        // Tap New Journal button
        XCTAssertTrue(newJournal.exists)
        newJournal.tap()

        // Verify sheet appears
        var journalNameLabel: XCUIElement { app.staticTexts["JOURNAL NAME"].firstMatch }
        XCTAssertTrue(journalNameLabel.exists)

        // Type into text field
        var textField: XCUIElement { app.textFields["Enter name"].firstMatch }
        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.typeText("XCUITest Journal")

        // Tap Create button
        var createButton: XCUIElement { app.buttons["Create"].firstMatch }
        var titleLabel: XCUIElement { app.staticTexts["Journals"].firstMatch }
        XCTAssertTrue(createButton.exists)
        createButton.tap()

        // Verify back on dashboard
        XCTAssertTrue(titleLabel.exists)

        // Verify journal created
        var xcuiJournal: XCUIElement { app.staticTexts["XCUITest Journal"].firstMatch }
        XCTAssertTrue(xcuiJournal.exists)
    }

    func test_verifySearchJournals() throws {
        // Create a journal to search for
        _ = app.exists
        var newJournalButton: XCUIElement { app.buttons["New Journal"].firstMatch }
        XCTAssertTrue(newJournalButton.exists)
        newJournalButton.tap()

        var textField: XCUIElement { app.textFields["Enter name"].firstMatch }
        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.typeText("Search Test Journal")

        var createButton: XCUIElement { app.buttons["Create"].firstMatch }
        XCTAssertTrue(createButton.exists)
        createButton.tap()

        // Wait for dashboard
        var titleLabel: XCUIElement { app.staticTexts["Journals"].firstMatch }
        XCTAssertTrue(titleLabel.exists)

        // Tap search field
        var searchField: XCUIElement { app.textFields["Search Journals..."].firstMatch }
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Search")

        // Verify journal appears in search results
        var searchTestLabel: XCUIElement { app.staticTexts["Search Test Journal"].firstMatch }
        XCTAssertTrue(searchTestLabel.exists)
    }
}

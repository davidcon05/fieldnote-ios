//
//  LogsListScreen.swift
//  fieldnoteUITests
//
//  Screen object for Logs List feature
//

import XCTest

struct LogsListScreen {
    let app: XCUIApplication

    // MARK: - Elements

    // Empty State
    var emptyStateIcon: XCUIElement {
        app.images["logsList.emptyState.icon"].firstMatch
    }

    var emptyStateTitle: XCUIElement {
        app.staticTexts["logsList.emptyState.title"].firstMatch
    }

    var emptyStateMessage: XCUIElement {
        app.staticTexts["logsList.emptyState.message"].firstMatch
    }

    // Search & Filter
    var searchField: XCUIElement {
        app.textFields["logsList.searchField"].firstMatch
    }

    var filterButton: XCUIElement {
        app.buttons["logsList.filterButton"].firstMatch
    }

    // Header
    var headerTitle: XCUIElement {
        app.staticTexts["logsList.headerTitle"].firstMatch
    }

    // Dynamic Elements
    func logCard(id: String) -> XCUIElement {
        app.otherElements["logsList.logCard.\(id)"].firstMatch
    }

    func logCardByTitle(_ title: String) -> XCUIElement {
        app.staticTexts[title].firstMatch
    }
}

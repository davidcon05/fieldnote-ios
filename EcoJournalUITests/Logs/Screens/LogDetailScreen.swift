//
//  LogDetailScreen.swift
//  EcoJournalUITests
//
//  Screen object for Log Detail feature
//

import XCTest

struct LogDetailScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var heroPhoto: XCUIElement {
        app.images["logDetail.heroPhoto"].firstMatch
    }

    var titleText: XCUIElement {
        app.staticTexts["logDetail.titleText"].firstMatch
    }

    var timestampText: XCUIElement {
        app.staticTexts["logDetail.timestampText"].firstMatch
    }

    var notesText: XCUIElement {
        app.staticTexts["logDetail.notesText"].firstMatch
    }

    var gpsTelemetryCard: XCUIElement {
        app.otherElements["logDetail.gpsTelemetryCard"].firstMatch
    }

    var weatherDataCard: XCUIElement {
        app.otherElements["logDetail.weatherDataCard"].firstMatch
    }

    var editButton: XCUIElement {
        app.buttons["logDetail.editButton"].firstMatch
    }

    var deleteButton: XCUIElement {
        app.buttons["logDetail.deleteButton"].firstMatch
    }

    var backButton: XCUIElement {
        app.navigationBars.buttons.firstMatch
    }
}

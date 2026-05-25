//
//  NewLogScreen.swift
//  fieldnoteUITests
//
//  Screen object for New Log feature
//

import XCTest

struct NewLogScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var titleField: XCUIElement {
        app.textFields["newLog.titleField"].firstMatch
    }

    var notesField: XCUIElement {
        app.textFields["newLog.notesField"].firstMatch
    }

    var finalizeButton: XCUIElement {
        app.buttons["newLog.finalizeButton"].firstMatch
    }

    var addPhotoButton: XCUIElement {
        app.buttons["newLog.addPhotoButton"].firstMatch
    }

    var gpsTelemetryCard: XCUIElement {
        app.otherElements["newLog.gpsTelemetryCard"].firstMatch
    }

    var weatherDataCard: XCUIElement {
        app.otherElements["newLog.weatherDataCard"].firstMatch
    }

    var weatherRetryButton: XCUIElement {
        app.buttons["newLog.weatherRetryButton"].firstMatch
    }
}

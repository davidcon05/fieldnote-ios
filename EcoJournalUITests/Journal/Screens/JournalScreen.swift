//
//  JournalScreen.swift
//  EcoJournalUITests
//
//  Screen object for Journal tab container
//

import XCTest

struct JournalScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var tabBar: XCUIElement {
        app.tabBars.firstMatch
    }

    var logsTab: XCUIElement {
        app.buttons["Logs"].firstMatch
    }

    var newLogTab: XCUIElement {
        app.buttons["New Log"].firstMatch
    }

    var mapTab: XCUIElement {
        app.buttons["Map"].firstMatch
    }

    var backButton: XCUIElement {
        app.navigationBars.buttons.firstMatch
    }
}

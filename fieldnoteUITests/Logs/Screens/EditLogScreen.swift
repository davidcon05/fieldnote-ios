//
//  EditLogScreen.swift
//  fieldnoteUITests
//
//  Screen object for Edit Log feature
//

import XCTest

struct EditLogScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var saveButton: XCUIElement {
        app.buttons["editLog.saveButton"].firstMatch
    }
}

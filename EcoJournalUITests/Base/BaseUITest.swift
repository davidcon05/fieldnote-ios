//
//  BaseUITest.swift
//  EcoJournalUITests
//
//  Base test class for all UI tests
//

import XCTest
import CoreLocation

class BaseUITest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]

        // Note: Location must be simulated via scheme settings or GPX file
        // For now, the app should handle missing location gracefully in tests
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
}

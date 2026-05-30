//
//  NewLogRobot.swift
//  EcoJournalUITests
//
//  Robot pattern for New Log screen interactions
//

import XCTest

final class NewLogRobot: BaseRobot {
    private let screen: NewLogScreen

    override init(app: XCUIApplication) {
        self.screen = NewLogScreen(app: app)
        super.init(app: app)
    }

    // MARK: - Actions

    @discardableResult
    func enterTitle(_ title: String) -> Self {
        screen.titleField.enterText(title)
        return self
    }

    @discardableResult
    func enterNotes(_ notes: String) -> Self {
        screen.notesField
            .scrollToElement(distance: .search) // Defaults: 1 attempt, .screen distance
            .enterText(notes)
        return self
    }

    @discardableResult
    func tapAddPhoto() -> Self {
        screen.addPhotoButton.tap()
        return self
    }

    @discardableResult
    func tapFinalizeEntry() -> Self {
        screen.finalizeButton.tap()
        return self
    }

    @discardableResult
    func dismissSaveConfirmationAlert() -> Self {
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons["OK"].tap()
        }
        return self
    }

    @discardableResult
    func tapRetryWeather() -> Self {
        screen.weatherRetryButton.scrollToElement()
        screen.weatherRetryButton.tap()
        return self
    }

    // MARK: - Verifications

    @discardableResult
    func verifyTitleFieldExists() -> Self {
        screen.titleField.scrollToElement()
        XCTAssertTrue(screen.titleField.exists, "Title field should exist")
        return self
    }

    @discardableResult
    func verifyFinalizeButtonEnabled(_ enabled: Bool) -> Self {
        XCTAssertEqual(screen.finalizeButton.isEnabled, enabled, "Finalize button enabled state should be \(enabled)")
        return self
    }

    @discardableResult
    func verifyGPSCardExists() -> Self {
        screen.gpsTelemetryCard.scrollToElement()
        XCTAssertTrue(screen.gpsTelemetryCard.waitForExistence(timeout: 2), "GPS telemetry card should exist")
        return self
    }

    @discardableResult
    func verifyWeatherCardExists() -> Self {
        XCTAssertTrue(screen.weatherDataCard.waitForExistence(timeout: 2), "Weather data card should exist")
        return self
    }
}

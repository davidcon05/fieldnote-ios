//
//  MapRobot.swift
//  EcoJournalUITests
//
//  Robot pattern for Map screen interactions
//

import XCTest

final class MapRobot: BaseRobot {
    private let screen: MapScreen

    override init(app: XCUIApplication) {
        self.screen = MapScreen(app: app)
        super.init(app: app)
    }

    // MARK: - Actions

    @discardableResult
    func tapCenterLocation() -> Self {
        screen.centerLocationButton.tap()
        return self
    }

    @discardableResult
    func tapMetricsPanel() -> Self {
        screen.metricsPanel.tap()
        return self
    }

    @discardableResult
    func tapPin(logID: String) -> Self {
        screen.pin(logID: logID).tap()
        return self
    }

    @discardableResult
    func tapCalloutDetails() -> Self {
        screen.calloutDetailsButton.tap()
        return self
    }

    @discardableResult
    func tapCalloutClose() -> Self {
        screen.calloutCloseButton.tap()
        return self
    }

    // MARK: - Verifications

    @discardableResult
    func verifyEmptyState() -> Self {
        XCTAssertTrue(screen.emptyStateIcon.exists, "Empty state icon should exist")
        XCTAssertTrue(screen.emptyStateTitle.exists, "Empty state title should exist")
        XCTAssertTrue(screen.emptyStateMessage.exists, "Empty state message should exist")
        return self
    }

    @discardableResult
    func verifyMapExists() -> Self {
        XCTAssertTrue(screen.mapView.waitForExistence(timeout: 5), "Map view should exist")
        return self
    }

    @discardableResult
    func verifyPinExists(logID: String) -> Self {
        XCTAssertTrue(screen.pin(logID: logID).exists, "Pin for log \(logID) should exist")
        return self
    }

    @discardableResult
    func verifyCalloutExists() -> Self {
        XCTAssertTrue(screen.calloutCard.exists, "Callout card should exist")
        return self
    }

    @discardableResult
    func verifyCalloutDoesNotExist() -> Self {
        XCTAssertFalse(screen.calloutCard.exists, "Callout card should not exist")
        return self
    }

    @discardableResult
    func verifyMetricsPanelExists() -> Self {
        XCTAssertTrue(screen.metricsPanel.exists, "Metrics panel should exist")
        return self
    }
}

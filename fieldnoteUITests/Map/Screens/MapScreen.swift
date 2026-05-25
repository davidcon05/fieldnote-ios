//
//  MapScreen.swift
//  fieldnoteUITests
//
//  Screen object for Map feature
//

import XCTest

struct MapScreen {
    let app: XCUIApplication

    // MARK: - Elements

    // Empty State
    var emptyStateIcon: XCUIElement {
        app.images["map.emptyState.icon"].firstMatch
    }

    var emptyStateTitle: XCUIElement {
        app.staticTexts["map.emptyState.title"].firstMatch
    }

    var emptyStateMessage: XCUIElement {
        app.staticTexts["map.emptyState.message"].firstMatch
    }

    // Map
    var mapView: XCUIElement {
        app.maps["map.mapView"].firstMatch
    }

    // Controls
    var centerLocationButton: XCUIElement {
        app.buttons["map.centerLocationButton"].firstMatch
    }

    var metricsPanel: XCUIElement {
        app.otherElements["map.metricsPanel"].firstMatch
    }

    // Callout
    var calloutCard: XCUIElement {
        app.otherElements["map.calloutCard"].firstMatch
    }

    var calloutDetailsButton: XCUIElement {
        app.buttons["map.calloutDetailsButton"].firstMatch
    }

    var calloutCloseButton: XCUIElement {
        app.buttons["map.calloutCloseButton"].firstMatch
    }

    // Dynamic Elements
    func pin(logID: String) -> XCUIElement {
        app.otherElements["map.pin.\(logID)"].firstMatch
    }
}

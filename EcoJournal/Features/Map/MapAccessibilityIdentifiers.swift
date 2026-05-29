//
//  MapAccessibilityIdentifiers.swift
//  EcoJournal
//
//  Accessibility identifiers for Map feature
//

import Foundation

enum MapAccessibilityIdentifiers {
    // Empty State
    static let emptyStateIcon = "map.emptyState.icon"
    static let emptyStateTitle = "map.emptyState.title"
    static let emptyStateMessage = "map.emptyState.message"

    // Map
    static let mapView = "map.mapView"

    // Pins
    static func pin(_ logID: String) -> String {
        "map.pin.\(logID)"
    }

    // Live Metrics Panel
    static let metricsPanel = "map.metricsPanel"
    static let metricsPanelHeader = "map.metricsPanel.header"
    static let metricsElevation = "map.metricsPanel.elevation"
    static let metricsHumidity = "map.metricsPanel.humidity"
    static let metricsTemperature = "map.metricsPanel.temperature"

    // Center Location Button
    static let centerLocationButton = "map.centerLocationButton"

    // Callout
    static let calloutCard = "map.calloutCard"
    static let calloutTitle = "map.calloutTitle"
    static let calloutDate = "map.calloutDate"
    static let calloutDetailsButton = "map.calloutDetailsButton"
    static let calloutCloseButton = "map.calloutCloseButton"
}

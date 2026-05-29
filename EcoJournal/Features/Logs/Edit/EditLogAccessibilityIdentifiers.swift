//
//  EditLogAccessibilityIdentifiers.swift
//  EcoJournal
//
//  Accessibility identifiers for Edit Log feature
//

import Foundation

enum EditLogAccessibilityIdentifiers {
    // Similar to NewLog but with edit prefix
    static let titleField = "editLog.titleField"
    static let notesField = "editLog.notesField"
    static let saveButton = "editLog.saveButton"
    static let deleteButton = "editLog.deleteButton"

    // Refresh buttons
    static let refreshWeatherButton = "editLog.refreshWeatherButton"
    static let refreshGPSButton = "editLog.refreshGPSButton"

    // Cards
    static let gpsTelemetryCard = "editLog.gpsTelemetryCard"
    static let weatherCard = "editLog.weatherCard"
}

//
//  NewLogAccessibilityIdentifiers.swift
//  fieldnote
//
//  Accessibility identifiers for New Log feature
//

import Foundation

enum NewLogAccessibilityIdentifiers {
    // Header
    static let sessionHeader = "newLog.sessionHeader"
    static let sessionTitle = "newLog.sessionTitle"

    // Title Field
    static let titleLabel = "newLog.titleLabel"
    static let titleField = "newLog.titleField"

    // Photo Gallery
    static let photoGallery = "newLog.photoGallery"
    static let addPhotoButton = "newLog.addPhotoButton"
    static func photoThumbnail(_ index: Int) -> String {
        "newLog.photoThumbnail.\(index)"
    }

    // Audio Memos
    static let audioMemoSection = "newLog.audioMemoSection"
    static let addAudioButton = "newLog.addAudioButton"

    // GPS Card
    static let gpsTelemetryCard = "newLog.gpsTelemetryCard"
    static let gpsRefreshButton = "newLog.gpsRefreshButton"

    // Weather Card
    static let weatherDataCard = "newLog.weatherDataCard"
    static let weatherRetryButton = "newLog.weatherRetryButton"

    // Field Notes
    static let notesLabel = "newLog.notesLabel"
    static let notesField = "newLog.notesField"

    // Save Button
    static let finalizeButton = "newLog.finalizeButton"
}

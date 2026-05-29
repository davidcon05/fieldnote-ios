//
//  LogsListAccessibilityIdentifiers.swift
//  EcoJournal
//
//  Accessibility identifiers for Logs List feature
//

import Foundation

enum LogsListAccessibilityIdentifiers {
    // Empty State
    static let emptyStateIcon = "logsList.emptyState.icon"
    static let emptyStateTitle = "logsList.emptyState.title"
    static let emptyStateMessage = "logsList.emptyState.message"

    // Search & Filter
    static let searchField = "logsList.searchField"
    static let filterButton = "logsList.filterButton"

    // Header
    static let headerTitle = "logsList.headerTitle"
    static let headerSubtitle = "logsList.headerSubtitle"

    // Log Cards
    static func logCard(_ logID: String) -> String {
        "logsList.logCard.\(logID)"
    }
    static func featuredLogCard(_ index: Int) -> String {
        "logsList.featuredLogCard.\(index)"
    }
    static func compactLogCard(_ logID: String) -> String {
        "logsList.compactLogCard.\(logID)"
    }
}

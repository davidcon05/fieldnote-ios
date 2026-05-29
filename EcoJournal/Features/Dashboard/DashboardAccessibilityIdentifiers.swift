//
//  DashboardAccessibilityIdentifiers.swift
//  EcoJournal
//
//  Accessibility identifiers for Dashboard feature
//

import Foundation

enum DashboardAccessibilityIdentifiers {
    // Main Elements
    static let dashboardTitle = "dashboard.title"
    static let newJournalButton = "dashboard.newJournalButton"
    static let searchField = "dashboard.searchField"
    static let filterButton = "dashboard.filterButton"

    // Empty State
    static let emptyStateIcon = "dashboard.emptyState.icon"
    static let emptyStateTitle = "dashboard.emptyState.title"
    static let emptyStateMessage = "dashboard.emptyState.message"

    // Journal Card
    static func journalCard(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID)"
    }
    static func journalCardTitle(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID).title"
    }
    static func journalCardDate(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID).date"
    }
    static func journalCardLogCount(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID).logCount"
    }
    static func journalCardLockIcon(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID).lockIcon"
    }
    static func journalCardSettingsButton(_ journalID: String) -> String {
        "dashboard.journalCard.\(journalID).settingsButton"
    }

    // Create Journal Sheet
    static let createJournalSheet = "dashboard.createJournalSheet"
    static let createJournalSheetTitle = "dashboard.createJournalSheet.title"
    static let createJournalNameLabel = "dashboard.createJournalSheet.nameLabel"
    static let createJournalNameField = "dashboard.createJournalSheet.nameField"
    static let createJournalCreateButton = "dashboard.createJournalSheet.createButton"
    static let createJournalDescription = "dashboard.createJournalSheet.description"

    // Filter Sheet
    static let filterSheet = "dashboard.filterSheet"
    static let filterSheetTitle = "dashboard.filterSheet.title"
    static let filterOptionMostRecent = "dashboard.filterSheet.option.mostRecent"
    static let filterOptionOldestFirst = "dashboard.filterSheet.option.oldestFirst"
    static let filterOptionAToZ = "dashboard.filterSheet.option.aToZ"
    static let filterOptionZToA = "dashboard.filterSheet.option.zToA"
}

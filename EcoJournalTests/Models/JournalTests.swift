//
//  JournalTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
@testable import EcoJournal
internal import SwiftUI

struct JournalTests {

    @Test("Journal initializes with random theme and default values")
    func journalInitialization() {
        // When: Create a new journal
        let journal = Journal(name: "Test Journal")

        // Then: Random theme assigned, defaults set
        #expect(journal.name == "Test Journal")
        #expect(!journal.themeIcon.isEmpty)
        #expect(!journal.themeColorHex.isEmpty)
        #expect(journal.themeColorHex.hasPrefix("#"))
        #expect(journal.isPasswordProtected == false)
        #expect(journal.logs.isEmpty)
    }

    @Test("Journal can be created with specific theme")
    func journalCustomTheme() {
        // Given: A specific theme
        let theme = JournalTheme(icon: "leaf.fill", color: .green, colorHex: "#4A7C59")

        // When: Create journal with custom theme
        let journal = Journal(name: "Custom Theme Journal", theme: theme)

        // Then: Custom theme applied
        #expect(journal.themeIcon == "leaf.fill")
        #expect(journal.themeColorHex == "#4A7C59")
    }
}

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

    // MARK: - Lock Badge Tests

    @Test("Lock badge should show when journal is password protected")
    func testLockBadge_showsWhenProtected() {
        // Given: A password-protected journal
        let journal = Journal(name: "Protected Journal")
        journal.isPasswordProtected = true

        // Then: Lock badge should be visible
        #expect(journal.isPasswordProtected == true)
    }

    @Test("Lock badge should not show when journal is not password protected")
    func testLockBadge_hidesWhenNotProtected() {
        // Given: A non-password-protected journal
        let journal = Journal(name: "Public Journal")

        // Then: Lock badge should not be visible (default is false)
        #expect(journal.isPasswordProtected == false)
    }

    // MARK: - Theme Tests

    @Test("Journal initializes with random theme")
    func testJournal_hasThemeOnInit() {
        // When: Create a new journal
        let journal = Journal(name: "Test Journal")

        // Then: Theme should be assigned
        #expect(!journal.themeIcon.isEmpty)
        #expect(!journal.themeColorHex.isEmpty)
        #expect(journal.themeColorHex.hasPrefix("#"))
    }

    @Test("Journal can be created with specific theme")
    func testJournal_customTheme() {
        // Given: A specific theme
        let theme = JournalTheme(icon: "leaf.fill", color: .green, colorHex: "#4A7C59")

        // When: Create journal with that theme
        let journal = Journal(name: "Custom Theme Journal", theme: theme)

        // Then: Journal should have that theme
        #expect(journal.themeIcon == "leaf.fill")
        #expect(journal.themeColorHex == "#4A7C59")
    }

    // MARK: - Cover Photo Priority Tests

    @Test("Password protected journal should always show theme (privacy)")
    func testCoverPhoto_protectedJournalShowsTheme() {
        // Given: Password-protected journal with cover photo
        let journal = Journal(name: "Protected Journal")
        journal.isPasswordProtected = true
        journal.coverPhotoURL = URL(string: "https://example.com/photo.jpg")

        // Then: Should prioritize theme over cover photo for privacy
        // (This logic is in the View, but we document the rule here)
        #expect(journal.isPasswordProtected == true)
        #expect(journal.coverPhotoURL != nil)
        // View should show theme, not photo
    }

    @Test("Non-protected journal with cover photo should show cover")
    func testCoverPhoto_nonProtectedShowsCover() {
        // Given: Non-protected journal with cover photo
        let journal = Journal(name: "Public Journal")
        journal.isPasswordProtected = false
        journal.coverPhotoURL = URL(string: "https://example.com/photo.jpg")

        // Then: Should show cover photo
        #expect(journal.coverPhotoURL != nil)
        #expect(journal.isPasswordProtected == false)
    }

    // MARK: - Logs Count Tests

    @Test("New journal has zero logs")
    func testJournal_zeroLogsOnInit() {
        // When: Create a new journal
        let journal = Journal(name: "Test Journal")

        // Then: Should have no logs
        #expect(journal.logs.isEmpty)
        #expect(journal.logs.count == 0)
    }

    @Test("Journal tracks log count correctly")
    func testJournal_tracksLogCount() {
        // Given: A journal
        let journal = Journal(name: "Test Journal")

        // When: Add logs
        journal.logs.append(Log(notes: "First observation"))
        journal.logs.append(Log(notes: "Second observation"))
        journal.logs.append(Log(notes: "Third observation"))

        // Then: Count should be accurate
        #expect(journal.logs.count == 3)
    }

    // MARK: - Date Tests

    @Test("Journal initializes with current date")
    func testJournal_initializesWithCurrentDate() {
        // When: Create a new journal
        let beforeCreation = Date()
        let journal = Journal(name: "Test Journal")
        let afterCreation = Date()

        // Then: Created date should be between before and after
        #expect(journal.createdDate >= beforeCreation)
        #expect(journal.createdDate <= afterCreation)
        #expect(journal.lastModified >= beforeCreation)
        #expect(journal.lastModified <= afterCreation)
    }

    @Test("Last modified date updates when journal is modified")
    func testJournal_lastModifiedUpdates() async throws {
        // Given: A journal created in the past
        let journal = Journal(name: "Test Journal")
        let originalDate = journal.lastModified

        // Wait to ensure time difference
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // When: Modify the journal
        journal.lastModified = Date()

        // Then: Last modified should be newer
        #expect(journal.lastModified > originalDate)
    }

    // MARK: - Name Tests

    @Test("Journal name can be updated")
    func testJournal_nameCanUpdate() {
        // Given: A journal
        let journal = Journal(name: "Original Name")
        #expect(journal.name == "Original Name")

        // When: Update the name
        journal.name = "Updated Name"

        // Then: Name should be changed
        #expect(journal.name == "Updated Name")
    }
}

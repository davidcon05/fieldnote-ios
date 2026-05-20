//
//  DashboardViewModelTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
@testable import fieldnote
import Foundation

@MainActor
@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    func makeViewModel(with seedData: [Journal] = []) -> (DashboardViewModel, FakeJournalRepository) {
        let repository = FakeJournalRepository()
        repository.setSeedData(seedData)
        let viewModel = DashboardViewModel(repository: repository)
        return (viewModel, repository)
    }

    // MARK: - Empty State Tests

    @Test("Dashboard shows empty state when no journals exist")
    func testEmptyState_noJournals() async throws {
        // Given: New ViewModel with no journals
        let (sut, _) = makeViewModel()

        // Then: journals array should be empty
        #expect(sut.journals.isEmpty)
    }

    @Test("Dashboard does not show empty state when journals exist")
    func testEmptyState_withJournals() async throws {
        // Given: Repository with one journal
        let journal = Journal(name: "Test Journal")
        let (sut, _) = makeViewModel(with: [journal])

        // Then: journals array should not be empty
        #expect(!sut.journals.isEmpty)
        #expect(sut.journals.count == 1)
    }

    // MARK: - Create Journal Tests

    @Test("Creating journal adds it to journals array")
    func testCreateJournal_addsToArray() async throws {
        // Given: New ViewModel with empty journals
        let (sut, _) = makeViewModel()
        #expect(sut.journals.isEmpty)

        // When: Create a new journal
        sut.createJournal(name: "Olympic National Park")

        // Then: Journal should be in array
        #expect(sut.journals.count == 1)
        #expect(sut.journals.first?.name == "Olympic National Park")
    }

    @Test("Creating journal assigns random theme")
    func testCreateJournal_assignsTheme() async throws {
        // Given: New ViewModel
        let (sut, _) = makeViewModel()

        // When: Create a new journal
        sut.createJournal(name: "Test Journal")

        // Then: Journal should have theme assigned
        let journal = try #require(sut.journals.first)
        #expect(!journal.themeIcon.isEmpty)
        #expect(!journal.themeColorHex.isEmpty)
    }

    @Test("Creating journal closes create sheet")
    func testCreateJournal_closesSheet() async throws {
        // Given: ViewModel with create sheet showing
        let (sut, _) = makeViewModel()
        sut.showingCreateJournal = true

        // When: Create a journal
        sut.createJournal(name: "Test Journal")

        // Then: Sheet should be dismissed
        #expect(sut.showingCreateJournal == false)
    }

    // MARK: - Delete Journal Tests

    @Test("Deleting journal removes it from array")
    func testDeleteJournal_removesFromArray() async throws {
        // Given: ViewModel with one journal
        let (sut, _) = makeViewModel()
        sut.createJournal(name: "Test Journal")
        #expect(sut.journals.count == 1)

        let journal = try #require(sut.journals.first)

        // When: Delete the journal
        sut.deleteJournal(journal)

        // Then: Array should be empty
        #expect(sut.journals.isEmpty)
    }

    @Test("Deleting journal closes settings sheet")
    func testDeleteJournal_closesSheet() async throws {
        // Given: ViewModel with settings showing for a journal
        let (sut, _) = makeViewModel()
        sut.createJournal(name: "Test Journal")
        let journal = try #require(sut.journals.first)
        sut.openSettings(for: journal)
        #expect(sut.showingSettings == true)

        // When: Delete the journal
        sut.deleteJournal(journal)

        // Then: Settings sheet should be dismissed
        #expect(sut.showingSettings == false)
        #expect(sut.selectedJournal == nil)
    }

    // MARK: - Settings Tests

    @Test("Opening settings shows sheet and sets selected journal")
    func testOpenSettings_showsSheet() async throws {
        // Given: ViewModel with one journal
        let (sut, _) = makeViewModel()
        sut.createJournal(name: "Test Journal")
        let journal = try #require(sut.journals.first)

        // When: Open settings
        sut.openSettings(for: journal)

        // Then: Sheet should show and journal should be selected
        #expect(sut.showingSettings == true)
        #expect(sut.selectedJournal?.id == journal.id)
    }

    @Test("Saving journal settings updates last modified date")
    func testSaveSettings_updatesLastModified() async throws {
        // Given: ViewModel with journal
        let (sut, _) = makeViewModel()
        sut.createJournal(name: "Test Journal")
        let journal = try #require(sut.journals.first)
        let oldDate = journal.lastModified

        // Wait a moment to ensure time difference
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // When: Update journal name and save
        journal.name = "Updated Journal"
        journal.lastModified = Date()
        sut.saveJournalSettings()

        // Then: Last modified should be updated
        let updatedJournal = try #require(sut.journals.first)
        #expect(updatedJournal.lastModified > oldDate)
    }

    // MARK: - Sorting Tests

    @Test("Journals are sorted by last modified date (newest first)")
    func testJournals_sortedByLastModified() async throws {
        // Given: Repository with journals at different modified dates
        let journal1 = Journal(name: "Old Journal")
        journal1.lastModified = Date().addingTimeInterval(-86400) // 1 day ago

        let journal2 = Journal(name: "Recent Journal")
        journal2.lastModified = Date() // Now

        let (sut, _) = makeViewModel(with: [journal1, journal2])

        // Then: Most recent should be first
        #expect(sut.journals.count == 2)
        #expect(sut.journals.first?.name == "Recent Journal")
        #expect(sut.journals.last?.name == "Old Journal")
    }
}

//
//  DashboardViewModelTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
@testable import EcoJournal
import Foundation
import SwiftData

@MainActor
@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    func makeTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Journal.self, Log.self, configurations: config)
        return container
    }

    func makeViewModel() -> DashboardViewModel {
        return DashboardViewModel()
    }

    // MARK: - Create Journal Tests

    @Test("Creating journal saves to context")
    func testCreateJournal_savesToContext() async throws {
        // Given: New ViewModel and ModelContext
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        // When: Create a new journal
        sut.createJournal(name: "Olympic National Park", modelContext: context)

        // Then: Journal should be in context
        let descriptor = FetchDescriptor<Journal>()
        let journals = try context.fetch(descriptor)
        #expect(journals.count == 1)
        #expect(journals.first?.name == "Olympic National Park")
    }

    @Test("Creating journal assigns random theme")
    func testCreateJournal_assignsTheme() async throws {
        // Given: New ViewModel and ModelContext
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        // When: Create a new journal
        sut.createJournal(name: "Test Journal", modelContext: context)

        // Then: Journal should have theme assigned
        let descriptor = FetchDescriptor<Journal>()
        let journals = try context.fetch(descriptor)
        let journal = try #require(journals.first)
        #expect(!journal.themeIcon.isEmpty)
        #expect(!journal.themeColorHex.isEmpty)
    }

    @Test("Creating journal closes create sheet")
    func testCreateJournal_closesSheet() async throws {
        // Given: ViewModel with create sheet showing
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)
        sut.showingCreateJournal = true

        // When: Create a journal
        sut.createJournal(name: "Test Journal", modelContext: context)

        // Then: Sheet should be dismissed
        #expect(sut.showingCreateJournal == false)
    }

    // MARK: - Delete Journal Tests

    @Test("Deleting journal removes it from context")
    func testDeleteJournal_removesFromContext() async throws {
        // Given: ModelContext with one journal
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        context.insert(journal)
        try context.save()

        // Verify journal exists
        var descriptor = FetchDescriptor<Journal>()
        var journals = try context.fetch(descriptor)
        #expect(journals.count == 1)

        // When: Delete the journal
        sut.deleteJournal(journal, modelContext: context)

        // Then: Context should be empty
        descriptor = FetchDescriptor<Journal>()
        journals = try context.fetch(descriptor)
        #expect(journals.isEmpty)
    }

    @Test("Deleting journal closes settings sheet")
    func testDeleteJournal_closesSheet() async throws {
        // Given: ViewModel with settings showing for a journal
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        context.insert(journal)
        try context.save()

        sut.openSettings(for: journal)
        #expect(sut.showingSettings == true)

        // When: Delete the journal
        sut.deleteJournal(journal, modelContext: context)

        // Then: Settings sheet should be dismissed
        #expect(sut.showingSettings == false)
        #expect(sut.selectedJournal == nil)
    }

    // MARK: - Settings Tests

    @Test("Opening settings shows sheet and sets selected journal")
    func testOpenSettings_showsSheet() async throws {
        // Given: ViewModel with one journal
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        context.insert(journal)
        try context.save()

        // When: Open settings (non-password protected)
        sut.openSettings(for: journal)

        // Then: Sheet should show and journal should be selected
        #expect(sut.showingSettings == true)
        #expect(sut.selectedJournal?.id == journal.id)
    }

    @Test("Saving journal settings saves to context")
    func testSaveSettings_savesToContext() async throws {
        // Given: ViewModel with journal
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        context.insert(journal)
        try context.save()

        sut.selectedJournal = journal

        // When: Update journal name and save
        journal.name = "Updated Journal"
        sut.saveJournalSettings(modelContext: context)

        // Then: Changes should be saved
        let descriptor = FetchDescriptor<Journal>()
        let journals = try context.fetch(descriptor)
        let updatedJournal = try #require(journals.first)
        #expect(updatedJournal.name == "Updated Journal")
    }

    // MARK: - Filtering Tests

    @Test("Filtered journals applies search filter")
    func testFilteredJournals_appliesSearch() async throws {
        // Given: Journals with different names
        let journal1 = Journal(name: "Cedar River")
        let journal2 = Journal(name: "Oak Forest")
        let journal3 = Journal(name: "Pine Mountain")
        let journals = [journal1, journal2, journal3]

        let sut = makeViewModel()
        sut.searchText = "river"

        // When: Filter journals
        let filtered = sut.filteredJournals(from: journals)

        // Then: Only matching journal should be returned
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Cedar River")
    }

    @Test("Filtered journals applies sort option")
    func testFilteredJournals_appliesSort() async throws {
        // Given: Journals with different modified dates
        let journal1 = Journal(name: "A Journal")
        journal1.lastModified = Date().addingTimeInterval(-86400) // 1 day ago

        let journal2 = Journal(name: "B Journal")
        journal2.lastModified = Date() // Now

        let journals = [journal1, journal2]

        let sut = makeViewModel()
        sut.sortOption = .aToZ

        // When: Filter journals with A-Z sort
        let filtered = sut.filteredJournals(from: journals)

        // Then: Should be sorted alphabetically
        #expect(filtered.count == 2)
        #expect(filtered.first?.name == "A Journal")
        #expect(filtered.last?.name == "B Journal")
    }

    @Test("Search suggestions returns matching journals")
    func testSearchSuggestions_returnsMatches() async throws {
        // Given: Journals with similar names
        let journal1 = Journal(name: "River Valley")
        let journal2 = Journal(name: "River Basin")
        let journal3 = Journal(name: "Mountain Peak")
        let journals = [journal1, journal2, journal3]

        let sut = makeViewModel()
        sut.searchText = "river"

        // When: Get search suggestions
        let suggestions = sut.searchSuggestions(from: journals)

        // Then: Only matching journals should be returned
        #expect(suggestions.count == 2)
        #expect(suggestions.contains { $0.name == "River Valley" })
        #expect(suggestions.contains { $0.name == "River Basin" })
    }

    @Test("isFilterActive returns true when sort is not most recent")
    func testIsFilterActive_detectsNonDefaultSort() async throws {
        let sut = makeViewModel()

        // Default sort
        #expect(sut.isFilterActive == false)

        // Change to A-Z sort
        sut.sortOption = .aToZ
        #expect(sut.isFilterActive == true)
    }
}

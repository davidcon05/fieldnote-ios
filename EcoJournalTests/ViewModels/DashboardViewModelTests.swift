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

    // MARK: - Create/Delete Tests

    @Test("Creating journal saves with theme and closes sheet")
    func createJournalFlow() async throws {
        // Given
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)
        sut.showingCreateJournal = true

        // When: Create a new journal
        sut.createJournal(name: "Olympic National Park", modelContext: context)

        // Then: Journal saved with theme, sheet dismissed
        let descriptor = FetchDescriptor<Journal>()
        let journals = try context.fetch(descriptor)
        let journal = try #require(journals.first)
        #expect(journal.name == "Olympic National Park")
        #expect(!journal.themeIcon.isEmpty)
        #expect(!journal.themeColorHex.isEmpty)
        #expect(sut.showingCreateJournal == false)
    }

    @Test("Deleting journal removes from context and closes sheet")
    func deleteJournalFlow() async throws {
        // Given
        let sut = makeViewModel()
        let container = try makeTestContainer()
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        context.insert(journal)
        try context.save()
        sut.openSettings(for: journal)

        // When: Delete the journal
        sut.deleteJournal(journal, modelContext: context)

        // Then: Removed from context, sheet dismissed
        let descriptor = FetchDescriptor<Journal>()
        let journals = try context.fetch(descriptor)
        #expect(journals.isEmpty)
        #expect(sut.showingSettings == false)
        #expect(sut.selectedJournal == nil)
    }

    @Test("Filtering journals applies search and sort")
    func filteringJournals() async throws {
        // Given: Journals with different names and dates
        let journal1 = Journal(name: "River Valley")
        journal1.lastModified = Date().addingTimeInterval(-86400)

        let journal2 = Journal(name: "River Basin")
        journal2.lastModified = Date()

        let journal3 = Journal(name: "Mountain Peak")
        let journals = [journal1, journal2, journal3]

        let sut = makeViewModel()

        // When: Apply search filter
        sut.searchText = "river"
        var filtered = sut.filteredJournals(from: journals)

        // Then: Only matching journals
        #expect(filtered.count == 2)

        // When: Apply alphabetical sort
        sut.searchText = ""
        sut.sortOption = .aToZ
        filtered = sut.filteredJournals(from: journals)

        // Then: Sorted correctly
        #expect(filtered.first?.name == "Mountain Peak")
        #expect(sut.isFilterActive == true)
    }
}

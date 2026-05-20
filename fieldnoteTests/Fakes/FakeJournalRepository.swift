//
//  FakeJournalRepository.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
@testable import fieldnote

final class FakeJournalRepository: JournalRepository {
    private var journals: [Journal] = []

    func fetchAll() throws -> [Journal] {
        // Sort by lastModified (newest first) to match real implementation
        return journals.sorted { $0.lastModified > $1.lastModified }
    }

    func save(_ journal: Journal) throws {
        journals.append(journal)
    }

    func delete(_ journal: Journal) throws {
        journals.removeAll { $0.id == journal.id }
    }

    func update(_ journal: Journal) throws {
        // In-memory reference is already updated, nothing to do
    }

    // Test helpers
    func setSeedData(_ seedJournals: [Journal]) {
        journals = seedJournals
    }

    func clear() {
        journals.removeAll()
    }
}

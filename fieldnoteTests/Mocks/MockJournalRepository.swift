//
//  MockJournalRepository.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
@testable import fieldnote

final class MockJournalRepository: JournalRepository {
    // MARK: - Mock State

    var journals: [Journal] = []
    var shouldFailFetch = false
    var shouldFailSave = false
    var shouldFailDelete = false
    var shouldFailUpdate = false

    var fetchCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var updateCallCount = 0

    // MARK: - JournalRepository Implementation

    func fetchAll() throws -> [Journal] {
        fetchCallCount += 1

        if shouldFailFetch {
            throw MockRepositoryError.fetchFailed
        }

        return journals
    }

    func save(_ journal: Journal) throws {
        saveCallCount += 1

        if shouldFailSave {
            throw MockRepositoryError.saveFailed
        }

        journals.append(journal)
    }

    func delete(_ journal: Journal) throws {
        deleteCallCount += 1

        if shouldFailDelete {
            throw MockRepositoryError.deleteFailed
        }

        journals.removeAll { $0.id == journal.id }
    }

    func update(_ journal: Journal) throws {
        updateCallCount += 1

        if shouldFailUpdate {
            throw MockRepositoryError.updateFailed
        }

        if let index = journals.firstIndex(where: { $0.id == journal.id }) {
            journals[index] = journal
        }
    }

    // MARK: - Test Helpers

    func reset() {
        journals.removeAll()
        shouldFailFetch = false
        shouldFailSave = false
        shouldFailDelete = false
        shouldFailUpdate = false
        fetchCallCount = 0
        saveCallCount = 0
        deleteCallCount = 0
        updateCallCount = 0
    }
}

// MARK: - Mock Errors

enum MockRepositoryError: Error {
    case fetchFailed
    case saveFailed
    case deleteFailed
    case updateFailed
}

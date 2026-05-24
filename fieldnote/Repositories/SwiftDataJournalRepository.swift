//
//  SwiftDataJournalRepository.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
import SwiftData

final class SwiftDataJournalRepository: JournalRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Journal] {
        var descriptor = FetchDescriptor<Journal>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.logs]
        return try modelContext.fetch(descriptor)
    }

    func save(_ journal: Journal) throws {
        modelContext.insert(journal)
        try modelContext.save()
    }

    func delete(_ journal: Journal) throws {
        modelContext.delete(journal)
        try modelContext.save()
    }

    func update(_ journal: Journal) throws {
        try modelContext.save()
    }
}

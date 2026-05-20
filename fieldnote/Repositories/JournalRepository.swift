//
//  JournalRepository.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import Foundation

protocol JournalRepository {
    func fetchAll() throws -> [Journal]
    func save(_ journal: Journal) throws
    func delete(_ journal: Journal) throws
    func update(_ journal: Journal) throws
}

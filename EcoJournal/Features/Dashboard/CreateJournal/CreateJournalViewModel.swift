//
//  CreateJournalViewModel.swift
//  EcoJournal
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI
internal import Combine

@MainActor
final class CreateJournalViewModel: ObservableObject {
    @Published var journalName = ""

    var isValid: Bool {
        !journalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func reset() {
        journalName = ""
    }
}

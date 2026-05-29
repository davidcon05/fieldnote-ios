//
//  Journal.swift
//  EcoJournal
//
//  Created by David Contreras on 5/8/26.
//

import Foundation
import SwiftData

@Model
final class Journal {
    var id: UUID
    var name: String
    var createdDate: Date
    var lastModified: Date
    var coverPhotoURL: URL?

    // Theme (always assigned - serves as fallback and privacy layer)
    var themeIcon: String
    var themeColorHex: String

    // Privacy
    var isPasswordProtected: Bool

    @Relationship(deleteRule: .cascade, inverse: \Log.journal)
    var logs: [Log]

    init(name: String, coverPhotoURL: URL? = nil, theme: JournalTheme? = nil) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.lastModified = Date()
        self.coverPhotoURL = coverPhotoURL

        // Assign theme (random if not specified)
        let selectedTheme = theme ?? JournalTheme.random()
        self.themeIcon = selectedTheme.icon
        self.themeColorHex = selectedTheme.colorHex

        self.isPasswordProtected = false
        self.logs = []
    }

    func touch() {
        self.lastModified = Date()
    }
}

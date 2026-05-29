//
//  Log.swift
//  EcoJournal
//
//  Created by David Contreras on 5/8/26.
//

import Foundation
import SwiftData

@Model
final class Log {
    var id: UUID
    var timestamp: Date

    var title: String = "Untitled Entry" // Required field - the only requirement for a log entry
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?

    var weather: Weather?

    var notes: String
    var mediaURLs: [URL]

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \AudioMemo.log)
    var audioMemos: [AudioMemo] = []

    var journal: Journal?

    init(title: String = "", notes: String = "", mediaURLs: [URL] = []) {
        self.id = UUID()
        self.timestamp = Date()
        self.title = title
        self.notes = notes
        self.mediaURLs = mediaURLs
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

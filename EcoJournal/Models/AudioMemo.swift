//
//  AudioMemo.swift
//  EcoJournal
//
//  Created by David Contreras on 5/19/26.
//

import Foundation
import SwiftData

@Model
final class AudioMemo {
    var id: UUID
    var title: String // e.g., "Soil Moisture", "Ambient Acoustics"
    var audioURL: URL
    var transcription: String?
    var timestamp: Date
    var duration: TimeInterval // in seconds

    var log: Log?

    init(title: String = "Voice Memo", audioURL: URL, transcription: String? = nil, duration: TimeInterval = 0) {
        self.id = UUID()
        self.title = title
        self.audioURL = audioURL
        self.transcription = transcription
        self.timestamp = Date()
        self.duration = duration
    }
}

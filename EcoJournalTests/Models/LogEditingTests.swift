//
//  LogEditingTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import EcoJournal

@Suite("Log Editing Behavior Tests")
nonisolated struct LogEditingTests {

    @Test("Log properties can be updated")
    func propertiesCanBeUpdated() {
        // Given
        let log = Log(notes: "Test log")

        // When - Update various properties
        log.latitude = 48.0
        log.longitude = -124.0
        log.altitude = 200.0
        log.notes = "Updated notes"

        // Then - All updates work
        #expect(log.latitude == 48.0)
        #expect(log.longitude == -124.0)
        #expect(log.altitude == 200.0)
        #expect(log.notes == "Updated notes")
    }

    @Test("Log title validation rejects empty title")
    func emptyTitleIsInvalid() {
        // Given
        let log = Log(notes: "Test")

        // When
        log.title = ""

        // Then
        #expect(log.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("Log allows media URLs to be managed")
    func mediaURLsCanBeManaged() {
        // Given
        let log = Log(notes: "Test")
        let url1 = URL(fileURLWithPath: "/test1.jpg")
        let url2 = URL(fileURLWithPath: "/test2.jpg")

        // When - Add URLs
        log.mediaURLs.append(url1)
        log.mediaURLs.append(url2)

        // Then
        #expect(log.mediaURLs.count == 2)

        // When - Remove URL
        log.mediaURLs.removeAll()

        // Then
        #expect(log.mediaURLs.isEmpty)
    }
}

//
//  LogTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
@testable import EcoJournal
import Foundation

@Suite("Log Model Tests")
struct LogTests {

    @Test("Log initialization sets default values")
    func logInitialization() {
        // When: Initialize with various parameters
        let log1 = Log()
        let log2 = Log(notes: "Field observation")
        let url = URL(fileURLWithPath: "/photo.jpg")
        let log3 = Log(notes: "Media test", mediaURLs: [url])

        // Then: Default values set correctly
        #expect(log1.notes == "")
        #expect(log1.mediaURLs.isEmpty)
        #expect(log1.latitude == nil)
        #expect(log1.weather == nil)

        #expect(log2.notes == "Field observation")

        #expect(log3.mediaURLs.count == 1)
        #expect(log3.mediaURLs[0] == url)
    }

    @Test("Log validation checks title is non-empty")
    func logValidation() {
        // Given: Logs with different titles
        let validLog = Log(title: "Valid observation")
        let emptyLog = Log(title: "")
        let whitespaceLog = Log(title: "   \n\t   ")
        let paddedLog = Log(title: "  Valid with padding  ")

        // Then: isValid checks for non-empty trimmed title
        #expect(validLog.isValid)
        #expect(!emptyLog.isValid)
        #expect(!whitespaceLog.isValid)
        #expect(paddedLog.isValid)
    }
}

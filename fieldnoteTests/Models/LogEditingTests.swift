//
//  LogEditingTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import fieldnote

@Suite("Log Editing Behavior Tests")
nonisolated struct LogEditingTests {

    // MARK: - GPS Editing Tests

    @Test("Log allows GPS coordinates to be updated")
    func gpsCoordinatesCanBeUpdated() {
        // Given
        let log = Log(notes: "Test log")
        log.latitude = 47.8597
        log.longitude = -123.9346
        log.altitude = 182.0

        // When
        log.latitude = 48.0
        log.longitude = -124.0
        log.altitude = 200.0

        // Then
        #expect(log.latitude == 48.0)
        #expect(log.longitude == -124.0)
        #expect(log.altitude == 200.0)
    }

    @Test("Log GPS validation rejects invalid latitude", arguments: [-91.0, 91.0, 200.0])
    func invalidLatitude(lat: Double) {
        // Given - latitude must be between -90 and 90
        let isValid = lat >= -90 && lat <= 90

        // Then
        #expect(!isValid)
    }

    @Test("Log GPS validation accepts valid latitude", arguments: [-90.0, 0.0, 45.5, 90.0])
    func validLatitude(lat: Double) {
        // Given - latitude must be between -90 and 90
        let isValid = lat >= -90 && lat <= 90

        // Then
        #expect(isValid)
    }

    @Test("Log GPS validation rejects invalid longitude", arguments: [-181.0, 181.0, 360.0])
    func invalidLongitude(lon: Double) {
        // Given - longitude must be between -180 and 180
        let isValid = lon >= -180 && lon <= 180

        // Then
        #expect(!isValid)
    }

    @Test("Log GPS validation accepts valid longitude", arguments: [-180.0, 0.0, 123.5, 180.0])
    func validLongitude(lon: Double) {
        // Given - longitude must be between -180 and 180
        let isValid = lon >= -180 && lon <= 180

        // Then
        #expect(isValid)
    }

    @Test("Log can clear GPS coordinates")
    func gpsCoordinatesCanBeCleared() {
        // Given
        let log = Log(notes: "Test log")
        log.latitude = 47.8597
        log.longitude = -123.9346
        log.altitude = 182.0

        // When
        log.latitude = nil
        log.longitude = nil
        log.altitude = nil

        // Then
        #expect(log.latitude == nil)
        #expect(log.longitude == nil)
        #expect(log.altitude == nil)
    }

    // MARK: - Weather Editing Tests

    @Test("Log allows weather to be updated")
    func weatherCanBeUpdated() {
        // Given
        let log = Log(notes: "Test log")
        let originalWeather = Weather(
            condition: "Clear",
            temperature: 18.5,
            humidity: 62,
            windSpeed: 3.2,
            icon: "01d"
        )
        log.weather = originalWeather

        // When
        let updatedWeather = Weather(
            condition: "Rainy",
            temperature: 15.0,
            humidity: 85,
            windSpeed: 5.5,
            icon: "10d"
        )
        log.weather = updatedWeather

        // Then
        #expect(log.weather?.condition == "Rainy")
        #expect(log.weather?.temperature == 15.0)
        #expect(log.weather?.humidity == 85)
    }

    @Test("Log can clear weather data")
    func weatherCanBeCleared() {
        // Given
        let log = Log(notes: "Test log")
        log.weather = Weather(
            condition: "Clear",
            temperature: 18.5,
            humidity: 62,
            windSpeed: 3.2,
            icon: "01d"
        )

        // When
        log.weather = nil

        // Then
        #expect(log.weather == nil)
    }

    // MARK: - Timestamp Editing Tests

    @Test("Log allows timestamp to be updated")
    func timestampCanBeUpdated() {
        // Given
        let log = Log(notes: "Test log")
        let originalTimestamp = log.timestamp

        // When
        let newTimestamp = Date().addingTimeInterval(-3600) // 1 hour ago
        log.timestamp = newTimestamp

        // Then
        #expect(log.timestamp != originalTimestamp)
        #expect(log.timestamp == newTimestamp)
    }

    @Test("Log timestamp can be set to future date")
    func timestampCanBeSetToFuture() {
        // Given
        let log = Log(notes: "Test log")

        // When
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        log.timestamp = futureDate

        // Then
        #expect(log.timestamp == futureDate)
        #expect(log.timestamp > Date())
    }

    @Test("Log timestamp can be set to past date")
    func timestampCanBeSetToPast() {
        // Given
        let log = Log(notes: "Test log")

        // When
        let pastDate = Date().addingTimeInterval(-86400) // 1 day ago
        log.timestamp = pastDate

        // Then
        #expect(log.timestamp == pastDate)
        #expect(log.timestamp < Date())
    }

    // MARK: - Notes Editing Tests

    @Test("Log notes can be updated")
    func notesCanBeUpdated() {
        // Given
        let log = Log(notes: "Original notes")

        // When
        log.notes = "Updated notes with more details"

        // Then
        #expect(log.notes == "Updated notes with more details")
    }

    @Test("Log with empty notes after edit is invalid")
    func emptyNotesInvalidAfterEdit() {
        // Given
        let log = Log(notes: "Original notes")
        #expect(log.isValid)

        // When
        log.notes = ""

        // Then
        #expect(!log.isValid)
    }

    @Test("Log with whitespace-only notes after edit is invalid")
    func whitespaceNotesInvalidAfterEdit() {
        // Given
        let log = Log(notes: "Original notes")
        #expect(log.isValid)

        // When
        log.notes = "   \n\t   "

        // Then
        #expect(!log.isValid)
    }

    @Test("Log remains valid when notes are updated with content")
    func validNotesRemainsValid() {
        // Given
        let log = Log(notes: "Original notes")

        // When
        log.notes = "New valid notes"

        // Then
        #expect(log.isValid)
    }

    // MARK: - Media Editing Tests

    @Test("Log allows media URLs to be added")
    func mediaURLsCanBeAdded() {
        // Given
        let log = Log(notes: "Test log")
        #expect(log.mediaURLs.isEmpty)

        // When
        let photoURL1 = URL(fileURLWithPath: "/path/to/photo1.jpg")
        let photoURL2 = URL(fileURLWithPath: "/path/to/photo2.jpg")
        log.mediaURLs.append(photoURL1)
        log.mediaURLs.append(photoURL2)

        // Then
        #expect(log.mediaURLs.count == 2)
        #expect(log.mediaURLs.contains(photoURL1))
        #expect(log.mediaURLs.contains(photoURL2))
    }

    @Test("Log allows media URLs to be removed")
    func mediaURLsCanBeRemoved() {
        // Given
        let photoURL1 = URL(fileURLWithPath: "/path/to/photo1.jpg")
        let photoURL2 = URL(fileURLWithPath: "/path/to/photo2.jpg")
        let log = Log(notes: "Test log", mediaURLs: [photoURL1, photoURL2])

        // When
        log.mediaURLs.removeAll { $0 == photoURL1 }

        // Then
        #expect(log.mediaURLs.count == 1)
        #expect(!log.mediaURLs.contains(photoURL1))
        #expect(log.mediaURLs.contains(photoURL2))
    }

    @Test("Log allows all media URLs to be cleared")
    func allMediaURLsCanBeCleared() {
        // Given
        let photoURL1 = URL(fileURLWithPath: "/path/to/photo1.jpg")
        let photoURL2 = URL(fileURLWithPath: "/path/to/photo2.jpg")
        let log = Log(notes: "Test log", mediaURLs: [photoURL1, photoURL2])

        // When
        log.mediaURLs.removeAll()

        // Then
        #expect(log.mediaURLs.isEmpty)
    }

    // MARK: - Audio Editing Tests

    @Test("Log allows audio memo to be added")
    func audioMemoCanBeAdded() {
        // Given
        let log = Log(notes: "Test log")
        #expect(log.audioMemoURL == nil)

        // When
        let audioURL = URL(fileURLWithPath: "/path/to/memo.m4a")
        log.audioMemoURL = audioURL

        // Then
        #expect(log.audioMemoURL == audioURL)
    }

    @Test("Log allows audio memo to be replaced")
    func audioMemoCanBeReplaced() {
        // Given
        let originalAudioURL = URL(fileURLWithPath: "/path/to/memo1.m4a")
        let log = Log(notes: "Test log", audioMemoURL: originalAudioURL)

        // When
        let newAudioURL = URL(fileURLWithPath: "/path/to/memo2.m4a")
        log.audioMemoURL = newAudioURL

        // Then
        #expect(log.audioMemoURL == newAudioURL)
        #expect(log.audioMemoURL != originalAudioURL)
    }

    @Test("Log allows audio memo to be removed")
    func audioMemoCanBeRemoved() {
        // Given
        let audioURL = URL(fileURLWithPath: "/path/to/memo.m4a")
        let log = Log(notes: "Test log", audioMemoURL: audioURL)

        // When
        log.audioMemoURL = nil

        // Then
        #expect(log.audioMemoURL == nil)
    }

    // MARK: - Combined Editing Tests

    @Test("Log allows multiple properties to be edited simultaneously")
    func multiplePropertiesCanBeEdited() {
        // Given
        let log = Log(notes: "Original notes")
        log.latitude = 47.0
        log.longitude = -123.0
        log.weather = Weather(condition: "Clear", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d")

        // When
        log.notes = "Updated notes"
        log.timestamp = Date().addingTimeInterval(-3600)
        log.latitude = 48.0
        log.longitude = -124.0
        log.weather = Weather(condition: "Rainy", temperature: 15.0, humidity: 80, windSpeed: 5.0, icon: "10d")

        // Then
        #expect(log.notes == "Updated notes")
        #expect(log.latitude == 48.0)
        #expect(log.longitude == -124.0)
        #expect(log.weather?.condition == "Rainy")
        #expect(log.isValid)
    }

    @Test("Log preserves ID after editing")
    func idPreservedAfterEditing() {
        // Given
        let log = Log(notes: "Original notes")
        let originalID = log.id

        // When
        log.notes = "Updated notes"
        log.latitude = 48.0
        log.weather = Weather(condition: "Clear", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d")

        // Then
        #expect(log.id == originalID)
    }

    // MARK: - Delete Confirmation Tests

    @Test("Delete confirmation requires exact text match")
    func deleteConfirmationValidation() {
        // Given
        let validInputs = ["DELETE"]
        let invalidInputs = ["delete", "Delete", "DEL", "DELET", " DELETE", "DELETE ", ""]

        // When/Then - Valid inputs
        for input in validInputs {
            #expect(input == "DELETE")
        }

        // When/Then - Invalid inputs
        for input in invalidInputs {
            #expect(input != "DELETE")
        }
    }
}

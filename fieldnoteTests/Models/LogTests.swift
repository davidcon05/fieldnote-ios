//
//  LogTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
@testable import fieldnote
import Foundation

@Suite("Log Model Tests")
struct LogTests {

    // MARK: - Initialization Tests

    @Test("Initialize log with default parameters creates log with empty notes")
    func initWithDefaultParameters() {
        // When
        let log = Log()

        // Then
        #expect(log.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        #expect(log.notes == "")
        #expect(log.mediaURLs.isEmpty)
        #expect(log.audioMemoURL == nil)
        #expect(log.latitude == nil)
        #expect(log.longitude == nil)
        #expect(log.altitude == nil)
        #expect(log.weather == nil)
        #expect(log.journal == nil)
    }

    @Test("Initialize log with notes creates log with notes")
    func initWithNotes() {
        // Given
        let notes = "Found moss samples in rain forest"

        // When
        let log = Log(notes: notes)

        // Then
        #expect(log.notes == notes)
        #expect(log.mediaURLs.isEmpty)
        #expect(log.audioMemoURL == nil)
    }

    @Test("Initialize log with media URLs creates log with media")
    func initWithMediaURLs() {
        // Given
        let url1 = URL(fileURLWithPath: "/path/to/photo1.jpg")
        let url2 = URL(fileURLWithPath: "/path/to/photo2.jpg")
        let mediaURLs = [url1, url2]

        // When
        let log = Log(notes: "Test", mediaURLs: mediaURLs)

        // Then
        #expect(log.mediaURLs.count == 2)
        #expect(log.mediaURLs == mediaURLs)
    }

    @Test("Initialize log with audio memo creates log with audio")
    func initWithAudioMemo() {
        // Given
        let audioURL = URL(fileURLWithPath: "/path/to/memo.m4a")

        // When
        let log = Log(notes: "Test", audioMemoURL: audioURL)

        // Then
        #expect(log.audioMemoURL == audioURL)
    }

    // MARK: - Validation Tests

    @Test("Log with non-empty notes is valid")
    func validWithNonEmptyNotes() {
        // Given
        let log = Log(notes: "Valid observation notes")

        // Then
        #expect(log.isValid)
    }

    @Test("Log with empty notes is invalid")
    func invalidWithEmptyNotes() {
        // Given
        let log = Log(notes: "")

        // Then
        #expect(!log.isValid)
    }

    @Test("Log with whitespace-only notes is invalid")
    func invalidWithWhitespaceOnlyNotes() {
        // Given
        let log = Log(notes: "   \n\t   ")

        // Then
        #expect(!log.isValid)
    }

    @Test("Log with notes containing whitespace padding is valid")
    func validWithNotesContainingWhitespace() {
        // Given
        let log = Log(notes: "  Valid notes with padding  ")

        // Then
        #expect(log.isValid)
    }

    // MARK: - GPS Data Tests

    @Test("GPS data can be set and retrieved")
    func gpsDataCanBeSetAndRetrieved() {
        // Given
        let log = Log(notes: "GPS test")
        let latitude = 47.8597
        let longitude = -123.9346
        let altitude = 182.0

        // When
        log.latitude = latitude
        log.longitude = longitude
        log.altitude = altitude

        // Then
        #expect(log.latitude == latitude)
        #expect(log.longitude == longitude)
        #expect(log.altitude == altitude)
    }

    @Test("GPS data defaults to nil")
    func gpsDataDefaultsToNil() {
        // Given / When
        let log = Log()

        // Then
        #expect(log.latitude == nil)
        #expect(log.longitude == nil)
        #expect(log.altitude == nil)
    }

    // MARK: - Weather Data Tests

    @Test("Weather data can be set and retrieved")
    func weatherDataCanBeSetAndRetrieved() {
        // Given
        let log = Log(notes: "Weather test")
        let weather = Weather(
            condition: "Rain",
            temperature: 12.5,
            humidity: 95,
            windSpeed: 2.1,
            icon: "10d",
            aqi: 1,
            pm25: 8.5,
            pm10: 12.3
        )

        // When
        log.weather = weather

        // Then
        #expect(log.weather != nil)
        #expect(log.weather?.condition == "Rain")
        #expect(log.weather?.temperature == 12.5)
        #expect(log.weather?.aqi == 1)
    }

    @Test("Weather data defaults to nil")
    func weatherDataDefaultsToNil() {
        // Given / When
        let log = Log()

        // Then
        #expect(log.weather == nil)
    }

    // MARK: - Timestamp Tests

    @Test("Timestamp is set on initialization")
    func timestampIsSetOnInitialization() {
        // Given
        let beforeCreation = Date()

        // When
        let log = Log(notes: "Timestamp test")

        // Then
        let afterCreation = Date()
        #expect(log.timestamp >= beforeCreation)
        #expect(log.timestamp <= afterCreation)
    }

    // MARK: - ID Tests

    @Test("ID is unique for each log")
    func idIsUniqueForEachLog() {
        // Given / When
        let log1 = Log(notes: "Log 1")
        let log2 = Log(notes: "Log 2")

        // Then
        #expect(log1.id != log2.id)
    }

    // MARK: - Media URLs Tests

    @Test("Media URLs can be modified")
    func mediaURLsCanBeModified() {
        // Given
        let log = Log(notes: "Media test")
        let url1 = URL(fileURLWithPath: "/photo1.jpg")
        let url2 = URL(fileURLWithPath: "/photo2.jpg")

        // When
        log.mediaURLs.append(url1)
        log.mediaURLs.append(url2)

        // Then
        #expect(log.mediaURLs.count == 2)
        #expect(log.mediaURLs[0] == url1)
        #expect(log.mediaURLs[1] == url2)
    }

    @Test("Media URLs can be cleared")
    func mediaURLsCanBeCleared() {
        // Given
        let url = URL(fileURLWithPath: "/photo.jpg")
        let log = Log(notes: "Test", mediaURLs: [url])

        // When
        log.mediaURLs.removeAll()

        // Then
        #expect(log.mediaURLs.isEmpty)
    }

    // MARK: - Audio Memo Tests

    @Test("Audio memo URL can be set to nil")
    func audioMemoURLCanBeSetToNil() {
        // Given
        let audioURL = URL(fileURLWithPath: "/memo.m4a")
        let log = Log(notes: "Test", audioMemoURL: audioURL)

        // When
        log.audioMemoURL = nil

        // Then
        #expect(log.audioMemoURL == nil)
    }
}

//
//  AirQualityServiceTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import EcoJournal

@Suite("AirQualityService Tests")
nonisolated struct AirQualityServiceTests {

    // MARK: - Mock URLSession

    final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
        var mockData: Data?
        var mockResponse: URLResponse?
        var mockError: Error?

        func data(from url: URL) async throws -> (Data, URLResponse) {
            if let error = mockError {
                throw error
            }
            guard let data = mockData, let response = mockResponse else {
                throw URLError(.badServerResponse)
            }
            return (data, response)
        }
    }

    // MARK: - Success Tests

    @Test("Fetch air quality with valid response returns air quality data")
    func fetchAirQualityWithValidResponse() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "list": [
                {
                    "main": {
                        "aqi": 1
                    },
                    "components": {
                        "co": 201.94,
                        "no": 0.01,
                        "no2": 0.5,
                        "o3": 68.66,
                        "so2": 0.64,
                        "pm2_5": 8.5,
                        "pm10": 12.3,
                        "nh3": 0.12
                    }
                }
            ]
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When
        let airQuality = try await service.fetchAirQuality(latitude: 47.8597, longitude: -123.9346)

        // Then
        #expect(airQuality.aqi == 1)
        #expect(airQuality.pm25 == 8.5)
        #expect(airQuality.pm10 == 12.3)
    }

    @Test("Fetch air quality caches result and returns cached value on second call")
    func fetchAirQualityCachesResult() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "list": [
                {
                    "main": {"aqi": 2},
                    "components": {
                        "co": 250.0, "no": 1.0, "no2": 5.0, "o3": 80.0,
                        "so2": 2.0, "pm2_5": 15.8, "pm10": 22.4, "nh3": 1.0
                    }
                }
            ]
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When - First fetch
        let airQuality1 = try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)

        // Simulate network failure
        mockSession.mockData = nil
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Second fetch should return cached value
        let airQuality2 = try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)

        // Then
        #expect(airQuality1.aqi == 2)
        #expect(airQuality2.aqi == 2)
        #expect(airQuality1.pm25 == airQuality2.pm25)
    }

    @Test("Clear cache removes cached data and forces new fetch")
    func clearCacheRemovesCachedData() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "list": [
                {
                    "main": {"aqi": 3},
                    "components": {
                        "co": 300.0, "no": 5.0, "no2": 20.0, "o3": 100.0,
                        "so2": 10.0, "pm2_5": 35.0, "pm10": 50.0, "nh3": 3.0
                    }
                }
            ]
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // Fetch and cache
        _ = try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)

        // When
        service.clearCache()

        // Simulate network error
        mockSession.mockData = nil
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Then
        await #expect(throws: URLError.self) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    // MARK: - Error Tests

    @Test("Fetch air quality with missing API key throws missingAPIKey error")
    func fetchAirQualityWithMissingAPIKey() async {
        // Given
        let mockSession = MockURLSession()
        let service = AirQualityService(apiKey: "", session: mockSession)

        // When / Then
        await #expect(throws: AirQualityError.missingAPIKey) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch air quality with HTTP error throws correct error code", arguments: [401, 500])
    func fetchAirQualityWithHTTPError(statusCode: Int) async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        do {
            _ = try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
            Issue.record("Should have thrown HTTP error")
        } catch let error as AirQualityError {
            #expect(error == .httpError(statusCode))
        }
    }

    @Test("Fetch air quality with empty list throws noData error")
    func fetchAirQualityWithEmptyList() async {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "list": []
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: AirQualityError.noData) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch air quality with invalid JSON throws decoding error")
    func fetchAirQualityWithInvalidJSON() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = "invalid json".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: DecodingError.self) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch air quality with network error throws URLError")
    func fetchAirQualityWithNetworkError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockError = URLError(.notConnectedToInternet)
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: URLError.self) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch air quality with non-HTTP response throws invalidResponse error")
    func fetchAirQualityWithNonHTTPResponse() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = URLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: AirQualityError.invalidResponse) {
            try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
        }
    }

    // MARK: - Edge Cases

    @Test("Fetch air quality for all AQI levels returns correct values", arguments: [1, 2, 3, 4, 5])
    func fetchAirQualityWithAllAQILevels(aqiLevel: Int) async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "list": [
                {
                    "main": {"aqi": \(aqiLevel)},
                    "components": {
                        "co": 200.0, "no": 1.0, "no2": 5.0, "o3": 60.0,
                        "so2": 2.0, "pm2_5": 10.0, "pm10": 15.0, "nh3": 1.0
                    }
                }
            ]
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When
        let airQuality = try await service.fetchAirQuality(latitude: Double(aqiLevel), longitude: 0.0)

        // Then
        #expect(airQuality.aqi == aqiLevel)
    }
}

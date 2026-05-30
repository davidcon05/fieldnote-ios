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

    @Test("Fetch air quality with HTTP error throws error")
    func fetchAirQualityWithHTTPError() async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        let service = AirQualityService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        do {
            _ = try await service.fetchAirQuality(latitude: 47.0, longitude: -123.0)
            Issue.record("Should have thrown HTTP error")
        } catch let error as AirQualityError {
            #expect(error == .httpError(500))
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
}

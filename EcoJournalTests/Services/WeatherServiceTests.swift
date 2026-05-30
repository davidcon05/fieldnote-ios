//
//  WeatherServiceTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import EcoJournal

@Suite("WeatherService Tests")
nonisolated struct WeatherServiceTests {

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

    @Test("Fetch weather with valid response returns weather data")
    func fetchWeatherWithValidResponse() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "weather": [
                {
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ],
            "main": {
                "temp": 18.5,
                "humidity": 62
            },
            "wind": {
                "speed": 3.2
            }
        }
        """
        mockSession.mockData = mockJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When
        let weather = try await service.fetchWeather(latitude: 47.8597, longitude: -123.9346)

        // Then
        #expect(weather.condition == "Clear")
        #expect(weather.temperature == 18.5)
        #expect(weather.humidity == 62)
        #expect(weather.windSpeed == 3.2)
        #expect(weather.icon == "01d")
    }

    // MARK: - Error Tests

    @Test("Fetch weather with missing API key throws missingAPIKey error")
    func fetchWeatherWithMissingAPIKey() async {
        // Given
        let mockSession = MockURLSession()
        let service = WeatherService(apiKey: "", session: mockSession)

        // When / Then
        await #expect(throws: WeatherError.missingAPIKey) {
            try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch weather with HTTP error throws error")
    func fetchWeatherWithHTTPError() async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        do {
            _ = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
            Issue.record("Should have thrown HTTP error")
        } catch let error as WeatherError {
            #expect(error == .httpError(500))
        }
    }

    @Test("Fetch weather with invalid JSON throws decoding error")
    func fetchWeatherWithInvalidJSON() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = "invalid json".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: DecodingError.self) {
            try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
        }
    }
}

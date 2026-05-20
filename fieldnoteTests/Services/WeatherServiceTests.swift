//
//  WeatherServiceTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import fieldnote

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

    @Test("Fetch weather caches result and returns cached value on second call")
    func fetchWeatherCachesResult() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "weather": [{"main": "Rain", "description": "light rain", "icon": "10d"}],
            "main": {"temp": 12.0, "humidity": 88},
            "wind": {"speed": 2.5}
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

        // When - First fetch
        let weather1 = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)

        // Simulate network failure
        mockSession.mockData = nil
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Second fetch should return cached value
        let weather2 = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)

        // Then
        #expect(weather1.condition == "Rain")
        #expect(weather2.condition == "Rain")
        #expect(weather1.temperature == weather2.temperature)
    }

    @Test("Fetch weather for different locations returns different cached values")
    func fetchWeatherDifferentLocationsDifferentCache() async throws {
        // Given
        let mockSession = MockURLSession()
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        let clearJSON = """
        {
            "weather": [{"main": "Clear", "description": "clear sky", "icon": "01d"}],
            "main": {"temp": 20.0, "humidity": 50},
            "wind": {"speed": 1.0}
        }
        """
        mockSession.mockData = clearJSON.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let weather1 = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)

        // Change mock data for different location
        let rainJSON = """
        {
            "weather": [{"main": "Rain", "description": "light rain", "icon": "10d"}],
            "main": {"temp": 15.0, "humidity": 80},
            "wind": {"speed": 3.0}
        }
        """
        mockSession.mockData = rainJSON.data(using: .utf8)

        let weather2 = try await service.fetchWeather(latitude: 48.0, longitude: -124.0)

        // Then
        #expect(weather1.condition == "Clear")
        #expect(weather2.condition == "Rain")
        #expect(weather1.temperature != weather2.temperature)
    }

    @Test("Clear cache removes cached data and forces new fetch")
    func clearCacheRemovesCachedData() async throws {
        // Given
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "weather": [{"main": "Clouds", "description": "few clouds", "icon": "02d"}],
            "main": {"temp": 16.0, "humidity": 60},
            "wind": {"speed": 2.0}
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

        // Fetch and cache
        _ = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)

        // When
        service.clearCache()

        // Simulate network error
        mockSession.mockData = nil
        mockSession.mockError = URLError(.notConnectedToInternet)

        // Then - Should throw error since cache is cleared
        await #expect(throws: URLError.self) {
            try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
        }
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

    @Test("Fetch weather with HTTP error throws correct error code", arguments: [401, 404, 500])
    func fetchWeatherWithHTTPError(statusCode: Int) async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        do {
            _ = try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
            Issue.record("Should have thrown HTTP error")
        } catch let error as WeatherError {
            #expect(error == .httpError(statusCode))
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

    @Test("Fetch weather with network error throws URLError")
    func fetchWeatherWithNetworkError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockError = URLError(.notConnectedToInternet)
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: URLError.self) {
            try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
        }
    }

    @Test("Fetch weather with non-HTTP response throws invalidResponse error")
    func fetchWeatherWithNonHTTPResponse() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = URLResponse(
            url: URL(string: "https://api.openweathermap.org")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let service = WeatherService(apiKey: "test-api-key", session: mockSession)

        // When / Then
        await #expect(throws: WeatherError.invalidResponse) {
            try await service.fetchWeather(latitude: 47.0, longitude: -123.0)
        }
    }

    // MARK: - Edge Cases

    @Test("Fetch weather with extreme coordinates (North Pole) constructs valid URL")
    func fetchWeatherWithExtremeCoordinates() async throws {
        // Given - North Pole
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "weather": [{"main": "Snow", "description": "snow", "icon": "13d"}],
            "main": {"temp": -25.0, "humidity": 95},
            "wind": {"speed": 10.0}
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
        let weather = try await service.fetchWeather(latitude: 90.0, longitude: 0.0)

        // Then
        #expect(weather.condition == "Snow")
        #expect(weather.temperature == -25.0)
    }

    @Test("Fetch weather with negative coordinates constructs valid URL")
    func fetchWeatherWithNegativeCoordinates() async throws {
        // Given - South America
        let mockSession = MockURLSession()
        let mockJSON = """
        {
            "weather": [{"main": "Clear", "description": "clear", "icon": "01d"}],
            "main": {"temp": 28.0, "humidity": 70},
            "wind": {"speed": 2.0}
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
        let weather = try await service.fetchWeather(latitude: -23.5505, longitude: -46.6333)

        // Then
        #expect(weather.condition == "Clear")
    }
}

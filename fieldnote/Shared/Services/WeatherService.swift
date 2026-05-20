//
//  WeatherService.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
import CoreLocation

// MARK: - URLSession Protocol

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

nonisolated class WeatherService {
    // MARK: - Properties

    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let session: URLSessionProtocol

    // MARK: - Cache

    private var cache: [String: CachedWeather] = [:]
    private let cacheExpiration: TimeInterval = 600 // 10 minutes

    // MARK: - Initialization

    init(apiKey: String = "", session: URLSessionProtocol = URLSession.shared) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: - Public Methods

    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        // Check cache first
        let cacheKey = "\(latitude),\(longitude)"
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            return cached.weather
        }

        // Validate API key
        guard !apiKey.isEmpty else {
            throw WeatherError.missingAPIKey
        }

        // Build URL
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // Celsius
        ]

        guard let url = components.url else {
            throw WeatherError.invalidURL
        }

        // Fetch data
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(httpResponse.statusCode)
        }

        // Decode response
        let weatherResponse = try JSONDecoder().decode(OpenWeatherMapResponse.self, from: data)
        let weather = Weather(from: weatherResponse)

        // Cache the result
        cache[cacheKey] = CachedWeather(weather: weather, timestamp: Date())

        return weather
    }

    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - OpenWeatherMap Response Model

private nonisolated struct OpenWeatherMapResponse: Codable {
    let weather: [WeatherCondition]
    let main: MainData
    let wind: WindData

    struct WeatherCondition: Codable {
        let main: String
        let description: String
        let icon: String
    }

    struct MainData: Codable {
        let temp: Double
        let humidity: Int
    }

    struct WindData: Codable {
        let speed: Double
    }
}

// MARK: - Weather Extension

nonisolated extension Weather {
    fileprivate init(from response: OpenWeatherMapResponse) {
        self.init(
            condition: response.weather.first?.main ?? "Unknown",
            temperature: response.main.temp,
            humidity: response.main.humidity,
            windSpeed: response.wind.speed,
            icon: response.weather.first?.icon ?? "01d"
        )
    }
}

// MARK: - Cached Weather

private nonisolated struct CachedWeather {
    let weather: Weather
    let timestamp: Date
}

// MARK: - Weather Errors

enum WeatherError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Weather API key not configured"
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .httpError(let code):
            return "Weather service error (HTTP \(code))"
        case .decodingError:
            return "Failed to decode weather data"
        }
    }
}

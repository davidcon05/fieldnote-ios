//
//  AirQualityService.swift
//  EcoJournal
//
//  Created by David Contreras on 5/10/26.
//

import Foundation
import CoreLocation

nonisolated struct AirQualityData {
    let aqi: Int
    let pm25: Double
    let pm10: Double
}

nonisolated class AirQualityService {
    // MARK: - Properties

    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5/air_pollution"
    private let session: URLSessionProtocol

    // MARK: - Cache

    private var cache: [String: CachedAirQuality] = [:]
    private let cacheExpiration: TimeInterval = 600 // 10 minutes

    // MARK: - Initialization

    init(apiKey: String = "", session: URLSessionProtocol = URLSession.shared) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: - Public Methods

    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQualityData {
        // Check cache first
        let cacheKey = "\(latitude),\(longitude)"
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            return cached.airQuality
        }

        // Validate API key
        guard !apiKey.isEmpty else {
            throw AirQualityError.missingAPIKey
        }

        // Build URL
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components.url else {
            throw AirQualityError.invalidURL
        }

        // Fetch data
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AirQualityError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AirQualityError.httpError(httpResponse.statusCode)
        }

        // Decode response
        let aqResponse = try JSONDecoder().decode(AirPollutionResponse.self, from: data)

        guard let firstReading = aqResponse.list.first else {
            throw AirQualityError.noData
        }

        let airQuality = AirQualityData(
            aqi: firstReading.main.aqi,
            pm25: firstReading.components.pm2_5,
            pm10: firstReading.components.pm10
        )

        // Cache the result
        cache[cacheKey] = CachedAirQuality(airQuality: airQuality, timestamp: Date())

        return airQuality
    }

    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - OpenWeatherMap Air Pollution Response Model

private nonisolated struct AirPollutionResponse: Codable {
    let list: [AirPollutionReading]

    struct AirPollutionReading: Codable {
        let main: AQIData
        let components: Components

        struct AQIData: Codable {
            let aqi: Int
        }

        struct Components: Codable {
            let co: Double
            let no: Double
            let no2: Double
            let o3: Double
            let so2: Double
            let pm2_5: Double
            let pm10: Double
            let nh3: Double
        }
    }
}

// MARK: - Cached Air Quality

private nonisolated struct CachedAirQuality {
    let airQuality: AirQualityData
    let timestamp: Date
}

// MARK: - Air Quality Errors

enum AirQualityError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case noData

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Air quality API key not configured"
        case .invalidURL:
            return "Invalid air quality API URL"
        case .invalidResponse:
            return "Invalid response from air quality service"
        case .httpError(let code):
            return "Air quality service error (HTTP \(code))"
        case .noData:
            return "No air quality data available"
        }
    }
}

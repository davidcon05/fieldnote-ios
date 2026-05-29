//
//  WeatherTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/10/26.
//

import Testing
import Foundation
@testable import EcoJournal

@Suite("Weather Model Tests")
nonisolated struct WeatherTests {

    // MARK: - Initialization Tests

    @Test("Initialize weather with all parameters including air quality")
    func initWithAllParameters() {
        // When
        let weather = Weather(
            condition: "Clear",
            temperature: 18.5,
            humidity: 62,
            windSpeed: 3.2,
            icon: "01d",
            aqi: 1,
            pm25: 8.5,
            pm10: 12.3
        )

        // Then
        #expect(weather.condition == "Clear")
        #expect(weather.temperature == 18.5)
        #expect(weather.humidity == 62)
        #expect(weather.windSpeed == 3.2)
        #expect(weather.icon == "01d")
        #expect(weather.aqi == 1)
        #expect(weather.pm25 == 8.5)
        #expect(weather.pm10 == 12.3)
    }

    @Test("Initialize weather without air quality sets AQI to nil")
    func initWithoutAirQuality() {
        // When
        let weather = Weather(
            condition: "Rain",
            temperature: 12.0,
            humidity: 88,
            windSpeed: 2.5,
            icon: "10d"
        )

        // Then
        #expect(weather.condition == "Rain")
        #expect(weather.temperature == 12.0)
        #expect(weather.aqi == nil)
        #expect(weather.pm25 == nil)
        #expect(weather.pm10 == nil)
    }

    // MARK: - AQI Description Tests

    @Test("AQI 5 returns Very Poor", arguments: [5])
    func aqiDescriptionForValidLevels(aqi: Int) {
        // Given
        let weather = Weather(
            condition: "Test",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d",
            aqi: aqi
        )

        let expectedDescriptions = [
            1: "Good",
            2: "Fair",
            3: "Moderate",
            4: "Poor",
            5: "Very Poor"
        ]

        // When
        let description = weather.aqiDescription

        // Then
        #expect(description == expectedDescriptions[aqi])
    }

    @Test("AQI description with invalid AQI returns Unknown")
    func aqiDescriptionWithInvalidAQI() {
        // Given
        let weather = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d",
            aqi: 99
        )

        // When
        let description = weather.aqiDescription

        // Then
        #expect(description == "Unknown")
    }

    @Test("AQI description with nil AQI returns nil")
    func aqiDescriptionWithNilAQI() {
        // Given
        let weather = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d"
        )

        // When
        let description = weather.aqiDescription

        // Then
        #expect(description == nil)
    }

    @Test("AQI description with zero AQI returns Unknown")
    func aqiDescriptionWithZeroAQI() {
        // Given
        let weather = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d",
            aqi: 0
        )

        // When
        let description = weather.aqiDescription

        // Then
        #expect(description == "Unknown")
    }

    // MARK: - Codable Tests

    @Test("Weather encodes to JSON successfully")
    func encodeToJSON() throws {
        // Given
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
        let encoder = JSONEncoder()
        let data = try encoder.encode(weather)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        #expect(json != nil)
        #expect(json?["condition"] as? String == "Rain")
        #expect(json?["temperature"] as? Double == 12.5)
        #expect(json?["humidity"] as? Int == 95)
        #expect(json?["windSpeed"] as? Double == 2.1)
        #expect(json?["icon"] as? String == "10d")
        #expect(json?["aqi"] as? Int == 1)
        #expect(json?["pm25"] as? Double == 8.5)
        #expect(json?["pm10"] as? Double == 12.3)
    }

    @Test("Weather decodes from JSON successfully")
    func decodeFromJSON() throws {
        // Given
        let json = """
        {
            "condition": "Clear",
            "temperature": 18.5,
            "humidity": 62,
            "windSpeed": 3.2,
            "icon": "01d",
            "aqi": 2,
            "pm25": 15.8,
            "pm10": 22.4
        }
        """
        let data = json.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let weather = try decoder.decode(Weather.self, from: data)

        // Then
        #expect(weather.condition == "Clear")
        #expect(weather.temperature == 18.5)
        #expect(weather.humidity == 62)
        #expect(weather.windSpeed == 3.2)
        #expect(weather.icon == "01d")
        #expect(weather.aqi == 2)
        #expect(weather.pm25 == 15.8)
        #expect(weather.pm10 == 22.4)
    }

    @Test("Weather decodes from JSON without air quality")
    func decodeFromJSONWithoutAirQuality() throws {
        // Given
        let json = """
        {
            "condition": "Clouds",
            "temperature": 15.0,
            "humidity": 70,
            "windSpeed": 2.5,
            "icon": "03d"
        }
        """
        let data = json.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let weather = try decoder.decode(Weather.self, from: data)

        // Then
        #expect(weather.condition == "Clouds")
        #expect(weather.temperature == 15.0)
        #expect(weather.aqi == nil)
        #expect(weather.pm25 == nil)
        #expect(weather.pm10 == nil)
    }

    @Test("Weather encode-decode round trip preserves all data")
    func encodeDecodeRoundTrip() throws {
        // Given
        let original = Weather(
            condition: "Snow",
            temperature: -5.0,
            humidity: 90,
            windSpeed: 4.5,
            icon: "13d",
            aqi: 3,
            pm25: 25.0,
            pm10: 35.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Weather.self, from: data)

        // Then
        #expect(decoded.condition == original.condition)
        #expect(decoded.temperature == original.temperature)
        #expect(decoded.humidity == original.humidity)
        #expect(decoded.windSpeed == original.windSpeed)
        #expect(decoded.icon == original.icon)
        #expect(decoded.aqi == original.aqi)
        #expect(decoded.pm25 == original.pm25)
        #expect(decoded.pm10 == original.pm10)
    }

    // MARK: - Hashable Tests

    @Test("Equal weather objects have same hash")
    func equalWeatherObjectsHaveSameHash() {
        // Given
        let weather1 = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d",
            aqi: 1,
            pm25: 8.0,
            pm10: 12.0
        )
        let weather2 = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d",
            aqi: 1,
            pm25: 8.0,
            pm10: 12.0
        )

        // When / Then
        #expect(weather1.hashValue == weather2.hashValue)
        #expect(weather1 == weather2)
    }

    @Test("Different weather objects are not equal")
    func differentWeatherObjectsAreNotEqual() {
        // Given
        let weather1 = Weather(
            condition: "Clear",
            temperature: 20.0,
            humidity: 50,
            windSpeed: 1.0,
            icon: "01d"
        )
        let weather2 = Weather(
            condition: "Rain",
            temperature: 15.0,
            humidity: 80,
            windSpeed: 3.0,
            icon: "10d"
        )

        // When / Then
        #expect(weather1 != weather2)
    }
}

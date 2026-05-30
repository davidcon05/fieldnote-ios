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

    @Test("Weather initialization with and without air quality")
    func weatherInitialization() {
        // When: Initialize with all parameters
        let weather1 = Weather(
            condition: "Clear",
            temperature: 18.5,
            humidity: 62,
            windSpeed: 3.2,
            icon: "01d",
            aqi: 1,
            pm25: 8.5,
            pm10: 12.3
        )

        // Then: All properties set
        #expect(weather1.condition == "Clear")
        #expect(weather1.temperature == 18.5)
        #expect(weather1.aqi == 1)
        #expect(weather1.pm25 == 8.5)

        // When: Initialize without air quality
        let weather2 = Weather(
            condition: "Rain",
            temperature: 12.0,
            humidity: 88,
            windSpeed: 2.5,
            icon: "10d"
        )

        // Then: Air quality defaults to nil
        #expect(weather2.condition == "Rain")
        #expect(weather2.aqi == nil)
        #expect(weather2.pm25 == nil)
    }

    @Test("AQI description maps values correctly")
    func aqiDescriptionMapping() {
        // Given: Various AQI values
        let validAQI = Weather(condition: "Test", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d", aqi: 3)
        let invalidAQI = Weather(condition: "Test", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d", aqi: 99)
        let zeroAQI = Weather(condition: "Test", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d", aqi: 0)
        let nilAQI = Weather(condition: "Test", temperature: 20.0, humidity: 50, windSpeed: 1.0, icon: "01d")

        // Then: Correct descriptions
        #expect(validAQI.aqiDescription == "Moderate")
        #expect(invalidAQI.aqiDescription == "Unknown")
        #expect(zeroAQI.aqiDescription == "Unknown")
        #expect(nilAQI.aqiDescription == nil)
    }
}

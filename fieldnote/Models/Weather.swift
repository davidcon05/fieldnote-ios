//
//  Weather.swift
//  fieldnote
//
//  Created by David Contreras on 5/8/26.
//

import Foundation

nonisolated struct Weather: Codable, Hashable {
    let condition: String
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let icon: String

    // Air Quality Data
    let aqi: Int? // Air Quality Index (1-5)
    let pm25: Double? // Fine particulate matter
    let pm10: Double? // Coarse particulate matter

    /// Default initializer with air quality
    init(
        condition: String,
        temperature: Double,
        humidity: Int,
        windSpeed: Double,
        icon: String,
        aqi: Int? = nil,
        pm25: Double? = nil,
        pm10: Double? = nil
    ) {
        self.condition = condition
        self.temperature = temperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.icon = icon
        self.aqi = aqi
        self.pm25 = pm25
        self.pm10 = pm10
    }

    /// Air quality description
    var aqiDescription: String? {
        guard let aqi = aqi else { return nil }
        switch aqi {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }
}

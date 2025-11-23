//
//  WeatherDay.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import Foundation

struct WeatherDay: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let temperature: Double
    let cloudCover: Double

    private enum CodingKeys: String, CodingKey {
        case date
        case temperature
        case cloudCover
    }
}

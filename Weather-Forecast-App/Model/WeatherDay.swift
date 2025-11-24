//
//  WeatherDay.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//


import Foundation

struct WeatherDay: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let temperature: Double
    let cloudCover: Double
}

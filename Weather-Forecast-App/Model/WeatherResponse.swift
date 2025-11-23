//
//  WeatherResponse.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import Foundation

struct WeatherResponse: Codable {
    let approvedTime: String
    let referenceTime: String
    let geometry: Geometry
    let timeSeries: [TimeSeriesEntry]
}

struct Geometry: Codable {
    let type: String
    let coordinates: [[Double]]
}

struct TimeSeriesEntry: Codable {
    let validTime: String
    let parameters: [Parameter]
}

struct Parameter: Codable {
    let name: String
    let levelType: String
    let level: Int
    let unit: String
    let values: [Double]
}

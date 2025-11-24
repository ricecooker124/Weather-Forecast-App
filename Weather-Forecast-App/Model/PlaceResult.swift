//
//  PlaceResult.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//


import Foundation

struct PlaceResult: Identifiable, Codable {
    var id: Int { geonameid }

    let geonameid: Int
    let place: String
    let population: Int
    let lon: Double
    let lat: Double
    let type: [String]
    let municipality: String
    let county: String
    let country: String
    let district: String
}

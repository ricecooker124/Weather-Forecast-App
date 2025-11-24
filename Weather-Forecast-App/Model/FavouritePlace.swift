//
//  FavouritePlace.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//

import Foundation

struct FavoritePlace: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let lat: Double
    let lon: Double

    init(id: UUID = UUID(), name: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }

    static func == (lhs: FavoritePlace, rhs: FavoritePlace) -> Bool {
        return lhs.name == rhs.name && lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }
}

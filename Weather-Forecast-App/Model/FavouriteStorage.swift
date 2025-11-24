//
//  FavouriteStorage.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//


import Foundation

final class FavoriteStorage {
    private let key = "favorite_places_v1"

    func load() -> [FavoritePlace] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([FavoritePlace].self, from: data)
        } catch {
            print("FavoriteStorage: decode failed:", error)
            return []
        }
    }

    func save(_ places: [FavoritePlace]) {
        do {
            let data = try JSONEncoder().encode(places)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("FavoriteStorage: encode failed:", error)
        }
    }
}

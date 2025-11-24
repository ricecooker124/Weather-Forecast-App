//
//  FavoritesVM.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//

import Foundation
import Combine

@MainActor
final class FavoritesVM: ObservableObject {
    @Published var favorites: [FavoritePlace] = []

    private let storage = FavoriteStorage()

    init() {
        favorites = storage.load()
    }

    func add(_ fav: FavoritePlace) {
        guard !favorites.contains(fav) else { return }
        favorites.append(fav)
        storage.save(favorites)
    }

    func remove(_ fav: FavoritePlace) {
        favorites.removeAll { $0.id == fav.id }
        storage.save(favorites)
    }
}

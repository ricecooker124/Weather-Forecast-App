// FavoritesVM.swift
import Foundation
import Combine

@MainActor
final class FavoritesVM: ObservableObject {
    @Published var favorites: [FavoritePlace] = []
    private let storage = FavouriteStorage()

    init() {
        favorites = storage.load()
    }

    func add(_ fav: FavoritePlace) {
        favorites.append(fav)
        storage.save(favorites)
    }

    func remove(_ fav: FavoritePlace) {
        favorites.removeAll { $0.id == fav.id }
        storage.save(favorites)
    }
}

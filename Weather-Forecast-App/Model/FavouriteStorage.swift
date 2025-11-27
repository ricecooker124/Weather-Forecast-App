// FavouriteStorage.swift
import Foundation

final class FavouriteStorage {
    private let file = "favorites.json"
    private var url: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(file)
    }

    func save(_ list: [FavoritePlace]) {
        guard let u = url else { return }
        do {
            let data = try JSONEncoder().encode(list)
            try data.write(to: u)
        } catch {
            print("FavouriteStorage.save failed:", error)
        }
    }

    func load() -> [FavoritePlace] {
        guard let u = url, FileManager.default.fileExists(atPath: u.path) else { return [] }
        do { return try JSONDecoder().decode([FavoritePlace].self, from: Data(contentsOf: u)) }
        catch { print("FavouriteStorage.load failed:", error); return [] }
    }
}

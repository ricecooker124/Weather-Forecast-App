//
//  WeatherStorage.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

// WeatherStorage.swift
// WeatherStorage.swift
import Foundation

final class WeatherStorage {
    private let fileName = "forecast_cache.json"

    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }

    func saveForecast(_ days: [WeatherDay]) {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(days)
            try data.write(to: url)
        } catch {
            print("Failed to save forecast:", error)
        }
    }

    func loadForecast() -> [WeatherDay] {
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([WeatherDay].self, from: data)
        } catch {
            print("Failed to load forecast:", error)
            return []
        }
    }
}

import Foundation

final class WeatherStorage {

    private let dailyFile = "forecast_daily.json"
    private let hourlyFile = "forecast_hourly.json"

    private var dailyURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(dailyFile)
    }

    private var hourlyURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(hourlyFile)
    }

    // MARK: - Daily

    func saveForecast(_ days: [WeatherDay]) {
        guard let url = dailyURL else { return }
        do {
            let data = try JSONEncoder().encode(days)
            try data.write(to: url)
        } catch {
            print("WeatherStorage.saveForecast failed:", error)
        }
    }

    func loadForecast() -> [WeatherDay] {
        guard let url = dailyURL,
              FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([WeatherDay].self, from: data)
        } catch {
            print("WeatherStorage.loadForecast failed:", error)
            return []
        }
    }

    // MARK: - Hourly

    func saveHourly(_ hrs: [WeatherHour]) {
        guard let url = hourlyURL else { return }
        do {
            let data = try JSONEncoder().encode(hrs)
            try data.write(to: url)
        } catch {
            print("WeatherStorage.saveHourly failed:", error)
        }
    }

    func loadHourly() -> [WeatherHour] {
        guard let url = hourlyURL,
              FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([WeatherHour].self, from: data)
        } catch {
            print("WeatherStorage.loadHourly failed:", error)
            return []
        }
    }
}


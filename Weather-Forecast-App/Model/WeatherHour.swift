import Foundation

struct WeatherHour: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let cloudCover: Double // percent 0–100
    let windSpeed: Double?
    let precipitation: Double?
}


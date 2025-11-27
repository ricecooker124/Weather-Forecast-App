import Foundation

struct WeatherDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let cloudCover: Double
}


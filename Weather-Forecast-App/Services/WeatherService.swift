//
//  WeatherService.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

// WeatherService.swift
// WeatherService.swift
import Foundation
import Combine

enum WeatherServiceError: Error, LocalizedError {
    case badURL
    case requestFailed
    case decodingFailed
    case noData

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Ogiltig URL."
        case .requestFailed:
            return "Kunde inte hämta data från servern."
        case .decodingFailed:
            return "Kunde inte tolka väderdatat."
        case .noData:
            return "Inget data från servern."
        }
    }
}

final class WeatherService {
    private let baseURL = "https://maceo.sth.kth.se/weather/forecast"

    func fetchForecastPublisher(lat: Double, lon: Double) -> AnyPublisher<[WeatherDay], Error> {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lonLat", value: "lon/\(lon)/lat/\(lat)")
        ]

        guard let url = components?.url else {
            return Fail(error: WeatherServiceError.badURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map(\.data)
            .tryMap { data in
                do {
                    let apiResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    return WeatherParser.parse(apiResponse)
                } catch {
                    throw WeatherServiceError.decodingFailed
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

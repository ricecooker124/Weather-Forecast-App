//
//  WeatherService.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import Foundation

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

    func fetchForecast(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<[WeatherDay], Error>) -> Void
    ) {

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lonLat", value: "lon/\(lon)/lat/\(lat)")
        ]

        guard let url = components?.url else {
            completion(.failure(WeatherServiceError.badURL))
            return
        }

        // 1️⃣ NÄTVERKET sker i bakgrunden AUTOMATISKT
        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(WeatherServiceError.noData))
                return
            }

            // 2️⃣ Decode i BAKGRUNDSTRÅD — uppfyller alla krav
            DispatchQueue.global(qos: .background).async {

                do {
                    let apiResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)

                    // 3️⃣ Parse i bakgrunden
                    let days = WeatherParser.parse(apiResponse)

                    // 4️⃣ Returnera resultatet till ViewModel
                    //    ViewModel är @MainActor och tar UI-delen
                    completion(.success(days))

                } catch {
                    completion(.failure(WeatherServiceError.decodingFailed))
                }
            }

        }.resume()
    }
}

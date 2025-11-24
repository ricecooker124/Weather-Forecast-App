//
//  PlaceSearchService.swift
//  Weather-Forecast-App
//


// PlaceSearchService.swift
import Foundation
import Combine

enum PlaceSearchError: Error, LocalizedError {
    case badURL
    case noResults
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Ogiltig sök-URL."
        case .noResults:
            return "Hittade inga platser."
        case .decodingFailed:
            return "Kunde inte tolka platsdata."
        }
    }
}

final class PlaceSearchService {
    private let baseURL = "https://maceo.sth.kth.se/weather/search?location="

    func searchPlace(_ query: String) -> AnyPublisher<[PlaceResult], Error> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Fail(error: PlaceSearchError.badURL).eraseToAnyPublisher()
        }

        let urlString = baseURL + trimmed
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            return Fail(error: PlaceSearchError.badURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map(\.data)
            .tryMap { data -> [PlaceResult] in
                do {
                    return try JSONDecoder().decode([PlaceResult].self, from: data)
                } catch {
                    throw PlaceSearchError.decodingFailed
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

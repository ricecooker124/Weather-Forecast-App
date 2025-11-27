import Foundation
import Combine

final class WeatherService {

    enum WeatherError: Error, LocalizedError {
        case invalidURL
        case httpError(status: Int, body: String?)
        case decodeError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .httpError(let status, _):
                return "Server returned HTTP \(status)."
            case .decodeError:
                return "Could not decode weather data."
            }
        }
    }

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// SMHI funkar bra med 1 decimal
    private func roundCoord(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    func fetchForecast(lat: Double, lon: Double) -> AnyPublisher<WeatherResponse, Error> {
        let latStr = roundCoord(lat)
        let lonStr = roundCoord(lon)

        // PMP3g point-API [web:48][web:51]
        let urlString =
        "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(lonStr)/lat/\(latStr)/data.json"

        guard let url = URL(string: urlString) else {
            return Fail(error: WeatherError.invalidURL).eraseToAnyPublisher()
        }

        print("[WeatherService] URL → \(url.absoluteString)")

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let http = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard http.statusCode == 200 else {
                    let bodyString = String(data: output.data, encoding: .utf8)
                    print("[WeatherService] HTTP \(http.statusCode)")
                    print("[WeatherService] BODY:\n\(bodyString ?? "(nil)")")
                    throw WeatherError.httpError(status: http.statusCode, body: bodyString)
                }
                return output.data
            }
            .decode(type: WeatherResponse.self, decoder: decoder)
            .mapError { err in
                print("[WeatherService] Decode error: \(err)")
                return err
            }
            .eraseToAnyPublisher()
    }
}


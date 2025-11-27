import Foundation
import Combine

final class PlaceSearchService {

    func searchPublisher(for query: String) -> AnyPublisher<[PlaceResult], Error> {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let urlString =
        "https://www.smhi.se/wpt-a/backend_solr/autocomplete/search/\(encoded)?type=autocomplete"

        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                // parse JSON manually (SMHI uses mixed types)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let array = json as? [[String: Any]] else { return [] }

                return array.compactMap { dict in
                    guard
                        let geonameid = dict["geonameid"] as? Int,
                        let place = dict["place"] as? String,
                        let population = dict["population"] as? Int,
                        let lon = dict["lon"] as? Double,
                        let lat = dict["lat"] as? Double,
                        let type = dict["type"] as? [String],
                        let municipality = dict["municipality"] as? String,
                        let county = dict["county"] as? String,
                        let country = dict["country"] as? String,
                        let district = dict["district"] as? String
                    else {
                        return nil
                    }

                    return PlaceResult(
                        geonameid: geonameid,
                        place: place,
                        population: population,
                        lon: lon,
                        lat: lat,
                        type: type,
                        municipality: municipality,
                        county: county,
                        country: country,
                        district: district
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

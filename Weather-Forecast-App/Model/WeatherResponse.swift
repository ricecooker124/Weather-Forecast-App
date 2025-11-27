import Foundation

struct WeatherResponse: Decodable {
    let approvedTime: Date
    let referenceTime: Date
    let geometry: Geometry
    let timeSeries: [TimeSeries]

    struct Geometry: Decodable {
        let type: String
        let coordinates: [[Double]]
    }

    struct TimeSeries: Decodable {
        let validTime: Date
        let parameters: [Parameter]
    }

    struct Parameter: Decodable {
        let name: String
        let levelType: String
        let level: Int
        let unit: String
        let values: [Double]
    }
}


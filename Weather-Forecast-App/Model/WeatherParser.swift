//
//  WeatherParser.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import Foundation

struct WeatherParser {
    private static let iso = ISO8601DateFormatter()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    static func parse(_ response: WeatherResponse) -> [WeatherDay] {
        typealias Agg = (tempSum: Double, tempCount: Int, cloudSum: Double, cloudCount: Int)
        var aggregated: [String: Agg] = [:]

        for entry in response.timeSeries {
            guard let date = iso.date(from: entry.validTime) else { continue }
            let dayKey = dayFormatter.string(from: date)
            var temp: Double?
            var cloud: Double?

            for param in entry.parameters {
                switch param.name {
                case "t":
                    temp = param.values.first
                case "tcc_mean":
                    if let octas = param.values.first {
                        cloud = (octas / 8.0) * 100.0
                    }
                default:
                    break
                }
            }

            var agg = aggregated[dayKey] ?? (0,0,0,0)
            if let t = temp {
                agg.tempSum += t
                agg.tempCount += 1
            }
            if let c = cloud {
                agg.cloudSum += c
                agg.cloudCount += 1
            }
            aggregated[dayKey] = agg
        }

        let sortedKeys = aggregated.keys.sorted()
        var result: [WeatherDay] = []

        for key in sortedKeys {
            guard let agg = aggregated[key] else { continue }
            let dateString = key + "T00:00:00Z"
            let date = iso.date(from: dateString) ?? Date()
            let tempAvg = agg.tempCount > 0 ? agg.tempSum / Double(agg.tempCount) : 0
            let cloudAvg = agg.cloudCount > 0 ? agg.cloudSum / Double(agg.cloudCount) : 0
            result.append(WeatherDay(date: date, temperature: tempAvg, cloudCover: cloudAvg))
        }

        return result
    }
}

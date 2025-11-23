//
//  WeatherParser.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import Foundation


struct WeatherParser {

    static func parse(_ response: WeatherResponse) -> [WeatherDay] {
        let isoFormatter = ISO8601DateFormatter()

        typealias Agg = (tempSum: Double, tempCount: Int,
                         cloudSum: Double, cloudCount: Int)

        var aggregated: [String: Agg] = [:]

        // Gå igenom varje hourly datapunkt
        for entry in response.timeSeries {
            let timeString = entry.validTime

            // ISO8601 → Date (vi använder den sen bara för att skapa WeatherDay)
            guard let _ = isoFormatter.date(from: timeString) else { continue }

            // Nyckel: "YYYY-MM-DD"
            let dayKey = String(timeString.prefix(10))

            var temp: Double?
            var cloudOctas: Double?

            for param in entry.parameters {
                switch param.name {
                case "t":          // temperatur i °C
                    temp = param.values.first
                case "tcc_mean":   // total cloud cover, 0–8 "octas"
                    cloudOctas = param.values.first
                default:
                    break
                }
            }

            var agg = aggregated[dayKey] ?? (0, 0, 0, 0)

            if let t = temp {
                agg.tempSum += t
                agg.tempCount += 1
            }

            if let octas = cloudOctas {
                // konvertera 0–8 octas → 0–100 %
                let pct = (octas / 8.0) * 100.0
                agg.cloudSum += pct
                agg.cloudCount += 1
            }

            aggregated[dayKey] = agg
        }

        // Sortera dagarna kronologiskt
        let sortedKeys = aggregated.keys.sorted()
        var result: [WeatherDay] = []

        for key in sortedKeys {
            guard let agg = aggregated[key] else { continue }

            let dateString = key + "T00:00:00Z"
            let date = isoFormatter.date(from: dateString) ?? Date()

            let tempAvg = agg.tempCount > 0 ? agg.tempSum / Double(agg.tempCount) : 0
            let cloudAvg = agg.cloudCount > 0 ? agg.cloudSum / Double(agg.cloudCount) : 0

            result.append(
                WeatherDay(
                    date: date,
                    temperature: tempAvg,
                    cloudCover: cloudAvg
                )
            )
        }

        return result
    }
}

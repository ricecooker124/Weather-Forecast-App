import Foundation

struct WeatherParser {

    // SMHI tider är ISO8601 i UTC [web:21]
    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static let fallbackISO: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static func dateFromISO(_ s: String) -> Date? {
        if let d = iso.date(from: s) { return d }
        return fallbackISO.date(from: s)
    }

    // MARK: - Hourly

    static func parseHourly(from response: WeatherResponse) -> [WeatherHour] {
        var hours: [WeatherHour] = []

        for entry in response.timeSeries {
            let date = entry.validTime  // redan Date via JSONDecoder

            var temp: Double = 0
            var cloud: Double = 0
            var wind: Double?
            var precip: Double?

            for p in entry.parameters {
                switch p.name {
                case "t":
                    if let v = p.values.first { temp = v }
                case "tcc_mean":
                    if let v = p.values.first {
                        cloud = (v / 8.0) * 100.0
                    }
                case "ws", "ff":
                    if let v = p.values.first { wind = v }
                case "pmean", "pmax", "pmin", "pmedian":
                    if let v = p.values.first { precip = v }
                default:
                    break
                }
            }

            hours.append(
                WeatherHour(
                    date: date,
                    temperature: temp,
                    cloudCover: cloud,
                    windSpeed: wind,
                    precipitation: precip
                )
            )
        }

        hours.sort { $0.date < $1.date }
        return hours
    }

    // MARK: - Daily (simple avg)

    static func parseDaily(from response: WeatherResponse) -> [WeatherDay] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        typealias Agg = (tempSum: Double, tempCount: Int, cloudSum: Double, cloudCount: Int)
        var agg: [Date: Agg] = [:]

        for entry in response.timeSeries {
            let date = entry.validTime
            let dayKey = calendar.startOfDay(for: date)

            var t: Double?
            var c: Double?

            for p in entry.parameters {
                switch p.name {
                case "t":
                    t = p.values.first
                case "tcc_mean":
                    if let v = p.values.first {
                        c = (v / 8.0) * 100.0
                    }
                default:
                    break
                }
            }

            var a = agg[dayKey] ?? (0, 0, 0, 0)
            if let tt = t {
                a.tempSum += tt
                a.tempCount += 1
            }
            if let cc = c {
                a.cloudSum += cc
                a.cloudCount += 1
            }
            agg[dayKey] = a
        }

        let sortedDays = agg.keys.sorted()
        var result: [WeatherDay] = []

        for d in sortedDays {
            guard let a = agg[d] else { continue }
            let tAvg = a.tempCount > 0 ? a.tempSum / Double(a.tempCount) : 0
            let cAvg = a.cloudCount > 0 ? a.cloudSum / Double(a.cloudCount) : 0
            result.append(WeatherDay(date: d, temperature: tAvg, cloudCover: cAvg))
        }

        return Array(result.prefix(7))
    }
}


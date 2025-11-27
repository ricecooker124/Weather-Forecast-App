import SwiftUI

struct WeatherHourRowView: View {
    let hour: WeatherHour

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        HStack {
            Text(Self.timeFormatter.string(from: hour.date))
                .font(.body)

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.1f °C", hour.temperature))
                    .font(.body).bold()
                HStack(spacing: 8) {
                    Text("Clouds: \(Int(hour.cloudCover))%")
                    if let w = hour.windSpeed {
                        Text(String(format: "Wind: %.1f m/s", w))
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Image(systemName: "cloud.fill")
                .foregroundColor(.blue)
        }
    }
}


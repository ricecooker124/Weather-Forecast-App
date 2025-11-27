import SwiftUI

struct WeatherDayRowView: View {
    let day: WeatherDay

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f
    }()

    var body: some View {
        HStack {
            Text(Self.dayFormatter.string(from: day.date))
                .font(.body)

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.1f °C", day.temperature))
                    .font(.body).bold()
                Text("Clouds: \(Int(day.cloudCover))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}


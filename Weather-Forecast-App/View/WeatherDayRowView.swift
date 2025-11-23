//
//  WeatherDayRowView.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-23.
//

import SwiftUI

struct WeatherDayRowView: View {
    let day: WeatherDay

    var cloudIcon: String {
        switch day.cloudCover {
        case 0..<20: return "sun.max.fill"
        case 20..<60: return "cloud.sun.fill"
        case 60..<90: return "cloud.fill"
        default: return "smoke.fill"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: cloudIcon)
                .foregroundColor(.blue)
                .font(.largeTitle)
                .frame(width: 50)

            VStack(alignment: .leading) {
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)

                Text("Temp: \(day.temperature, specifier: "%.1f") °C")
                Text("Clouds: \(day.cloudCover, specifier: "%.0f") %")
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WeatherDayRowView(day: WeatherDay(
        date: .now,
        temperature: 7.6,
        cloudCover: 80
    ))
}

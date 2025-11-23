//
//  ContentView.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: WeatherVM
    @EnvironmentObject var appVM: WeatherForecastVM

    var body: some View {
        VStack {
            Text("Weather Forecast")
                .font(.largeTitle)
                .padding()

            TextField("Latitude", text: $viewModel.latitudeText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)

            TextField("Longitude", text: $viewModel.longitudeText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)

            Button("Load Forecast") {
                viewModel.loadForecast()
            }
            .padding()
            
            if viewModel.isOffline {
                Text("Offline mode – showing cached data")
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)
            }

            if viewModel.isLoading {
                ProgressView()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            List(viewModel.forecast) { day in
                WeatherDayRowView(day: day)
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WeatherVM())
        .environmentObject(WeatherForecastVM())
}

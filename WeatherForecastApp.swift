//
//  Weather_Forecast_App.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-21.
//

import SwiftUI

@main
struct WeatherForecastApp: App {

    @StateObject private var appVM = WeatherForecastVM()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: appVM.weatherVM)
                .environmentObject(appVM)
        }
    }
}

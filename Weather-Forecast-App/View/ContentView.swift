// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject var appVM = WeatherForecastVM()

    var body: some View {
        TabView {
            ForecastView()
                .tabItem { Label("Forecast", systemImage: "cloud.sun.fill") }
                .environmentObject(appVM)

            LocationsView()
                .tabItem { Label("Locations", systemImage: "map") }
                .environmentObject(appVM)
        }
        .accentColor(Theme.accent)
    }
}

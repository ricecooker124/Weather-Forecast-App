//
//  WeatherVM.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-23.
//

import Foundation
import Combine

@MainActor
final class WeatherVM: ObservableObject {

    // MARK: - User Input
    @Published var latitudeText: String = ""
    @Published var longitudeText: String = ""

    // MARK: - Output to UI
    @Published var forecast: [WeatherDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false

    private let service = WeatherService()
    private let storage = WeatherStorage()

    init() {
        self.forecast = storage.loadForecast()
    }

    // MARK: - Load Weather
    func loadForecast() {
        errorMessage = nil

        guard let lat = Double(latitudeText),
              let lon = Double(longitudeText) else {
            errorMessage = "Latitude and longitude must be valid numbers."
            return
        }

        let hasNetwork = NetworkMonitor.shared.isConnected

        if !hasNetwork {
            isOffline = true
            let cached = storage.loadForecast()
            if cached.isEmpty {
                errorMessage = "No internet and no saved data available."
            } else {
                forecast = cached
            }
            return
        }

        isOffline = false
        isLoading = true

        service.fetchForecast(lat: lat, lon: lon) { [weak self] result in
            guard let self else { return }

            self.isLoading = false

            switch result {
            case .success(let days):
                self.forecast = Array(days.prefix(7))
                self.storage.saveForecast(self.forecast)

            case .failure(let err):
                self.errorMessage = err.localizedDescription

                let cached = self.storage.loadForecast()
                if !cached.isEmpty {
                    self.forecast = cached
                    self.isOffline = true
                }
            }
        }
    }
}

//
//  ForecastVM.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-24.
//
//


import Foundation
import Combine

@MainActor
final class ForecastVM: ObservableObject {
    @Published var forecast: [WeatherDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false

    private let service = WeatherService()
    private let storage = WeatherStorage()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // restore cached forecast on start
        forecast = storage.loadForecast()
    }

    func loadForecast(lat: Double, lon: Double) {
        errorMessage = nil
        isOffline = false
        isLoading = true

        service.fetchForecastPublisher(lat: lat, lon: lon)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    let cached = self.storage.loadForecast()
                    if !cached.isEmpty {
                        self.forecast = cached
                        self.isOffline = true
                    }
                }
            } receiveValue: { [weak self] days in
                guard let self = self else { return }
                self.forecast = Array(days.prefix(7))
                self.storage.saveForecast(self.forecast)
            }
            .store(in: &cancellables)
    }
}

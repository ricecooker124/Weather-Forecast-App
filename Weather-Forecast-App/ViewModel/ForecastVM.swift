import Foundation
import Combine

@MainActor
final class ForecastVM: ObservableObject {

    @Published var forecast: [WeatherDay] = []
    @Published var hourly: [WeatherHour] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false

    private let service = WeatherService()
    let storage = WeatherStorage()
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NetworkMonitor.shared

    init() {
        forecast = storage.loadForecast()
        hourly = storage.loadHourly()

        if !networkMonitor.isConnected {
            isOffline = true
            errorMessage = "Offline – showing cached data."
        }
    }

    func loadForecast(lat: Double, lon: Double) {
        errorMessage = nil
        isOffline = false

        if !networkMonitor.isConnected {
            useCachedDataOffline()
            return
        }

        isLoading = true

        service.fetchForecast(lat: lat, lon: lon)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    let cachedDaily = self.storage.loadForecast()
                    let cachedHourly = self.storage.loadHourly()

                    if !cachedDaily.isEmpty || !cachedHourly.isEmpty {
                        self.isOffline = true
                        self.forecast = cachedDaily
                        self.hourly = cachedHourly
                        self.errorMessage = "Could not fetch updated data — showing cache."
                    } else {
                        self.errorMessage = err.localizedDescription
                    }
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                let hours = WeatherParser.parseHourly(from: response)
                let days  = WeatherParser.parseDaily(from: response)

                self.hourly = hours
                self.forecast = days

                self.storage.saveHourly(hours)
                self.storage.saveForecast(days)

                self.errorMessage = nil
                self.isOffline = false
            }
            .store(in: &cancellables)
    }

    private func useCachedDataOffline() {
        isOffline = true
        errorMessage = "Offline – showing cached data."
        forecast = storage.loadForecast()
        hourly = storage.loadHourly()
    }
}


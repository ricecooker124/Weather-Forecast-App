// WeatherForecastVM.swift
// Main VM — view binds only to this. Mirrors sub-VMs and exposes simple API.

import Foundation
import Combine

@MainActor
final class WeatherForecastVM: ObservableObject {

    // sub VMs (private ownership)
    let searchVM = PlaceSearchVM()
    let forecastVM = ForecastVM()
    let favoritesVM = FavoritesVM()

    private var cancellables = Set<AnyCancellable>()

    // Exposed to view
    @Published var placeText: String = ""
    @Published var searchResults: [PlaceResult] = []
    @Published var searchError: String?
    @Published var isSearching: Bool = false

    @Published var forecast: [WeatherDay] = []
    @Published var hourly: [WeatherHour] = []
    @Published var isLoading: Bool = false
    @Published var forecastError: String?
    @Published var isOffline: Bool = false

    @Published var favorites: [FavoritePlace] = []

    private var selectedLat: Double?
    private var selectedLon: Double?

    init() {
        bindChildren()
        favorites = favoritesVM.favorites
    }

    private func bindChildren() {
        // forward main -> searchVM
        $placeText
            .removeDuplicates()
            .sink { [weak self] text in
                self?.searchVM.placeText = text
            }
            .store(in: &cancellables)

        // mirror searchVM -> main
        searchVM.$searchResults
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchResults)

        searchVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchError)

        searchVM.$isSearching
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSearching)

        // mirror forecastVM -> main
        forecastVM.$forecast
            .receive(on: DispatchQueue.main)
            .assign(to: &$forecast)

        forecastVM.$hourly
            .receive(on: DispatchQueue.main)
            .assign(to: &$hourly)

        forecastVM.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        forecastVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$forecastError)

        forecastVM.$isOffline
            .receive(on: DispatchQueue.main)
            .assign(to: &$isOffline)

        // favorites
        favoritesVM.$favorites
            .receive(on: DispatchQueue.main)
            .assign(to: &$favorites)

        // auto selection from searchVM
        searchVM.autoSelected
            .sink { [weak self] place in
                self?.selectPlace(place)
            }
            .store(in: &cancellables)
    }

    // MARK: - Select place from search result

    func selectPlace(_ place: PlaceResult) {
        selectedLat = place.lat
        selectedLon = place.lon
        placeText = place.place
        searchResults = []
        searchError = nil

        // ForecastVM sköter all nätverks/offline/fel-logik
        forecastVM.loadForecast(lat: place.lat, lon: place.lon)
    }

    // MARK: - Select place from favorite (överlagring)

    func selectPlace(_ fav: FavoritePlace) {
        selectedLat = fav.lat
        selectedLon = fav.lon
        placeText = fav.name
        searchResults = []
        searchError = nil

        forecastVM.loadForecast(lat: fav.lat, lon: fav.lon)
    }

    func selectFavorite(_ fav: FavoritePlace) {
        selectPlace(fav)
    }

    // MARK: - Favorites

    func addCurrentToFavorites() {
        guard let lat = selectedLat,
              let lon = selectedLon,
              !placeText.isEmpty else { return }

        let fav = FavoritePlace(name: placeText, lat: lat, lon: lon)
        favoritesVM.add(fav)
    }

    func removeFavorite(_ fav: FavoritePlace) {
        favoritesVM.remove(fav)
    }
}


//
//  WeatherForecastVM.swift
//  Weather-Forecast-App
//
//  Created by Simon Alam on 2025-11-23.
//

import Foundation
import Combine

@MainActor
final class WeatherForecastVM: ObservableObject {

    // Sub VMs (private ownership)
    let searchVM = PlaceSearchVM()
    let forecastVM = ForecastVM()
    let favoritesVM = FavoritesVM()

    // Published mirrors for the View (view observes ONLY main VM)
    @Published var placeText: String = ""
    @Published var searchResults: [PlaceResult] = []
    @Published var searchError: String?
    @Published var isSearching: Bool = false

    @Published var forecast: [WeatherDay] = []
    @Published var isLoading: Bool = false
    @Published var forecastError: String?
    @Published var isOffline: Bool = false

    @Published var favorites: [FavoritePlace] = []

    private var cancellables = Set<AnyCancellable>()
    private var selectedLat: Double?
    private var selectedLon: Double?

    init() {
        bindChildren()
        favorites = favoritesVM.favorites
    }

    private func bindChildren() {
        // Forward placeText changes FROM main -> sub
        $placeText
            .removeDuplicates()
            .sink { [weak self] new in
                self?.searchVM.placeText = new
            }
            .store(in: &cancellables)

        // Mirror searchVM -> main published properties
        searchVM.$searchResults
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchResults)

        searchVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchError)

        searchVM.$isSearching
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSearching)

        // Mirror forecastVM -> main published properties
        forecastVM.$forecast
            .receive(on: DispatchQueue.main)
            .assign(to: &$forecast)

        forecastVM.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        forecastVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$forecastError)

        forecastVM.$isOffline
            .receive(on: DispatchQueue.main)
            .assign(to: &$isOffline)

        // Mirror favoritesVM -> main
        favoritesVM.$favorites
            .receive(on: DispatchQueue.main)
            .assign(to: &$favorites)

        // Listen for autoSelected from searchVM
        searchVM.autoSelected
            .sink { [weak self] place in
                self?.selectPlace(place)
            }
            .store(in: &cancellables)
    }

    // Called by view when user taps result or when autoSelected emits
    func selectPlace(_ place: PlaceResult) {
        selectedLat = place.lat
        selectedLon = place.lon
        placeText = place.place
        searchResults = []
        searchError = nil

        forecastVM.loadForecast(lat: place.lat, lon: place.lon)
    }

    // Favorites API (use favoritesVM)
    func addCurrentToFavorites() {
        guard let lat = selectedLat, let lon = selectedLon, !placeText.isEmpty else { return }
        let fav = FavoritePlace(name: placeText, lat: lat, lon: lon)
        favoritesVM.add(fav)
    }

    func removeFavorite(_ fav: FavoritePlace) {
        favoritesVM.remove(fav)
    }

    func selectFavorite(_ fav: FavoritePlace) {
        // Create a minimal PlaceResult and feed selectPlace
        let place = PlaceResult(geonameid: Int.random(in: 1...Int.max),
                                place: fav.name, population: 0,
                                lon: fav.lon, lat: fav.lat,
                                type: [], municipality: "", county: "", country: "", district: "")
        selectPlace(place)
    }
}

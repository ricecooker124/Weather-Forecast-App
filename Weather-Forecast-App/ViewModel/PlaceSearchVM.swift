//
//  PlaceSearchVM.swift
//  Weather-Forecast-App
//

import Foundation
import Combine

@MainActor
final class PlaceSearchVM: ObservableObject {
    @Published var placeText: String = ""
    @Published var searchResults: [PlaceResult] = []
    @Published var errorMessage: String?
    @Published var isSearching: Bool = false

    /// autoSelected emits a PlaceResult when we want MainVM to select it (single hit or user tap)
    let autoSelected = PassthroughSubject<PlaceResult, Never>()

    private let service = PlaceSearchService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupPipeline()
    }

    private func setupPipeline() {
        $placeText
            .removeDuplicates()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .sink { [weak self] trimmed in
                guard let self = self else { return }
                if trimmed.isEmpty {
                    self.searchResults = []
                    self.errorMessage = nil
                    return
                }
                // perform search (no debounce; you asked no debounce)
                self.performSearch(query: trimmed)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        isSearching = true
        errorMessage = nil
        searchResults = []

        service.searchPlace(query)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isSearching = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.searchResults = []
                }
            } receiveValue: { [weak self] places in
                guard let self = self else { return }
                if places.isEmpty {
                    self.errorMessage = "Hittade inga platser."
                    self.searchResults = []
                    return
                }
                if places.count == 1 {
                    // auto select
                    self.searchResults = []
                    self.autoSelected.send(places[0])
                    return
                }
                self.searchResults = places
            }
            .store(in: &cancellables)
    }

    /// Called by view when user taps an item
    func userSelected(place: PlaceResult) {
        searchResults = []
        autoSelected.send(place)
    }
}

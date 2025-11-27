import Foundation
import Combine

@MainActor
final class PlaceSearchVM: ObservableObject {
    @Published var placeText: String = ""
    @Published var searchResults: [PlaceResult] = []
    @Published var errorMessage: String?
    @Published var isSearching: Bool = false

    let autoSelected = PassthroughSubject<PlaceResult, Never>()

    private let service = PlaceSearchService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupPipeline()
    }

    private func setupPipeline() {
        $placeText
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }

                if query.isEmpty {
                    self.searchResults = []
                    self.errorMessage = nil
                } else {
                    self.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        isSearching = true
        errorMessage = nil
        searchResults = []

        service.searchPublisher(for: query)
            .sink { [weak self] completion in
                guard let self = self else { return }

                self.isSearching = false

                switch completion {
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    self.searchResults = []
                case .finished:
                    break
                }
            } receiveValue: { [weak self] places in
                guard let self = self else { return }

                if places.isEmpty {
                    self.errorMessage = "Hittade inga platser."
                    self.searchResults = []
                }
                else if places.count == 1 {
                    // auto-select a single result
                    self.searchResults = []
                    self.autoSelected.send(places[0])
                }
                else {
                    self.searchResults = places
                }
            }
            .store(in: &cancellables)
    }

    func userSelected(place: PlaceResult) {
        searchResults = []
        autoSelected.send(place)
    }
}

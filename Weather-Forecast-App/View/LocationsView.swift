// LocationsView.swift
import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var appVM: WeatherForecastVM

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Search place", text: $appVM.placeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                if appVM.isSearching { ProgressView().padding(.horizontal) }
                if let err = appVM.searchError { Text(err).foregroundColor(.red).padding(.horizontal) }

                if appVM.searchResults.count > 1 {
                    List(appVM.searchResults, id: \.geonameid) { place in
                        Button {
                            appVM.selectPlace(place)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(place.place).font(.headline)
                                Text("\(place.municipality), \(place.county)").font(.caption).foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .frame(height: 200)
                }

                Button(action: { appVM.addCurrentToFavorites() }) {
                    Label("Add to Favorites", systemImage: "star").foregroundColor(Theme.accent)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(appVM.favorites) { fav in
                            VStack(alignment: .leading) {
                                Text(fav.name).bold()
                                Text(String(format: "Lat: %.3f Lon: %.3f", fav.lat, fav.lon)).font(.caption).foregroundColor(Theme.textSecondary)
                                HStack {
                                    Button("Open") { appVM.selectFavorite(fav) }
                                    Spacer()
                                    Button(action: { appVM.removeFavorite(fav) }) {
                                        Image(systemName: "trash").foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(Theme.card)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Locations")
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

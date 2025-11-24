
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appVM: WeatherForecastVM

    var body: some View {
        VStack(spacing: 12) {
            Text("Weather Forecast")
                .font(.largeTitle)
                .padding(.top)

            // Search field (two-way: binds to mainVM.placeText which forwards to searchVM)
            TextField("Enter place (e.g., Stockholm)", text: $appVM.placeText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Search state / error
            if appVM.isSearching {
                HStack { ProgressView(); Text("Söker...") }.padding(.horizontal)
            }

            if let err = appVM.searchError {
                Text(err).foregroundColor(.red).padding(.horizontal)
            }

            // Dropdown only when multiple results
            if appVM.searchResults.count > 1 {
                List(appVM.searchResults, id: \.geonameid) { place in
                    Button {
                        appVM.selectPlace(place)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(place.place).font(.headline)
                            Text("\(place.municipality), \(place.county)")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .frame(height: 200)
            }

            // Favorites
            if !appVM.favorites.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("Favorites").font(.headline); Spacer() }
                    ForEach(appVM.favorites) { fav in
                        HStack {
                            Button(action: { appVM.selectFavorite(fav) }) {
                                Text(fav.name)
                            }
                            Spacer()
                            Button(action: { appVM.removeFavorite(fav) }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            }

            // Add to favorites
            HStack {
                Spacer()
                Button(action: { appVM.addCurrentToFavorites() }) {
                    Label("Add to Favorites", systemImage: "star.fill")
                }
                .disabled(appVM.placeText.isEmpty || appVM.forecast.isEmpty)
                Spacer()
            }
            .padding(.vertical, 6)

            // Loading or forecast
            if appVM.isLoading {
                ProgressView().padding()
            }

            List(appVM.forecast) { day in
                WeatherDayRowView(day: day)
            }
            .listStyle(.plain)
        }
        .ignoresSafeArea(.keyboard)
    }
}

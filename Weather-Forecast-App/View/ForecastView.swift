import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var appVM: WeatherForecastVM
    @State private var selection: Segment = .hourly

    enum Segment { case hourly, days }

    // Alla timmar för "idag" i UTC (matchar SMHI:s validTime)
    private var todayHours: [WeatherHour] {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(secondsFromGMT: 0)!

        let nowUTC = Date()
        let todayUTC = utcCal.startOfDay(for: nowUTC)

        return appVM.hourly.filter { h in
            let d = utcCal.startOfDay(for: h.date)
            return d == todayUTC
        }
    }

    // Pågående timme: senaste hour med date <= nu (UTC)
    private var rightNowHour: WeatherHour? {
        let nowUTC = Date()
        let chosen = todayHours
            .filter { $0.date <= nowUTC }
            .sorted(by: { $0.date < $1.date })
            .last ?? todayHours.first

        return chosen
    }

    // Listan börjar på timmen efter rightNowHour
    private var upcomingHours: [WeatherHour] {
        guard let current = rightNowHour else { return todayHours }
        return Array(todayHours.drop { $0.date <= current.date })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Header
                HStack {
                    Text("Weather Forecast")
                        .font(.title2).bold()
                    Spacer()
                    Button(action: refreshAction) {
                        Image(systemName: "arrow.clockwise.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                // Right-now card
                rightNowCard
                    .padding(.horizontal)

                // Segment control
                Picker("", selection: $selection) {
                    Text("Hourly").tag(Segment.hourly)
                    Text("7d").tag(Segment.days)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Loading / error
                if appVM.isLoading {
                    ProgressView()
                        .padding(.top, 8)
                }
                if let err = appVM.forecastError {
                    Text(err)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Innehåll fyller resten av vyn – funkar på alla skärmar
                VStack {
                    if selection == .hourly {
                        hourlySection
                    } else {
                        daysSection
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
            .background(Theme.background.ignoresSafeArea())
        }
    }

    // MARK: - Sektioner

    private var hourlySection: some View {
        Group {
            if upcomingHours.isEmpty {
                VStack {
                    Text("Inga timmar att visa för idag.")
                        .foregroundColor(Theme.textSecondary)
                        .padding()
                    Spacer()
                }
            } else {
                List(upcomingHours) { hour in
                    WeatherHourRowView(hour: hour)
                }
                .listStyle(.plain)
            }
        }
    }

    // 7d – får automatiskt allt återstående utrymme via ramen ovan
    private var daysSection: some View {
        List(appVM.forecast.prefix(7)) { day in
            WeatherDayRowView(day: day)
        }
        .listStyle(.plain)
    }

    // MARK: - Right now card

    private var rightNowCard: some View {
        let chosen = rightNowHour

        return HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Right now")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                if let h = chosen {
                    Text(String(format: "%.1f°C", h.temperature))
                        .font(.system(size: 48, weight: .bold))

                    HStack(spacing: 10) {
                        Text("Clouds: \(Int(h.cloudCover))%")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)

                        if let w = h.windSpeed {
                            Text(String(format: "Wind: %.1f m/s", w))
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                } else {
                    Text("--")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "cloud.sun.fill")
                .resizable()
                .frame(width: 52, height: 52)
                .foregroundColor(Theme.accent)
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(12)
    }

    private func refreshAction() {
        // Här kan du välja första favorite eller senast valda koordinater
        // om du sparar dem. För nu: gör inget.
    }
}


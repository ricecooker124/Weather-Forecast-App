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
    let weatherVM = WeatherVM()
    init() { }
}

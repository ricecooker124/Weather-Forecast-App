//
//  FavoriteQuickInfo.swift
//  Weather-Forecast-App
//
//  Created by Amiin Sabriya on 2025-11-26.
//

import Foundation

struct FavoriteQuickInfo: Identifiable {
    let id = UUID()
    let name: String
    let temperature: Double?
    let cloudCover: Double?
}

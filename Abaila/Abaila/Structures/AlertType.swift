//
//  AlertType.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/21/25.
//

import SwiftUI
import Foundation

enum AlertType: String, CaseIterable, Codable {
    case fire = "fire"
    case medical = "medical"
    case accident = "accident"
    case crime = "crime"
    case natural = "natural"
    case general = "general"

    var displayName: String {
        switch self {
        case .fire: return "Fire"
        case .medical: return "Medical"
        case .accident: return "Accident"
        case .crime: return "Crime"
        case .natural: return "Natural Disaster"
        case .general: return "General"
        }
    }

    var icon: String {
        switch self {
        case .fire: return "flame.fill"
        case .medical: return "cross.fill"
        case .accident: return "car.fill"
        case .crime: return "shield.fill"
        case .natural: return "cloud.bolt.fill"
        case .general: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .fire: return .red
        case .medical: return .blue
        case .accident: return .orange
        case .crime: return .purple
        case .natural: return .green
        case .general: return .gray
        }
    }
}

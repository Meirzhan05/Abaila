//
//  AlertsView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/29/25.
//

import SwiftUI

struct AlertItem: Identifiable {
  enum Level: String, CaseIterable {
    case all, high, medium, low
  }

  let id: Int
  let icon: String
  let title: String
  let location: String
  let distance: String
  let time: String
  let level: Level
  let verified: Int
  let reports: Int
  let description: String
}

struct AlertsView: View {
    private let allAlerts: [AlertItem] = [
      .init(id: 1, icon: "🔥", title: "Structure Fire",   location: "Oak Street & 5th Ave", distance: "0.3 km", time: "2 minutes ago", level: .high,   verified: 12, reports: 3, description: "Large fire visible from multiple blocks"),
      .init(id: 2, icon: "🚔", title: "Police Activity",  location: "Downtown Plaza",     distance: "0.8 km", time: "8 minutes ago", level: .medium, verified:  8, reports: 2, description: "Multiple police vehicles on scene"),
      .init(id: 3, icon: "🚑", title: "Medical Emergency",location: "Central Park",       distance: "1.2 km", time: "12 minutes ago",level: .high,   verified: 15, reports: 1, description: "Ambulance and paramedics responding"),
      .init(id: 4, icon: "🚧", title: "Traffic Accident", location: "Highway 101 North", distance: "2.1 km", time: "15 minutes ago",level: .low,    verified:  5, reports: 4, description: "Minor fender bender, one lane blocked"),
    ]
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            VStack {
                Divider()
                Spacer()
                ScrollView {
                  LazyVStack(spacing: 16) {
                      ForEach(allAlerts) { alert in
                      AlertCard(alert: alert)
                    }
                  }
                  .padding()
                }
            }
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func backgroundColor(for isSelected: Bool) -> Color {
        if isSelected {
            return Color.accentColor
        } else {
            return colorScheme == .dark
                ? Color(UIColor.secondarySystemBackground)
                : Color.white
        }
    }
    
    private func foregroundColor(for isSelected: Bool) -> Color {
        if isSelected {
            return .white
        } else {
            return colorScheme == .dark ? .white : .primary
        }
    }
    
    private func strokeColor(for isSelected: Bool) -> Color {
        return isSelected
            ? Color.accentColor
            : Color(UIColor.separator)
    }
    struct AlertCard: View {
      let alert: AlertItem
      @Environment(\.colorScheme) private var colorScheme

      // map level → colorthe
      private var levelColor: Color {
        switch alert.level {
          case .high:   return .red
          case .medium: return .orange
          case .low:    return .yellow
          default:      return .blue
        }
      }

      var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          HStack(alignment: .top) {
            // icon bubble
            Text(alert.icon)
              .font(.largeTitle)
              .frame(width: 48, height: 48)
              .background(levelColor)
              .clipShape(Circle())
              .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
              Text(alert.title)
                .font(.headline)
                .foregroundColor(.primary)

              HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                Text(alert.location)
              }
              .font(.subheadline)
              .foregroundColor(.secondary)
            }
            Spacer()

            VStack(alignment: .trailing) {
              Text(alert.distance)
                .font(.subheadline)
                .foregroundColor(.primary)
              Text(alert.time)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          Text(alert.description)
            .font(.body)
            .foregroundColor(.primary)

          HStack {
            HStack(spacing: 4) {
              Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.blue)
              Text("\(alert.reports) reports")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Spacer()

            Text(alert.level.rawValue.uppercased())
              .font(.caption).bold()
              .padding(.vertical, 4).padding(.horizontal, 8)
              .background(levelColor)
              .foregroundColor(.white)
              .clipShape(Capsule())
          }
        }
        .padding()
        .background(colorScheme == .dark
                    ? Color(UIColor.secondarySystemBackground)
                    : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
      }
    }
}

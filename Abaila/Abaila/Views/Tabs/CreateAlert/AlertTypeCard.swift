//
//  AlertTypeCard.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/21/25.
//

import SwiftUI

struct AlertTypeCard: View {
    let alertType: AlertType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: alertType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : alertType.color)

                Text(alertType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? alertType.color : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(alertType.color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

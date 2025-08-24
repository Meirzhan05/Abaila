//
//  AlertMapPin.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 8/23/25.
//
import SwiftUI

struct AlertMapPin: View {
    let alert: AlertResponse
    
    var body: some View {
        ZStack {
            Circle()
                .fill(alert.alertType.color)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Image(systemName: alert.alertType.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

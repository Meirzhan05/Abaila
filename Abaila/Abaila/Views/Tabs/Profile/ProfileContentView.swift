//
//  ProfileContentView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/29/25.
//

import SwiftUI

struct ProfileContentView: View {
    @Binding var selectedAlert: Alert?
    let profile: UserProfile
    let userAlerts: [Alert]
    @Binding var showEditProfile: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header
                    VStack(spacing: 32) {
                        // Settings Button
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // Centered Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .pink, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        // User Info - Using actual profile data
                        VStack(alignment: .center, spacing: 12) {
                            Text(profile.username)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
//                            Text(profile.bio)
//                                .font(.body)
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                            
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Text("Downtown Metro Area")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Edit Profile Button
                        Button(action: {
                            print("Clicked")
                            self.showEditProfile = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(.subheadline)
                                Text("Edit Profile")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                    
                    // Content Tabs
                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack {
                            Button(action: {}) {
                                VStack(spacing: 8) {
                                    Image(systemName: "grid")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text("My Alerts")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.primary),
                                alignment: .bottom
                            )
                        }
                        .background(Color(.systemBackground))
                    }
                    
                    // Alerts Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                        ForEach(userAlerts) { alert in
                            AlertGridItem(alert: alert) {
                                selectedAlert = alert
                            }
                        }
                    }
                    .padding(.top, 1)
                    .padding(.horizontal, 1)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
}

// AlertGridItem and AlertDetailView remain the same...
struct AlertGridItem: View {
    let alert: Alert
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Placeholder image
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                HStack {
                    // Alert Type Icon
                    ZStack {
                        Circle()
                            .fill(alert.level.color)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        Text(alert.icon)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // Video Indicator
                    if alert.hasVideo {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "play.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    // Status Indicator
                    if alert.status == .active {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 14, height: 14)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 14, height: 14)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                }
            }
            .padding(10)
        }
        .cornerRadius(8)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            if !pressing {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct AlertDetailView: View {
    let alert: Alert
    @Environment(\.dismiss) private var dismiss
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000.0)
        }
        return String(num)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Image
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "xmark")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(alert.level.color)
                                .frame(width: 48, height: 48)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Text(alert.icon)
                                .font(.title2)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            
            // Alert Info
            VStack(alignment: .leading, spacing: 20) {
                Text(alert.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(alert.location) • \(alert.time)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Stats
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                        Text(formatNumber(alert.likes))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text(formatNumber(alert.comments))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text(formatNumber(alert.views))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
            }
            .padding(24)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

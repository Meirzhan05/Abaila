//
//  ProfileContentView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/29/25.
//

import SwiftUI

struct ProfileContentView: View {
    @Binding var selectedAlert: AlertResponse?
    let profile: UserProfile
    let userAlerts: [AlertResponse]
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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 1) {
                        ForEach(userAlerts) { alert in
                            AlertGridItem(alert: alert) {
                                selectedAlert = alert
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .onAppear{
                                print("Alert loaded: \(alert.media)")
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
}

extension AlertResponse {
    var relativeTime: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var isVideo: Bool {
        guard let mediaType else { return false }
        return mediaType.lowercased().contains("video") || mediaType.lowercased().contains("mp4")
    }
    
    var primaryMediaURL: URL? {
        guard let first = media.first, let url = URL(string: first) else { return nil }
        return url
    }
}

struct AlertGridItem: View {
    let alert: AlertResponse
    let onTap: () -> Void
    @State private var pressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image/placeholder
                Group {
                    if let firstMedia = alert.signedMedia.first,
                       let url = URL(string: firstMedia) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure(_):
                                Color.gray.opacity(0.3)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            case .empty:
                                ZStack {
                                    Color.gray.opacity(0.15)
                                    ProgressView()
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            @unknown default:
                                Color.gray
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                    } else {
                        placeholder
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
                // Overlays
                VStack {
                    HStack {
                        // Type badge
                        ZStack {
                            Circle()
                                .fill(alert.alertType.color.opacity(0.9))
                                .frame(width: 24, height: 24)
                            Image(systemName: alert.alertType.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Multiple media indicator
                        if alert.signedMedia.count > 1 {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        } else if alert.isVideo {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(4)
                    
                    Spacer()
                    
                    // Bottom gradient + stats
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alert.title)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        
                        HStack(spacing: 8) {
                            stat(icon: "heart.fill", value: alert.likes)
                            stat(icon: "message.fill", value: alert.comments)
                            stat(icon: "eye.fill", value: alert.views)
                            Spacer()
                        }
                        .font(.system(size: 8))
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .allowsHitTesting(false)
                    )
                }
            }
        }
        .cornerRadius(8)
        .contentShape(Rectangle())
        .scaleEffect(pressed ? 0.95 : 1)
        .animation(.easeInOut(duration: 0.1), value: pressed)
        .onTapGesture { onTap() }
        .onLongPressGesture(minimumDuration: 0, pressing: { isPress in
            pressed = isPress
        }, perform: {})
    }
    
    private var placeholder: some View {
        LinearGradient(
            colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.45)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @ViewBuilder
    private func stat(icon: String, value: Int) -> some View {
        HStack(spacing: 1) {
            Image(systemName: icon)
                .font(.system(size: 7))
            Text(shortFormat(value))
                .font(.system(size: 8))
        }
        .foregroundColor(.white.opacity(0.95))
    }
    
    private func shortFormat(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
}
struct AlertDetailView: View {
    let alert: AlertResponse
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                mediaHeader
                
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    statsSection
                    if let desc = alert.description, !desc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    metaSection
                }
                .padding(20)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
    }
    
    private var mediaHeader: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if alert.media.isEmpty {
                    LinearGradient(
                        colors: [alert.alertType.color.opacity(0.25), alert.alertType.color.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    TabView {
                        ForEach(alert.signedMedia, id: \.self) { item in
//                            if let url = URL(string: item) {
                            let url = URL(string: item)
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                case .failure(_): Color.gray.opacity(0.3)
                                case .empty: ZStack { Color.gray.opacity(0.15); ProgressView() }
                                @unknown default: Color.gray
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                }
            }
            .frame(height: 300)
            .clipped()
            
            HStack(spacing: 10) {
                typeBadge
                closeButton
            }
            .padding(12)
        }
    }
    
    private var typeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: alert.alertType.icon)
            Text(alert.alertType.displayName)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(alert.alertType.color.opacity(0.9))
        )
        .foregroundColor(.white)
        .shadow(radius: 3, x: 0, y: 2)
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Circle()
                .fill(Color.black.opacity(0.55))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(alert.title)
                .font(.title2.bold())
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                Text(locationDisplayText)
                Text("•")
                Text(alert.relativeTime)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    private var locationDisplayText: String {
        if let location = alert.location {
            // Format coordinates for display
            let latitude = location.coordinates[1]
            let longitude = location.coordinates[0]
            return String(format: "%.4f, %.4f", latitude, longitude)
        }
        return "Unknown location"
    }
    
    private var statsSection: some View {
        HStack(spacing: 34) {
            stat(icon: "heart.fill", color: .red, value: alert.likes)
            stat(icon: "message.fill", color: .blue, value: alert.comments)
            stat(icon: "eye.fill", color: .secondary, value: alert.views)
            Spacer()
        }
    }
    
    private func stat(icon: String, color: Color, value: Int) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(shortFormat(value))
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
        .frame(minWidth: 44)
    }
    
    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Reported by")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(alert.createdBy)
                .font(.subheadline.weight(.semibold))
            Text("Created at \(formattedDate(alert.createdAt))")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private func shortFormat(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}


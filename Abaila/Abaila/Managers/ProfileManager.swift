//
//  ProfileManager.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/13/25.
//

import SwiftUI
import Combine

struct Alert: Identifiable {
    let alertId: String
    var id = UUID()
    let type: String
    let icon: String
    let title: String
    let location: String
    let time: String
    let level: AlertLevel
    let likes: Int
    let comments: Int
    let views: Int
    let status: AlertStatus
    let hasVideo: Bool
}

enum AlertLevel: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: Color {
        switch self {
        case .critical: return Color(red: 0.863, green: 0.149, blue: 0.149)
        case .high: return Color(red: 1.0, green: 0.231, blue: 0.188)
        case .medium: return Color(red: 1.0, green: 0.584, blue: 0.0)
        case .low: return Color(red: 1.0, green: 0.8, blue: 0.0)
        }
    }
}

enum AlertStatus {
    case active
    case resolved
}


class ProfileManager: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var alerts: [Alert] = []
    @Published var errorMessage: String?
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    

    func fetchProfile() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        guard let url = URL(string: "http://localhost:3000/profile") else {
            await MainActor.run {
                error = URLError(.badURL)
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            await MainActor.run {
                error = URLError(.userAuthenticationRequired)
                isLoading = false
            }
            return
        }
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    error = URLError(.badServerResponse)
                    isLoading = false
                }
                return
            }
            if httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
                await MainActor.run {
                    self.profile = decoded
                    isLoading = false
                }
            } else if httpResponse.statusCode == 403 {
                // token expired
                do {
                    try await authViewModel.authenticationStatus()
                    // Retry the original request after token refresh
                   await fetchProfile()
                } catch {
                    await MainActor.run {
                        self.error = error
                        isLoading = false
                    }
                }
                return
            } else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
                await MainActor.run {
                    error = URLError(.badServerResponse)
                    isLoading = false
                }
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
    func updateProfile(email: String, username: String) async throws {
        await MainActor.run() {
            isLoading = true
            error = nil
        }
        
        guard let url = URL(string: "http://localhost:3000/profile/update") else {
            await MainActor.run {
                isLoading = false
            }
            throw URLError(.badURL)
        }
        
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            await MainActor.run {
                isLoading = false
            }
            throw URLError(.userAuthenticationRequired)
        }

        let newProfileData: UserProfileRequest = UserProfileRequest(email: email, username: username)
        
        guard let encoded = try? JSONEncoder().encode(newProfileData) else {
            await MainActor.run {
                isLoading = false
            }
            throw URLError(.badServerResponse)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    isLoading = false
                }
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 200 {
                await MainActor.run {
                    isLoading = false
                }
            } else if httpResponse.statusCode == 409 {
                await MainActor.run {
                    isLoading = false
                }
                throw ProfileUpdateError.conflictError("Username or email is already taken")
            } else if httpResponse.statusCode == 403 {
                try await authViewModel.authenticationStatus()
                try await updateProfile(email: email, username: username)
            } else {
                await MainActor.run {
                    isLoading = false
                }
                throw URLError(.badServerResponse)
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
            throw error
        }
    }
    func fetchAlerts() async {
        let userAlerts: [Alert] = [
            Alert(alertId: "fire_001", type: "fire", icon: "🔥", title: "Structure Fire Alert", location: "Oak Street & 5th Ave", time: "2h", level: .critical, likes: 124, comments: 18, views: 1560, status: .active, hasVideo: false),
            Alert(alertId: "traffic_001", type: "traffic", icon: "🚧", title: "Road Closure", location: "Main Street Bridge", time: "1d", level: .medium, likes: 45, comments: 8, views: 890, status: .resolved, hasVideo: true),
            Alert(alertId: "weather_001", type: "weather", icon: "⛈️", title: "Storm Warning", location: "Downtown Area", time: "3d", level: .high, likes: 89, comments: 25, views: 2340, status: .resolved, hasVideo: false),
            Alert(alertId: "medical_001", type: "medical", icon: "🚑", title: "Medical Emergency", location: "Central Park", time: "1w", level: .high, likes: 67, comments: 12, views: 1230, status: .resolved, hasVideo: false),
            Alert(alertId: "police_001", type: "police", icon: "🚔", title: "Police Activity", location: "Downtown Plaza", time: "2w", level: .medium, likes: 34, comments: 6, views: 980, status: .resolved, hasVideo: true),
            Alert(alertId: "fire_002", type: "fire", icon: "🔥", title: "Kitchen Fire", location: "Elm Street", time: "3w", level: .low, likes: 23, comments: 4, views: 670, status: .resolved, hasVideo: false)
        ]
        await MainActor.run {
            self.alerts = userAlerts
        }
        
    }
} 
enum ProfileUpdateError: LocalizedError {
    case conflictError(String)
    
    var errorDescription: String? {
        switch self {
        case .conflictError(let message):
            return message
        }
    }
}

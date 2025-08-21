//
//  ProfileManager.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/13/25.
//

import SwiftUI
import Combine


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
            let (_, response) = try await URLSession.shared.data(for: request)
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

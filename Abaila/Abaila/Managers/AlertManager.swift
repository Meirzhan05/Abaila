//
//  AlertManager.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/21/25.
//

import SwiftUI

class AlertManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    
    func createAlert(title: String, description: String, alertType: AlertType, location: String) async throws {
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        guard let url = URL(string: "http://localhost:3000/alerts/create") else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "NSURLErrorDomain", code: NSURLErrorBadURL, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            return
        }
        
        let alertData = AlertRequest(title: title, description: description, alertType: alertType, location: location)
        print(alertType)
        guard let encoded = try? JSONEncoder().encode(alertData) else {
            print("Failed when encoding alert data")
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "Failed encoding data", code: 100, userInfo: nil)
            }
            return
        }
        
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("User is not logged in")
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "AuthenticationError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    isLoading = false
                    error = NSError(domain: "Invalid response", code: 100, userInfo: nil)
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                await MainActor.run {
                    isLoading = false
                }
                return
            } else if httpResponse.statusCode == 403 {
                try await authViewModel.authenticationStatus()
                try await createAlert(title: title, description: description, alertType: alertType, location: location)
                return
            } else {
                await MainActor.run {
                    isLoading = false
                    error = error
                }
            }
            
            
        } catch {
            await MainActor.run {
                isLoading = false
                self.error = error
            }
            
            throw error
        }
    }
    
}

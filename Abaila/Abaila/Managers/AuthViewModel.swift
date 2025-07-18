//
//  AuthViewModel.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/8/25.
//

import SwiftUI
import Foundation
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    func isTokenExpired(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return true } // invalid token

        let payloadSegment = segments[1]
        
        // Add padding if needed (JWT base64 strings sometimes miss "=")
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddedLength = base64.count + (4 - base64.count % 4) % 4
        base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)

        guard let payloadData = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: payloadData, options: []),
              let payload = json as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        return Date() >= expirationDate
    }

    
    func authenticationStatus() async throws {
        print("Checking authentication status...")
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Access token not found")
            await MainActor.run {
                isAuthenticated = false
            }
            try KeychainManager.instance.deleteToken(forKey: "refreshToken") // delete refresh token if access token does not exist
            return
        }
        
        if isTokenExpired(accessToken) {
            print("Access token is expired")
            
            do { // get a new acess token using refresh token
                guard let refreshToken = KeychainManager.instance.getToken(forKey: "refreshToken") else { // refresh token does not exist
                    print("Refresh token not found")
                    await MainActor.run {
                        isAuthenticated = false
                    }
                    throw URLError(.userAuthenticationRequired)
                }
                
                // if refresh token exists
                
                guard let url = URL(string: "http://localhost:3000/token") else {
                    print("Invalid URL")
                    throw URLError(.badURL)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let refreshData = RefreshTokenRequest(refreshToken: refreshToken)
                guard let encoded = try? JSONEncoder().encode(refreshData) else {
                    print("Failed to encode refresh token data")
                    await MainActor.run {
                        isAuthenticated = false
                    }
                    throw URLError(.badURL)
                }
                request.httpBody = encoded
                
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse?.statusCode ?? "No status code")
                    
                    if let statusCode = httpResponse?.statusCode, statusCode == 200 {
                        let decoded = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                        UserDefaults.standard.set(decoded.accessToken, forKey: "accessToken")
                        await MainActor.run {
                            isAuthenticated = true
                        }
                    }
                }
                
            } catch {
                print("Error retrieving refresh token: \(error.localizedDescription)")
                await MainActor.run {
                    isAuthenticated = false
                }
            }
            
        } else {
            await MainActor.run {
                print(isTokenExpired(accessToken)) // check if access token is expired
                print("Access token is valid")
                isAuthenticated = true
            }
        }
    }
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "http://localhost:3000/login") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = LoginRequest(email: email, password: password)
        guard let encoded = try? JSONEncoder().encode(loginData) else {
            print("Failed to encode login data")
            throw URLError(.badURL)
        }
        request.httpBody = encoded
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse?.statusCode ?? "No status code")
            
            // Check for success status codes (200-299)
            if let statusCode = httpResponse?.statusCode, statusCode == 200 {
                let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                UserDefaults.standard.set(decoded.accessToken, forKey: "accessToken")
                do {
                    try KeychainManager.instance.saveToken(decoded.refreshToken, forKey: "refreshToken")
                } catch {
                    print("Keychain error: \(error.localizedDescription)")
                }
                
                
                
                await MainActor.run {
                    print("Login successful")
                    self.isAuthenticated = true
                }
            } else {
                // Handle non-success status codes
                print("Login failed with status code: \(httpResponse?.statusCode ?? 0)")
                throw URLError(.badServerResponse)
            }
        } catch {
            print("Login error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func register(username: String, email: String, password: String) async throws {
        guard let url = URL(string: "http://localhost:3000/register") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registerData = RegisterRequest(email: email, username: username, password: password)
        print(registerData)
        let encoded = try JSONEncoder().encode(registerData)
        request.httpBody = encoded
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse?.statusCode ?? "No status code")
            
            // Check for success status codes (200-299)
            if let statusCode = httpResponse?.statusCode, statusCode >= 200 && statusCode < 300 {
                let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                do {
                    try KeychainManager.instance.saveToken(decoded.refreshToken, forKey: "refreshToken")
                } catch {
                    print("Keychain error: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    print("Registration successful")
                    self.isAuthenticated = true
                }
            } else {
                // Handle non-success status codes
                print("Registration failed with status code: \(httpResponse?.statusCode ?? 0)")
                throw URLError(.badServerResponse)
            }
        } catch {
            print("Registration error: \(error.localizedDescription)")
            throw error
        }
    }
    
}

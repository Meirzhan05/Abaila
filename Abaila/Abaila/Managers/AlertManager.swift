// Swift
// `AlertManager.swift`
import SwiftUI

class AlertManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let authViewModel: AuthViewModel
    private let mediaManager: MediaManager
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.mediaManager = MediaManager(authViewModel: authViewModel)
    }

    func createAlert(title: String,
                     description: String,
                     alertType: AlertType,
                     location: String,
                     media: [String]) async throws {

        await MainActor.run {
            isLoading = true
            error = nil
        }

        guard let url = URL(string: "http://localhost:3000/alerts/create") else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "NSURLErrorDomain",
                                code: NSURLErrorBadURL,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            return
        }

        let body = AlertCreateRequest(title: title,
                                      description: description,
                                      type: alertType,
                                      location: location,
                                      media: media.isEmpty ? nil : media)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let encoded = try? encoder.encode(body) else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "Encoding",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to encode body"])
            }
            return
        }

        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "AuthenticationError",
                                code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
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
            guard let http = response as? HTTPURLResponse else {
                throw NSError(domain: "Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }

            if http.statusCode == 200 || http.statusCode == 201 {
                await MainActor.run { isLoading = false }
            } else if http.statusCode == 403 {
                try await authViewModel.authenticationStatus()
                try await createAlert(title: title,
                                      description: description,
                                      alertType: alertType,
                                      location: location,
                                      media: media)
            } else {
                throw NSError(domain: "Server",
                              code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "Server error \(http.statusCode)"])
            }
        } catch {
            await MainActor.run {
                isLoading = false
                self.error = error
            }
            throw error
        }
    }

    func getAlerts() async -> [AlertResponse] {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        guard let url = URL(string: "http://localhost:3000/alerts/get") else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "NSURLErrorDomain",
                                code: NSURLErrorBadURL,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            return []
        }

        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            await MainActor.run {
                isLoading = false
                error = NSError(domain: "AuthenticationError",
                                code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NSError(domain: "Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }

            if http.statusCode == 200 {
                do {
                    var alerts = try AlertResponse.decoder.decode([AlertResponse].self, from: data)
                    
                    for i in alerts.indices {
                        let keys = alerts[i].media
                        if !keys.isEmpty {
                            let urls = try await mediaManager.getSignedURLs(keys: keys)
                            alerts[i].signedMedia = urls
                        }
                    }
                    print("Alerts:", alerts)
                    await MainActor.run { isLoading = false }
                    return alerts
                } catch {
                    // Detailed debugging
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Raw alerts JSON:\n\(raw)")
                    }
                    print("Decoding error:", error)
                    await MainActor.run {
                        isLoading = false
                        self.error = error
                    }
                    return []
                }
            } else if http.statusCode == 403 {
                try await authViewModel.authenticationStatus()
                return await getAlerts()
            } else {
                throw NSError(domain: "Server",
                              code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "Server error \(http.statusCode)"])
            }
        } catch {
            await MainActor.run {
                isLoading = false
                self.error = error
            }
            return []
        }
    }
    
    
    
}

//
//  AbailaApp.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/27/25.
//

import SwiftUI

@main
struct AbailaApp: App {
    @State private var locationManager = LocationManager()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                ContentView()
                    .environment(locationManager)
                    .environmentObject(authViewModel)
                    .task {
                        do {
                            try await authViewModel.authenticationStatus()
                        } catch {
                            print("Authentication check failed: \(error)")
                        }
                    }
            } else {
                Text("Please enable location services in Settings to use the app.")
            }
        }
    }
}

//
//  AbailaApp.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/27/25.
//

import SwiftUI
import UIKit

@main
struct AbailaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
                            PushNotificationManager.shared.registerForPushNotifications()
                            PushNotificationManager.shared.syncTokenIfPossible()
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

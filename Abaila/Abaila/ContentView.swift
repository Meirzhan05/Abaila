//
//  ContentView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        
        if authViewModel.isAuthenticated {
            TabView {
                Tab("Map", systemImage: "map") {
                    MapView()
                }
                
                Tab("Alerts", systemImage: "bell") {
                    AlertsView()
                }
                
                Tab("Profile", systemImage: "person") {
                    ProfileView()
                }
            }
        } else {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
}

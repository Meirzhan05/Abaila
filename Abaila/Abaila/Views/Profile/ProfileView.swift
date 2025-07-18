//
//  ProfileView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/13/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileManager: ProfileManager
    @State private var selectedAlert: Alert?
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditProfile: Bool = false
    init() {
        let authViewModel = AuthViewModel()
        _profileManager = StateObject(wrappedValue: ProfileManager(authViewModel: authViewModel))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if profileManager.isLoading {
                    LoadingView()
                } else if let error = profileManager.error {
                    ErrorView(message: error.localizedDescription) {
                        Task {
                            try await profileManager.fetchProfile()
                            await profileManager.fetchAlerts()
                        }
                    }
                } else if let profile = profileManager.profile {
                    ProfileContentView(
                        selectedAlert: $selectedAlert,
                        profile: profile,
                        userAlerts: profileManager.alerts,
                        showEditProfile: $showEditProfile
                    )
                    .sheet(isPresented: $showEditProfile) {
                        EditProfileView(profile: profile)
                    }
                } else {
                    LoadingView()
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .task {
            await profileManager.fetchProfile()
            await profileManager.fetchAlerts()
        }
        .sheet(item: $selectedAlert) { alert in
            AlertDetailView(alert: alert)
        }
    }
}

// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileManager: ProfileManager
    @StateObject private var alertManager: AlertManager
    

    @State private var selectedAlert: AlertResponse?
    @State private var userAlerts: [AlertResponse] = []
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditProfile: Bool = false
    
    init() {
        let authVM = AuthViewModel()
        _alertManager = StateObject(wrappedValue: AlertManager(authViewModel: authVM))
        _profileManager = StateObject(wrappedValue: ProfileManager(authViewModel: authVM))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if profileManager.isLoading {
                    LoadingView()
                } else if let error = profileManager.error {
                    ErrorView(message: error.localizedDescription) {
                        Task {
                            await profileManager.fetchProfile()
                            await loadAlerts()
                        }
                    }
                } else if let profile = profileManager.profile {
                    ProfileContentView(
                        selectedAlert: $selectedAlert,
                        profile: profile,
                        userAlerts: userAlerts,
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
            await loadAlerts()
        }
        .sheet(item: $selectedAlert) { alert in
            AlertDetailView(alert: alert)
        }
    }
    
    private func loadAlerts() async {
        let alerts = await alertManager.getAlerts()
        await MainActor.run {
            self.userAlerts = alerts
        }
    }
}

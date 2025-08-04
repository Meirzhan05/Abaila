//
//  CreateAlertView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/21/25.
//

import SwiftUI

struct CreateAlertView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var alertManager: AlertManager?
    @State private var title = ""
    @State private var description = ""
    @State private var selectedAlertType = AlertType.general
    @State private var customLocation = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Create Alert")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Alert Created", isPresented: $showingSuccessAlert) {
                    Button("OK") {
                        resetForm()
                    }
                } message: {
                    Text("Your emergency alert has been sent successfully.")
                }
                .onChange(of: alertManager?.isLoading ?? false) { _, isLoading in
                    handleLoadingChange(isLoading)
                }
                .onAppear {
                    initializeAlertManager()
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        Group {
            if let alertManager = alertManager {
                alertContentView(for: alertManager)
            } else {
                LoadingView()
            }
        }
    }
    
    @ViewBuilder
    private func alertContentView(for alertManager: AlertManager) -> some View {
        if alertManager.isLoading {
            LoadingView()
        } else if let error = alertManager.error {
            ErrorView(message: error.localizedDescription) {
                Task {
                    await createAlert()
                }
            }
        } else {
            CreateAlertContentView(
                title: $title,
                description: $description,
                selectedAlertType: $selectedAlertType,
                customLocation: $customLocation,
                alertManager: alertManager
            )
        }
    }
    
    private func initializeAlertManager() {
        if alertManager == nil {
            alertManager = AlertManager(authViewModel: authViewModel)
        }
    }
    
    private func handleLoadingChange(_ isLoading: Bool) {
        if !isLoading && alertManager?.error == nil {
            showingSuccessAlert = true
        }
    }
    
    private func createAlert() async {
        guard let alertManager = alertManager else { return }
        let location = customLocation.isEmpty ? "Current Location" : customLocation
        do {
            try await alertManager.createAlert(
                title: title,
                description: description,
                alertType: selectedAlertType,
                location: location
            )
        } catch {
            print("Failed to create alert: \(error)")
        }
    }
    
    private func resetForm() {
        title = ""
        description = ""
        selectedAlertType = .general
        customLocation = ""
    }
}

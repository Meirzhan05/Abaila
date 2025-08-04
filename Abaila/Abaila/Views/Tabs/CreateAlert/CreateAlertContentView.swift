//
//  CreateAlertContentView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/30/25.
//

import SwiftUI

struct CreateAlertContentView: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var selectedAlertType: AlertType
    @State private var useCurrentLocation = true
    @Binding var customLocation: String
    @State private var isSubmitting = false
    let alertManager: AlertManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        headerSection
                        formContent
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.8), .red.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 8) {
                Text("Emergency Alert")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Fill out the form to notify nearby users")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 32)
    }

    private var formContent: some View {
        VStack(spacing: 24) {
            titleSection
            descriptionSection
            alertTypeSection
            locationSection
            submitSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's happening?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Brief description of emergency", text: $title)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(title.isEmpty ? Color.clear : selectedAlertType.color.opacity(0.3), lineWidth: 1.5)
                )
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Details")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(description.isEmpty ? Color.clear : selectedAlertType.color.opacity(0.3), lineWidth: 1.5)
                    )
                
                if description.isEmpty {
                    Text("Provide more context about the situation...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
                
                TextEditor(text: $description)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    private var alertTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alert Type")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(AlertType.allCases, id: \.self) { alertType in
                    ModernAlertTypeCard(
                        alertType: alertType,
                        isSelected: selectedAlertType == alertType
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedAlertType = alertType
                        }
                    }
                }
            }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use current location")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("Automatically detect your position")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $useCurrentLocation)
                        .toggleStyle(SwitchToggleStyle(tint: selectedAlertType.color))
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                if !useCurrentLocation {
                    TextField("Enter location manually", text: $customLocation)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(customLocation.isEmpty ? Color.clear : selectedAlertType.color.opacity(0.3), lineWidth: 1.5)
                        )
                }
            }
        }
    }

    private var submitSection: some View {
        VStack(spacing: 16) {
            Button(action: submitAlert) {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(isSubmitting ? "Sending Alert..." : "Send Emergency Alert")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isFormValid ? [selectedAlertType.color, selectedAlertType.color.opacity(0.8)] : [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: isFormValid ? selectedAlertType.color.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
            .disabled(!isFormValid || isSubmitting)
            .scaleEffect(isSubmitting ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isSubmitting)
            
            if !isFormValid {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                    Text("Please fill in all required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (useCurrentLocation || !customLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private func submitAlert() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSubmitting = true
        }

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isSubmitting = false
            }
            
            Task {
                do {
                    let location = useCurrentLocation ? "Current Location" : customLocation

                    try await alertManager.createAlert(
                        title: title,
                        description: description,
                        alertType: selectedAlertType,
                        location: location
                    )
                    
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSubmitting = false
                        }
//                        resetForm()
                    }
                } catch {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSubmitting = false
                        }
                    }
                    print("Failed to create alert: \(error)")
                }
            }
        }
        }
    }


struct ModernAlertTypeCard: View {
    let alertType: AlertType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? alertType.color : Color(.tertiarySystemGroupedBackground))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: alertType.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? .white : alertType.color)
                }
                
                Text(alertType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? alertType.color : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? alertType.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? alertType.color.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

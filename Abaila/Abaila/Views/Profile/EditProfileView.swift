//
//  EditProfileView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/15/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var profileManager: ProfileManager
    @State private var username: String = ""
//    @State private var bio: String = ""
//    @State private var location: String = "Downtown Metro Area"
    @State private var email: String = ""
//    @State private var phoneNumber: String = ""
//    @State private var isPrivateProfile: Bool = false
//    @State private var notificationsEnabled: Bool = true
    @State private var showImagePicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
//    @State private var showEditProfile = false
    
    let profile: UserProfile
    
    init(profile: UserProfile) {
        self.profile = profile
        _username = State(initialValue: profile.username)
        _email = State(initialValue: profile.email)
        let authViewModel = AuthViewModel()
        _profileManager = StateObject(wrappedValue: ProfileManager(authViewModel: authViewModel))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Profile Photo Section
                    VStack(spacing: 20) {
                        Button(action: { showImagePicker = true }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .pink, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                
                                // Camera overlay
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .offset(x: 30, y: 30)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("Tap to change photo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Username
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("Enter username", text: $username)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Bio
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Bio")
//                                .font(.subheadline)
//                                .fontWeight(.medium)
//                                .foregroundColor(.primary)
//                            
//                            TextField("Tell us about yourself", text: $bio, axis: .vertical)
//                                .lineLimit(3...6)
//                                .textFieldStyle(CustomTextFieldStyle())
//                        }
//                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("Enter email address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        Task {
                            do {
                                try await profileManager.updateProfile(email: email, username: username)
                                await profileManager.fetchProfile()
                                
                            } catch {
                                print(error.localizedDescription)
                                errorMessage = error.localizedDescription
                                showError = true
                            }

                        }
                    }) {
                        HStack(spacing: 8) {
                            if profileManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(profileManager.isLoading ? "Saving..." : "Save Changes")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isSaving || username.isEmpty || email.isEmpty)
                    .opacity(isSaving || username.isEmpty || email.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showImagePicker) {
            // Add your image picker here
            Text("Image Picker")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
//    private func saveProfile() {
//        isSaving = true
//        
//        // Simulate API call
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            isSaving = false
//            dismiss()
//        }
//    }
}

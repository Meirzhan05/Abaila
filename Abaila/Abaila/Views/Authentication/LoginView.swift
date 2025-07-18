//
//  LoginView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/3/25.
//

import SwiftUI




struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @EnvironmentObject var authViewModel: AuthViewModel


    var body: some View {        
        VStack(spacing: 28) {
            // Title
            Text("Welcome Back")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            // Form fields
            VStack(spacing: 20) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                }

                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    HStack {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .textContentType(.password)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                        }

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                    .textFieldStyle(CustomTextFieldStyle())
                }
            }

            // Forgot password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            // Login button
            Button(action: {
                Task {
                    isLoading = true
                    do {
                        try await authViewModel.login(email: email, password: password)
                    } catch {
                        print(error)
                        print("Register failed \(error)")
                    }
                    isLoading = false
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)

            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))

                Text("or")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
            }

            // Social login
            Button(action: {
                // Handle Google sign in
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "globe")
                        .font(.system(size: 16, weight: .medium))

                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
        .padding(.vertical, 20)
    }

}

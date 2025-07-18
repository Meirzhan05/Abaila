//
//  RegisterView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/3/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var agreeToTerms = false
    @EnvironmentObject var authViewModel: AuthViewModel

    
    var body: some View {
        VStack(spacing: 28) {
            // Title
            Text("Create Account")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            // Form fields
            VStack(spacing: 20) {
                // username field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("Enter your username", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.username)
                }

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
                            TextField("Create a password", text: $password)
                                .textContentType(.newPassword)
                        } else {
                            SecureField("Create a password", text: $password)
                                .textContentType(.newPassword)
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

                // Confirm password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm your password", text: $confirmPassword)
                                .textContentType(.newPassword)
                        } else {
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textContentType(.newPassword)
                        }

                        Button(action: {
                            showConfirmPassword.toggle()
                        }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                    .textFieldStyle(CustomTextFieldStyle())

                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords don't match")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.top, 2)
                    }
                }
            }

            // Terms and conditions
            HStack(alignment: .top, spacing: 10) {
                Button(action: {
                    agreeToTerms.toggle()
                }) {
                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(agreeToTerms ? .blue : .secondary)
                }

                Text("I agree to the ")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                + Text("Terms of Service")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                + Text(" and ")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                + Text("Privacy Policy")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)

                Spacer()
            }

            // Register button
            Button(action: {
                Task {
                    isLoading = true
                    
                    do {
                        print(isLoading)
                        print("Clicked")
                        try await authViewModel.register(
                            username: username, email: email, password: password
                        )
                    } catch {
                        print("Register failed: \(error.localizedDescription)")
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
                        Text("Create Account")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!isFormValid || isLoading)
            .opacity(isFormValid ? 1.0 : 0.6)
        }
        .padding(.vertical, 20)
    }

    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        agreeToTerms
    }
}

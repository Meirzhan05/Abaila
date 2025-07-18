import SwiftUI

struct AuthenticationView: View {
    @State private var showingLogin = true
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.03),
                    Color.purple.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    if showingLogin {
                        LoginView()
                            .environmentObject(authViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    } else {
                        RegisterView()
                            .environmentObject(authViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showingLogin.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(showingLogin ? "Don't have an account?" : "Already have an account?")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15, weight: .medium))
                            
                            Text(showingLogin ? "Sign Up" : "Sign In")
                                .foregroundColor(.blue)
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

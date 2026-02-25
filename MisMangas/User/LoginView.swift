//
//  LoginView.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import SwiftUI

/// Vista de inicio de sesión con diseño Liquid Glass.
///
/// Permite al usuario iniciar sesión con email y contraseña.
/// Muestra errores de validación y autenticación de forma clara.
///
/// ## Uso:
/// ```swift
/// @State private var authVM = AuthViewModel()
///
/// var body: some View {
///     if !authVM.isAuthenticated {
///         LoginView(authVM: authVM)
///     } else {
///         MainTab()
///     }
/// }
/// ```
struct LoginView: View {
    @Bindable var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - Logo y título
                        VStack(spacing: 16) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.blue.gradient)
                                .symbolEffect(.bounce, value: authVM.isAuthenticated)

                            Text("Mis Mangas")
                                .font(.largeTitle.bold())

                            Text("Gestiona tu colección de mangas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)

                        // MARK: - Formulario
                        VStack(spacing: 20) {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Email", systemImage: "envelope.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)

                                TextField("tu@email.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.separator), lineWidth: 0.5)
                                    }
                            }

                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Contraseña", systemImage: "lock.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)

                                SecureField("••••••••", text: $password)
                                    .textContentType(.password)
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.separator), lineWidth: 0.5)
                                    }
                            }

                            // MARK: - Error message
                            if let errorMessage = authVM.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)

                                    Text(errorMessage)
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.scale.combined(with: .opacity))
                            }

                            // MARK: - Login button
                            Button {
                                authVM.clearError()
                                Task {
                                    await authVM.login(email: email, password: password)
                                }
                            } label: {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Iniciar sesión")
                                            .font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                            }
                            .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                            .opacity(authVM.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        }
                        .padding(.horizontal, 24)

                        // MARK: - Register link
                        VStack(spacing: 16) {
                            Divider()

                            Button {
                                showRegister = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("¿No tienes cuenta?")
                                        .foregroundStyle(.secondary)

                                    Text("Regístrate")
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 40)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(authVM: authVM)
            }
            .onAppear {
                authVM.clearError()
            }
            .animation(.easeInOut, value: authVM.errorMessage)
        }
    }
}

#Preview("Login View") {
    @Previewable @State var authVM = AuthViewModel()
    LoginView(authVM: authVM)
}

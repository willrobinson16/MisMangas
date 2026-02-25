//
//  RegisterView.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import SwiftUI

/// Vista de registro de nuevo usuario con diseño Liquid Glass.
///
/// Permite crear una cuenta nueva con email, contraseña y confirmación.
/// Valida que las contraseñas coincidan y cumplan requisitos mínimos.
/// Después del registro exitoso, realiza login automático.
///
/// ## Uso:
/// ```swift
/// @State private var authVM = AuthViewModel()
///
/// RegisterView(authVM: authVM)
/// ```
struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
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
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .font(.system(size: 70))
                            .foregroundStyle(.blue.gradient)
                            .symbolEffect(.bounce, value: authVM.isAuthenticated)

                        Text("Crear cuenta")
                            .font(.largeTitle.bold())

                        Text("Únete a la comunidad de MisMangas")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

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

                            SecureField("Mínimo 8 caracteres", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                }

                            // Password requirements
                            if !password.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(password.count >= 8 ? .green : .red)
                                        .font(.caption)

                                    Text("Mínimo 8 caracteres")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }

                        // Confirm password field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Confirmar contraseña", systemImage: "lock.fill")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)

                            SecureField("Repite tu contraseña", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                }

                            // Password match indicator
                            if !confirmPassword.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(password == confirmPassword ? .green : .red)
                                        .font(.caption)

                                    Text(password == confirmPassword ? "Las contraseñas coinciden" : "Las contraseñas no coinciden")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .transition(.scale.combined(with: .opacity))
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

                        // MARK: - Register button
                        Button {
                            authVM.clearError()
                            Task {
                                await authVM.register(
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            }
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Crear cuenta")
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
                        .disabled(authVM.isLoading || !isFormValid)
                        .opacity(authVM.isLoading || !isFormValid ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Login link
                    VStack(spacing: 16) {
                        Divider()

                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Text("¿Ya tienes cuenta?")
                                    .foregroundStyle(.secondary)

                                Text("Inicia sesión")
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
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            authVM.clearError()
        }
        .animation(.easeInOut, value: authVM.errorMessage)
        .animation(.easeInOut, value: password)
        .animation(.easeInOut, value: confirmPassword)
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }

    // MARK: - Keyboard Helper
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview("Register View") {
    @Previewable @State var authVM = AuthViewModel()
    NavigationStack {
        RegisterView(authVM: authVM)
    }
}

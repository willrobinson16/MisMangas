//
//  AuthViewModel.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel para gestionar la autenticación y sesión del usuario.
///
/// Gestiona el estado de autenticación, login, registro y logout.
/// Compatible con Swift 6 concurrency y aislado a @MainActor para UI.
///
/// ## Uso en SwiftUI:
/// ```swift
/// @State private var authVM = AuthViewModel()
///
/// var body: some View {
///     if authVM.isAuthenticated {
///         MainTab()
///     } else {
///         LoginView(authVM: authVM)
///     }
/// }
/// ```
@Observable @MainActor
final class AuthViewModel {

    // MARK: - Published State

    /// Indica si el usuario está autenticado (tiene token válido)
    var isAuthenticated: Bool = false

    /// Indica si hay una operación en curso (login, register, logout)
    var isLoading: Bool = false

    /// Mensaje de error para mostrar al usuario
    var errorMessage: String?

    /// Información del usuario autenticado (nil si no está autenticado)
    var currentUser: UserResponse?

    // MARK: - Private Properties

    /// Repositorio de autenticación
    private let authRepo: UserAuthRepository = UserAuth()

    /// Repositorio de colección para sincronización
    private let collectionRepo: CollectionRepository = Collection()

    /// ModelContext para persistencia (inyectado desde la vista)
    private var modelContext: ModelContext?

    /// Sets the model context for data persistence
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    // MARK: - Initialization

    init() {
        // Verificar si hay token al inicializar
        Task {
            await checkAuthenticationStatus()
        }
    }

    // MARK: - Public Methods

    /// Verifica si existe un token válido en el Keychain.
    ///
    /// Llama a este método al iniciar la app para verificar sesión.
    func checkAuthenticationStatus() async {
        do {
            // Intentar obtener info del usuario con el token actual
            let user = try await authRepo.getMe()
            self.currentUser = user
            self.isAuthenticated = true

            // Sincronizar colección del servidor
            await syncCollectionFromServer()
        } catch {
            // No hay token o es inválido
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }

    /// Inicia sesión con email y password.
    ///
    /// - Parameters:
    ///   - email: Email del usuario.
    ///   - password: Contraseña del usuario.
    func login(email: String, password: String) async {
        guard !isLoading else { return }

        // Validar inputs
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email y contraseña son requeridos"
            return
        }

        guard isValidEmail(email) else {
            self.errorMessage = "Email no válido"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Login y guardar token
            _ = try await authRepo.login(email: email, password: password)

            // Obtener info del usuario
            let user = try await authRepo.getMe()
            self.currentUser = user
            self.isAuthenticated = true

            // Sincronizar colección del servidor
            await syncCollectionFromServer()

        } catch let error as AuthError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Error al iniciar sesión. Intenta nuevamente."
        }

        isLoading = false
    }

    /// Registra un nuevo usuario.
    ///
    /// - Parameters:
    ///   - email: Email del nuevo usuario.
    ///   - password: Contraseña del nuevo usuario.
    ///   - confirmPassword: Confirmación de contraseña.
    func register(email: String, password: String, confirmPassword: String) async {
        guard !isLoading else { return }

        // Validar inputs
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            self.errorMessage = "Todos los campos son requeridos"
            return
        }

        guard isValidEmail(email) else {
            self.errorMessage = "Email no válido"
            return
        }

        guard password.count >= 8 else {
            self.errorMessage = "La contraseña debe tener al menos 8 caracteres"
            return
        }

        guard password == confirmPassword else {
            self.errorMessage = "Las contraseñas no coinciden"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Registrar usuario
            let userData = UsersCreate(email: email, password: password)
            try await authRepo.register(userData)

            // Después de registrar, hacer login automático
            await login(email: email, password: password)

        } catch let error as AuthError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Error al registrar usuario. Intenta nuevamente."
        }

        isLoading = false
    }

    /// Cierra sesión del usuario actual.
    func logout() async {
        guard !isLoading else { return }

        isLoading = true

        do {
            try await authRepo.logout()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = "Error al cerrar sesión"
        }

        isLoading = false
    }

    /// Renueva el token JWT actual.
    ///
    /// Llamar este método antes de que expire el token (24 horas).
    func refreshToken() async {
        do {
            _ = try await authRepo.refreshToken()
        } catch {
            // Si falla el refresh, cerrar sesión
            await logout()
        }
    }

    /// Limpia el mensaje de error.
    func clearError() {
        errorMessage = nil
    }

    /// Maneja errores de autenticación (401/403) y hace logout si es necesario.
    ///
    /// Llamar este método cuando se detecte un error 401 en cualquier parte de la app.
    ///
    /// - Parameter error: El error capturado.
    /// - Returns: `true` si era un error de autenticación y se hizo logout.
    @discardableResult
    func handleAuthError(_ error: Error) async -> Bool {
        if let authError = error as? AuthError {
            switch authError {
            case .unauthorized, .tokenExpired, .tokenNotFound:
                // Hacer logout automáticamente
                await logout()
                self.errorMessage = "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."
                return true
            default:
                return false
            }
        }
        return false
    }

    // MARK: - Private Helpers

    /// Sincroniza la colección del usuario desde el servidor.
    ///
    /// Descarga la colección completa y la guarda en SwiftData local.
    private func syncCollectionFromServer() async {
        guard let context = modelContext else {
            return
        }

        do {
            _ = try await SyncManager.shared.fullSyncFromServer(context: context)
        } catch {
        }
    }

    /// Valida formato de email.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

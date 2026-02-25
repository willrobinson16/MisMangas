//
//  UserAuthRepository.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import NetworkAPI

/// Repositorio para operaciones de autenticación de usuarios (JWT).
///
/// Gestiona registro, login y obtención de información del usuario autenticado.
/// Utiliza autenticación JWT (Bearer token) y almacena tokens en Keychain.
///
/// ## Flujo de autenticación:
/// 1. **Register**: `POST /users` con App-Token → guarda usuario en servidor
/// 2. **Login**: `POST /users/jwt/login` con Basic Auth → recibe JWT y lo guarda en Keychain
/// 3. **Get Me**: `GET /users/jwt/me` con Bearer token → info del usuario autenticado
/// 4. **Refresh**: `POST /users/jwt/refresh` con Bearer token → renueva JWT
protocol UserAuthRepository: Sendable, NetworkInteractor {
    /// Registra un nuevo usuario en el servidor.
    ///
    /// Requiere App-Token en el header. Email debe ser único y contraseña mínima 8 caracteres.
    ///
    /// - Parameter userData: Datos del usuario (email y password).
    /// - Throws: `AuthError.registrationFailed` si falla el registro.
    func register(_ userData: UsersCreate) async throws

    /// Inicia sesión con credenciales del usuario y guarda el token JWT en Keychain.
    ///
    /// Usa Basic Auth con email y password. El JWT es válido por 24 horas.
    ///
    /// - Parameters:
    ///   - email: Email del usuario.
    ///   - password: Contraseña del usuario.
    /// - Returns: El token JWT recibido del servidor.
    /// - Throws: `AuthError.invalidCredentials` si las credenciales son incorrectas.
    func login(email: String, password: String) async throws -> String

    /// Obtiene la información del usuario autenticado actual.
    ///
    /// Requiere token JWT válido en Keychain.
    ///
    /// - Returns: Información del usuario autenticado.
    /// - Throws: `AuthError.unauthorized` si el token no es válido o ha expirado.
    func getMe() async throws -> UserResponse

    /// Renueva el token JWT actual.
    ///
    /// Genera un nuevo JWT y lo guarda en Keychain, invalidando el anterior.
    ///
    /// - Returns: El nuevo token JWT.
    /// - Throws: `AuthError.tokenExpired` si el token actual no es válido.
    func refreshToken() async throws -> String

    /// Cierra sesión eliminando el token del Keychain.
    func logout() async throws
}

// MARK: - Implementation

struct UserAuth: UserAuthRepository {

    // MARK: - Register

    func register(_ userData: UsersCreate) async throws {
        let request = URLRequest.postWithAppToken(url: .register, body: userData)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.registrationFailed("Respuesta inválida del servidor")
            }

            guard httpResponse.statusCode == 201 else {
                throw AuthError.registrationFailed("Código de estado: \(httpResponse.statusCode)")
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.registrationFailed(error.localizedDescription)
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async throws -> String {
        let request = URLRequest.postBasicAuth(url: .jwtLogin, username: email, password: password)

        do {
            let jwtResponse: JWTTokenResponse = try await getJSON(request, type: JWTTokenResponse.self)

            // Guardar token en Keychain
            try await KeychainManager.shared.saveToken(jwtResponse.jwt)

            return jwtResponse.jwt
        } catch {
            throw AuthError.invalidCredentials
        }
    }

    // MARK: - Get Me

    func getMe() async throws -> UserResponse {
        let request = try await URLRequest.getAuthenticated(url: .jwtMe)

        do {
            return try await getJSON(request, type: UserResponse.self)
        } catch {
            throw AuthError.unauthorized
        }
    }

    // MARK: - Refresh Token

    func refreshToken() async throws -> String {
        let request = try await URLRequest.postAuthenticated(url: .jwtRefresh, body: EmptyBody())

        do {
            let jwtResponse: JWTTokenResponse = try await getJSON(request, type: JWTTokenResponse.self)

            // Guardar nuevo token en Keychain
            try await KeychainManager.shared.saveToken(jwtResponse.jwt)

            return jwtResponse.jwt
        } catch {
            throw AuthError.tokenExpired
        }
    }

    // MARK: - Logout

    func logout() async throws {
        try await KeychainManager.shared.deleteToken()
    }
}

// MARK: - Helper

/// Body vacío para peticiones POST sin body
private struct EmptyBody: Codable, Sendable {}

//
//  URLRequest+Auth.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import NetworkAPI

/// Extensión de URLRequest para añadir métodos específicos de autenticación
/// que requieren acceso al KeychainManager del proyecto.
///
/// Las funciones básicas get() y post() están en NetworkAPI package.
/// Esta extensión solo añade las variantes autenticadas y especializadas.
extension URLRequest {

    // MARK: - App Token

    /// Token de aplicación para registro de usuarios
    private static let appToken = "sLGH38NhEJ0_anlIWwhsz1-LarClEohiAHQqayF0FY"

    // MARK: - Authenticated Requests (con token del Keychain)

    /// Crea una petición GET autenticada con el token JWT del Keychain.
    ///
    /// - Parameter url: La URL del endpoint de la API.
    /// - Returns: Un `URLRequest` configurado con el token del usuario autenticado.
    /// - Throws: `AuthError.tokenNotFound` si no se puede leer el token.
    public static func getAuthenticated(url: URL) async throws -> URLRequest {
        guard let token = try await KeychainManager.shared.getToken() else {
            throw AuthError.tokenNotFound
        }

        var request = get(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    /// Crea una petición POST autenticada con el token JWT del Keychain.
    ///
    /// - Parameters:
    ///   - url: La URL del endpoint de la API.
    ///   - body: El objeto `Codable` que se enviará como cuerpo.
    ///   - method: El método HTTP (por defecto "POST").
    /// - Returns: Un `URLRequest` configurado con el token del usuario autenticado.
    /// - Throws: `AuthError.tokenNotFound` si no se puede leer el token.
    public static func postAuthenticated<JSON>(url: URL, body: JSON, method: String = "POST") async throws -> URLRequest where JSON: Codable {
        guard let token = try await KeychainManager.shared.getToken() else {
            throw AuthError.tokenNotFound
        }

        var request = post(url: url, body: body, method: method)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    /// Crea una petición DELETE autenticada con el token JWT del Keychain.
    ///
    /// - Parameter url: La URL del endpoint de la API.
    /// - Returns: Un `URLRequest` configurado con método DELETE y token.
    /// - Throws: `AuthError.tokenNotFound` si no se puede leer el token.
    public static func deleteAuthenticated(url: URL) async throws -> URLRequest {
        guard let token = try await KeychainManager.shared.getToken() else {
            throw AuthError.tokenNotFound
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    // MARK: - Basic Auth (Login)

    /// Crea una petición POST con autenticación Basic Auth (para login JWT).
    ///
    /// - Parameters:
    ///   - url: La URL del endpoint de login.
    ///   - username: Email del usuario.
    ///   - password: Contraseña del usuario.
    /// - Returns: Un `URLRequest` configurado con Basic Auth en el header Authorization.
    public static func postBasicAuth(url: URL, username: String, password: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Basic Auth: Base64 encode de "username:password"
        let credentials = "\(username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - App Token (Register)

    /// Crea una petición POST con App-Token para registro de usuarios.
    ///
    /// - Parameters:
    ///   - url: La URL del endpoint de registro.
    ///   - body: Los datos del usuario a registrar.
    /// - Returns: Un `URLRequest` configurado con App-Token en el header.
    public static func postWithAppToken<JSON>(url: URL, body: JSON) -> URLRequest where JSON: Codable {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(appToken, forHTTPHeaderField: "App-Token")
        request.httpBody = try? JSONEncoder().encode(body)

        return request
    }
}


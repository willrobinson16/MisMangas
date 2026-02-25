//
//  KeychainManager.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import Security

/// Actor que gestiona el almacenamiento seguro de tokens JWT en el Keychain de iOS.
///
/// Compatible con Swift 6 concurrency. Utiliza el framework Security de Apple
/// sin dependencias externas. Todas las operaciones son thread-safe gracias al
/// aislamiento del actor.
///
/// ## Uso:
/// ```swift
/// let keychain = KeychainManager.shared
///
/// // Guardar token
/// try await keychain.saveToken("jwt_token_string")
///
/// // Leer token
/// if let token = try await keychain.getToken() {
///     print("Token: \(token)")
/// }
///
/// // Eliminar token
/// try await keychain.deleteToken()
/// ```
actor KeychainManager {

    /// Instancia compartida del KeychainManager
    static let shared = KeychainManager()

    /// Identificador único para el token JWT en el Keychain
    private let tokenKey = "com.grobinson.MisMangas.jwtToken"

    /// Servicio asociado al token en el Keychain
    private let service = "MisMangas"

    private init() {}

    // MARK: - Public Methods

    /// Guarda el token JWT en el Keychain de forma segura.
    ///
    /// Si ya existe un token, lo reemplaza automáticamente.
    ///
    /// - Parameter token: El token JWT como String.
    /// - Throws: `KeychainError` si la operación falla.
    func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        // Intentar actualizar primero
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)

        // Si no existe, crear nuevo
        if updateStatus == errSecItemNotFound {
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: tokenKey,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

            guard addStatus == errSecSuccess else {
                throw KeychainError.saveFailed(status: addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.updateFailed(status: updateStatus)
        }
    }

    /// Lee el token JWT almacenado en el Keychain.
    ///
    /// - Returns: El token JWT como String, o `nil` si no existe.
    /// - Throws: `KeychainError` si la operación falla.
    func getToken() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status: status)
        }

        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return token
    }

    /// Elimina el token JWT del Keychain.
    ///
    /// - Throws: `KeychainError` si la operación falla.
    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }

    /// Verifica si existe un token almacenado en el Keychain.
    ///
    /// - Returns: `true` si existe un token, `false` en caso contrario.
    func hasToken() async -> Bool {
        do {
            return try getToken() != nil
        } catch {
            return false
        }
    }
}

// MARK: - KeychainError

/// Errores específicos del KeychainManager
enum KeychainError: Error, LocalizedError {
    case invalidData
    case saveFailed(status: OSStatus)
    case updateFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Los datos del token no son válidos"
        case .saveFailed(let status):
            return "Error al guardar el token en Keychain (código: \(status))"
        case .updateFailed(let status):
            return "Error al actualizar el token en Keychain (código: \(status))"
        case .readFailed(let status):
            return "Error al leer el token del Keychain (código: \(status))"
        case .deleteFailed(let status):
            return "Error al eliminar el token del Keychain (código: \(status))"
        }
    }
}

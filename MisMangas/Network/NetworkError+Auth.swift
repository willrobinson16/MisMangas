//
//  NetworkError+Auth.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation

/// Errores específicos de autenticación que extienden el sistema de errores de red.
enum AuthError: Error, LocalizedError {
    case unauthorized // 401
    case tokenExpired
    case tokenNotFound
    case invalidCredentials
    case registrationFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "No autorizado. Por favor, inicia sesión nuevamente."
        case .tokenExpired:
            return "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."
        case .tokenNotFound:
            return "No se encontró el token de autenticación."
        case .invalidCredentials:
            return "Email o contraseña incorrectos."
        case .registrationFailed(let message):
            return "Error en el registro: \(message)"
        }
    }
}

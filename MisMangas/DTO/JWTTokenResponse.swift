//
//  JWTTokenResponse.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - JWT Token Response
/// Respuesta del servidor al hacer login JWT.
///
/// Devuelto por `POST /users/jwt/login` con Basic Auth.
/// El token JWT es válido por 24 horas (86400 segundos).
struct JWTTokenResponse: Codable, Sendable {
    let token: String
    let tokenType: String
    let expiresIn: Int

    /// Alias para acceso directo al token JWT
    var jwt: String {
        token
    }

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType
        case expiresIn
    }
}

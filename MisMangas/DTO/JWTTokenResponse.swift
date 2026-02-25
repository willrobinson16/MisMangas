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
/// El token JWT es válido por 24 horas.
struct JWTTokenResponse: Codable, Sendable {
    let jwt: String

    enum CodingKeys: String, CodingKey {
        case jwt
    }
}

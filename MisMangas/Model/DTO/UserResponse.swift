//
//  UserResponse.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Response
/// Información del usuario autenticado.
///
/// Devuelto por `GET /users/jwt/me` con token JWT Bearer.
struct UserResponse: Codable, Sendable {
    let id: UUID
    let email: String
    let role: String
    let isAdmin: Bool
    let isActive: Bool
}

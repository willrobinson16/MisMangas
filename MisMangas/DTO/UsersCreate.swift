//
//  UsersCreate.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Creation Request
/// DTO para crear un nuevo usuario en el servidor.
///
/// Usado en `POST /users` con App-Token header.
///
/// ## Requisitos:
/// - Email debe ser válido y único
/// - Password mínimo 8 caracteres
struct UsersCreate: Codable, Sendable {
    let email: String
    let password: String
}

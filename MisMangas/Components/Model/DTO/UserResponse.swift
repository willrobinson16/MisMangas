//
//  UserResponse.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Response
/// Authenticated user information
struct UserResponse: Codable {
    let id: UUID
    let email: String
    let role: String
    let isAdmin: Bool
    let isActive: Bool
}

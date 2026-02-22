//
//  UsersCreate.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Creation Request
/// Request body for creating a new user
struct UsersCreate: Codable {
    let email: String
    let password: String
}

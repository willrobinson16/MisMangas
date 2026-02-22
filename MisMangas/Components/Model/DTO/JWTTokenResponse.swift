//
//  JWTTokenResponse.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - JWT Token Response
/// JWT authentication response
struct JWTTokenResponse: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int
}

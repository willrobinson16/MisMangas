//
//  AuthorIdsRequest.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Author IDs Request
/// Request body with author IDs
struct AuthorIdsRequest: Codable {
    let ids: [UUID]
}

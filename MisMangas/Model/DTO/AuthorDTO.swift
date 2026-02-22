//
//  AuthorDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Author Response DTO
/// Author information
struct AuthorDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: AuthorRole
    
    var toAuthor: Author {
        Author(id: id, firstName: firstName, lastName: lastName, role: role)
    }
}

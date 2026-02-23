//
//  AuthorDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Author Response DTO

/// Data Transfer Object para información de un autor desde la API.
///
/// Contiene los datos básicos de un autor de manga incluyendo su rol
/// (Story, Art, o Story and Art).
///
/// ## Conversión:
/// ```swift
/// let author: Author = authorDTO.toAuthor
/// ```
struct AuthorDTO: Codable, Identifiable, Hashable {
    /// ID único del autor (UUID)
    let id: UUID
    /// Nombre del autor
    let firstName: String
    /// Apellido del autor
    let lastName: String
    /// Rol del autor en el manga (Story, Art, Story and Art)
    let role: AuthorRole

    /// Convierte el DTO a un modelo SwiftData `Author`
    var toAuthor: Author {
        Author(id: id, firstName: firstName, lastName: lastName, role: role)
    }
}

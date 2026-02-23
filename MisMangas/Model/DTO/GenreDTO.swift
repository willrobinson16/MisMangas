//
//  GenreDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Genre Response DTO

/// Data Transfer Object para géneros de manga desde la API.
///
/// Representa géneros como "Action", "Romance", "Horror", etc.
///
/// ## Ejemplo:
/// ```json
/// {
///   "id": "550E8400-E29B-41D4-A716-446655440001",
///   "genre": "Action"
/// }
/// ```
struct GenreDTO: Codable, Identifiable, Hashable {
    /// ID único del género (UUID)
    let id: UUID
    /// Nombre del género
    let genre: String
}

extension GenreDTO {
    /// Convierte el DTO a un modelo SwiftData `Genre`
    var toGenre: Genre {
        Genre(id: id, genre: genre)
    }
}

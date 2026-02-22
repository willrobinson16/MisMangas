//
//  GenreDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Genre Response DTO
/// Genre classification
struct GenreDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let genre: String
}

extension GenreDTO {
    var toGenre: Genre {
        Genre(id: id, genre: genre)
    }
}

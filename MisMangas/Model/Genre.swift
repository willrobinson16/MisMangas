//
//  Genre.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import Foundation

/// Genre model matching GenreDTO structure
struct Genre: Codable, Identifiable, Hashable {
    let id: UUID
    let genre: String
}

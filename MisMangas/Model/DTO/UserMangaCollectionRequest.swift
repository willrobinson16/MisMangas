//
//  UserMangaCollectionRequest.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation

//MARK: - User Collection Request DTO
/// DTO para enviar al servidor al añadir/actualizar manga en colección.
///
/// El servidor espera:
/// ```json
/// {
///   "id": "UUID-string",
///   "manga": 123,
///   "readingVolume": 5,
///   "completeCollection": false,
///   "volumesOwned": [1, 2, 3, 4, 5]
/// }
/// ```
struct UserMangaCollectionRequest: Codable, Sendable {
    let id: UUID
    let manga: Int  // ← Solo el ID del manga
    let readingVolume: Int?
    let completeCollection: Bool
    let volumesOwned: [Int]
}

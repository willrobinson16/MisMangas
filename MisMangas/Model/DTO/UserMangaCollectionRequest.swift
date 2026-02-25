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
/// Según la documentación de la API:
/// POST /collection/manga
/// ```json
/// {
///   "manga": 123,
///   "volumesOwned": [1, 2, 3, 4, 5],
///   "completeCollection": false,
///   "readingVolume": 5  // opcional, nullable
/// }
/// ```
///
/// IMPORTANTE: NO incluir campo "id" - el servidor no lo espera
struct UserMangaCollectionRequest: Codable, Sendable {
    let manga: Int
    let volumesOwned: [Int]
    let completeCollection: Bool
    let readingVolume: Int?
}

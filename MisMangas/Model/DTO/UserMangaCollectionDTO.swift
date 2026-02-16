//
//  UserMangaCollectionDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Collection Response DTO
/// User's manga collection entry
struct UserMangaCollectionDTO: Codable {
    let id: UUID
    let readingVolume: Int?
    let completeCollection: Bool
    let volumesOwned: [Int]
    let manga: MangaDTO
}

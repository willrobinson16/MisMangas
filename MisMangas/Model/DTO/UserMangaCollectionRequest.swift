//
//  UserMangaCollectionRequest.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - User Collection Request
/// Request to add or update manga in collection
struct UserMangaCollectionRequest: Codable {
    let manga: Int
    let completeCollection: Bool
    let volumesOwned: [Int]
    let readingVolume: Int?
}

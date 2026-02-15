//
//  MangaStatus.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Manga Status
enum MangaStatus: String, Codable {
    case discontinued = "discontinued"
    case onHiatus = "on_hiatus"
    case currentlyPublishing = "publishing"
    case finished = "finished"
    case none = "none"
}

//
//  MangaDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

struct ModelDTO: Codable {
    let status: Status
    let background: String
    let title: String
    let titleEnglish: String
    let score: Double
    let chapters: Int
    let startDate: String
}

enum Status {
    case finished /*= "finished"*/
    case currentlyPublishing/* = "currently_publishing"*/
}

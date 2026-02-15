//
//  MangaDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Manga Response DTO
/// Complete manga information with related data
struct MangaDTO: Codable, Identifiable, Hashable {
    let id: Int
    let status: MangaStatus
    let background: String?
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let score: Double
    let chapters: Int?
    let startDate: String?
    let themes: [ThemeDTO]
    let mainPicture: String?
    let authors: [AuthorDTO]
    let synopsis: String?
    let url: String?
    let genres: [GenreDTO]
    let volumes: Int?
    let endDate: String?
    let demographics: [DemographicDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, status, background, title, titleEnglish, titleJapanese
        case score, chapters, startDate, themes, mainPicture, authors
        case synopsis = "sypnosis"
        case url, genres, volumes, endDate, demographics
    }
}

extension MangaDTO {
    var toManga: Manga {
        Manga(
            id: id,
            status: status.rawValue,
            background: background,
            title: title,
            titleEnglish: titleEnglish,
            titleJapanese: titleJapanese,
            score: score,
            chapters: chapters,
            startDate: startDate,
            endDate: endDate,
            mainPicture: mainPicture.flatMap { URL(string: $0.cleanedURL) },
            synopsis: synopsis ?? "",
            url: url.flatMap { URL(string: $0.cleanedURL) },
            volumes: volumes,
            themes: themes.map { Theme(id: $0.id, theme: $0.theme) },
            authors: authors.map(\.toAuthor),
            genres: genres.map { Genre(id: $0.id, genre: $0.genre) },
            demographics: demographics.map { Demographic(id: $0.id, demographic: $0.demographic) }
        )
    }
    
    nonisolated var mainPictureURL: URL? {
        mainPicture.flatMap { URL(string: $0.cleanedURL) }
    }
    
    nonisolated var urlCleaned: URL? {
        url.flatMap { URL(string: $0.cleanedURL) }
    }
}

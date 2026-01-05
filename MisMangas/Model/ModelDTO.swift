//
//  ModelDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

//MARK: - Preestruct para poder recuperar la información de items
struct Items: Codable {
    let items: [MangaDTO]
}

//MARK: - Manga Response DTO: Complete manga information with related data
struct MangaDTO: Codable, Identifiable {
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
    let mainPicture: URL?
    let authors: [AuthorDTO]
    let synopsis: String?
    let url: URL?
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decodificar campos normales
        id = try container.decode(Int.self, forKey: .id)
        status = try container.decode(MangaStatus.self, forKey: .status)
        background = try container.decodeIfPresent(String.self, forKey: .background)
        title = try container.decode(String.self, forKey: .title)
        titleEnglish = try container.decodeIfPresent(String.self, forKey: .titleEnglish)
        titleJapanese = try container.decodeIfPresent(String.self, forKey: .titleJapanese)
        score = try container.decode(Double.self, forKey: .score)
        chapters = try container.decodeIfPresent(Int.self, forKey: .chapters)
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
        themes = try container.decode([ThemeDTO].self, forKey: .themes)
        authors = try container.decode([AuthorDTO].self, forKey: .authors)
        genres = try container.decode([GenreDTO].self, forKey: .genres)
        demographics = try container.decode([DemographicDTO].self, forKey: .demographics)
        volumes = try container.decodeIfPresent(Int.self, forKey: .volumes)
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate)
        
        // Decodificar synopsis (limpiando comillas si existen)
        if let synopsisString = try container.decodeIfPresent(String.self, forKey: .synopsis) {
            synopsis = synopsisString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        } else {
            synopsis = nil
        }
        
        // Decodificar mainPicture como String y convertir a URL (limpiando comillas)
        if let mainPictureString = try container.decodeIfPresent(String.self, forKey: .mainPicture) {
            let cleaned = mainPictureString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            mainPicture = URL(string: cleaned)
        } else {
            mainPicture = nil
        }
        
        // Decodificar url como String y convertir a URL (limpiando comillas)
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url) {
            let cleaned = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            url = URL(string: cleaned)
        } else {
            url = nil
        }
    }
}

//MARK: - Theme Response DTO: Theme or setting
struct ThemeDTO: Codable, Identifiable {
    let id: UUID
    let theme: String
}

//MARK: - Author Response DTO: Author information
struct AuthorDTO: Codable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: String
}

//MARK: - Genre Response DTO: Genre classification
struct GenreDTO: Codable, Identifiable {
    let id: UUID
    let genre: String
}

//MARK: - Demographic Response DTO: Target demographic
struct DemographicDTO: Codable, Identifiable {
    let id: UUID
    let demographic: String
}

//MARK: - Manga status
enum MangaStatus: String, Codable {
    case discontinued = "discontinued"
    case onHiatus = "on_hiatus"
    case currentlyPublishing = "currently_publishing"
    case finished = "finished"
    case none = "none"
}

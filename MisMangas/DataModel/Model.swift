//
//  Models.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation
import SwiftData

//MARK: - Persistence models
@Model
final class Manga {
    #Index<Manga>([\.title])
    @Attribute(.unique) var id: Int
    var status: String
    var background: String?
    var title: String
    var titleEnglish: String?
    var titleJapanese: String?
    var score: Double
    var chapters: Int?
    var startDate: String?
    var endDate: String?
    var mainPicture: URL?
    var synopsis: String?
    var url: URL?
    var volumes: Int?
    @Relationship var themes: [Theme]
    @Relationship var authors: [Author]
    @Relationship var genres: [Genre]
    @Relationship var demographics: [Demographic]
    
    init(id: Int, status: String, background: String?, title: String, titleEnglish: String?, titleJapanese: String?, score: Double, chapters: Int?, startDate: String?, endDate: String?, mainPicture: URL?, synopsis: String?, url: URL?, volumes: Int?, themes: [Theme], authors: [Author], genres: [Genre], demographics: [Demographic]) {
        self.id = id
        self.status = status
        self.background = background
        self.title = title
        self.titleEnglish = titleEnglish
        self.titleJapanese = titleJapanese
        self.score = score
        self.chapters = chapters
        self.startDate = startDate
        self.endDate = endDate
        self.mainPicture = mainPicture
        self.synopsis = synopsis
        self.url = url
        self.volumes = volumes
        self.themes = themes
        self.authors = authors
        self.genres = genres
        self.demographics = demographics
    }
}

extension Manga {
    var scoreS: String {
        score.formatted(.number.precision(.integerAndFractionLength(integer: 1, fraction: 2)))
    }
    
    var authorsString: String {
        authors.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
    }
    
    var authorsWithRole: String {
        authors.map { "\($0.firstName) \($0.lastName) (\($0.role))" }.joined(separator: " • ")
    }
    
    /// Test manga
    @MainActor static let test = Manga(
        id: 13,
        status: "currently_publishing",
        background: "One Piece is the best-selling manga series in history, with over 500 million copies in circulation worldwide.",
        title: "One Piece",
        titleEnglish: "One Piece",
        titleJapanese: "ワンピース",
        score: 9.21,
        chapters: 1100,
        startDate: "1997-07-25T00:00:00Z",
        endDate: nil,
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/2/253146.jpg"),
        synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his death revealed the existence of the greatest treasure in the world, One Piece.",
        url: URL(string: "https://myanimelist.net/manga/13/One_Piece"),
        volumes: 107,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440002")!, theme: "Adventure")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440000")!, firstName: "Eiichiro", lastName: "Oda", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440001")!, genre: "Action")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440003")!, demographic: "Shounen")
        ]
    )
}

@Model
final class Author {
    #Index<Author>([\.firstName], [\.lastName])
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var role: String
    
    @Relationship(deleteRule: .cascade, inverse: \Manga.authors) var mangas: [Manga]
    
    init(id: UUID, firstName: String, lastName: String, role: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.mangas = []
    }
}

extension Author {
    /// Test authors
    @MainActor static let eiichiroOda = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440000")!,
        firstName: "Eiichiro",
        lastName: "Oda",
        role: "Story & Art"
    )
    
    @MainActor static let masashiKishimoto = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440012")!,
        firstName: "Masashi",
        lastName: "Kishimoto",
        role: "Story & Art"
    )
    
    @MainActor static let tsugumiOhba = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440022")!,
        firstName: "Tsugumi",
        lastName: "Ohba",
        role: "Story"
    )
    
    @MainActor static let takeshiObata = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440023")!,
        firstName: "Takeshi",
        lastName: "Obata",
        role: "Art"
    )
    
    @MainActor static let test = [eiichiroOda, masashiKishimoto, tsugumiOhba, takeshiObata]
}

@Model
final class Theme {
    #Index<Theme>([\.theme])
    @Attribute(.unique) var id: UUID
    var theme: String
    
    init(id: UUID, theme: String) {
        self.id = id
        self.theme = theme
    }
}

@Model
final class Genre {
    #Index<Genre>([\.genre])
    @Attribute(.unique) var id: UUID
    var genre: String
    
    init(id: UUID, genre: String) {
        self.id = id
        self.genre = genre
    }
}

@Model
final class Demographic {
    #Index<Demographic>([\.demographic])
    @Attribute(.unique) var id: UUID
    var demographic: String

    init(id: UUID, demographic: String) {
        self.id = id
        self.demographic = demographic
    }
}


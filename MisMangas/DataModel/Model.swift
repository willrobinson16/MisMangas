//
//  Models.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation
import SwiftData

//MARK: - Modelos de Persistencia

/// Modelo principal de Manga para persistencia con SwiftData.
///
/// Representa un manga completo con toda su información y relaciones.
/// Utiliza el macro `@Model` de SwiftData para conversión automática a Core Data.
///
/// ## Características:
/// - ID único con restricción de unicidad
/// - Índice en el campo `title` para optimizar búsquedas
/// - Relaciones bidireccionales con Theme, Author, Genre y Demographic
/// - Propiedades opcionales para información que puede no estar disponible
///
/// ## Relaciones:
/// - **themes**: Temas asociados al manga (ej. "Adventure", "Fantasy")
/// - **authors**: Autores que participaron en la creación del manga
/// - **genres**: Géneros del manga (ej. "Action", "Romance")
/// - **demographics**: Demografía objetivo (ej. "Shounen", "Seinen")
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
    /// Formatea el score del manga con 2 decimales
    var scoreS: String {
        score.formatted(.number.precision(.integerAndFractionLength(integer: 1, fraction: 2)))
    }

    /// Retorna una cadena con los nombres completos de todos los autores, separados por comas
    var authorsString: String {
        authors.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
    }

    /// Retorna una cadena con los nombres completos de todos los autores y sus roles, separados por puntos medios
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
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440000")!, firstName: "Eiichiro", lastName: "Oda", role: .storyAndArt)
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440001")!, genre: "Action")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440003")!, demographic: "Shounen")
        ]
    )
}

/// Modelo de Autor para persistencia con SwiftData.
///
/// Representa un autor de manga con su información personal y rol.
///
/// ## Características:
/// - UUID único con restricción de unicidad
/// - Índices en firstName y lastName para optimizar búsquedas
/// - Relación inversa con Manga con regla de borrado en cascada
/// - Rol específico del autor (Story, Art, o Story and Art)
///
/// ## Relaciones:
/// - **mangas**: Lista de mangas en los que ha participado este autor
@Model
final class Author {
    #Index<Author>([\.firstName], [\.lastName])
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var role: AuthorRole
    
    @Relationship(deleteRule: .cascade, inverse: \Manga.authors) var mangas: [Manga]
    
    init(id: UUID, firstName: String, lastName: String, role: AuthorRole) {
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
        role: .storyAndArt
    )
    
    @MainActor static let masashiKishimoto = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440012")!,
        firstName: "Masashi",
        lastName: "Kishimoto",
        role: .storyAndArt
    )
    
    @MainActor static let tsugumiOhba = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440022")!,
        firstName: "Tsugumi",
        lastName: "Ohba",
        role: .story
    )
    
    @MainActor static let takeshiObata = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440023")!,
        firstName: "Takeshi",
        lastName: "Obata",
        role: .art
    )
    
    @MainActor static let test = [eiichiroOda, masashiKishimoto, tsugumiOhba, takeshiObata]
}

/// Modelo de Tema para persistencia con SwiftData.
///
/// Representa un tema narrativo o temática del manga (ej. "Adventure", "Fantasy", "School Life").
///
/// ## Características:
/// - UUID único con restricción de unicidad
/// - Índice en el campo `theme` para optimizar búsquedas
/// - Relación muchos-a-muchos con Manga
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

/// Modelo de Género para persistencia con SwiftData.
///
/// Representa un género del manga (ej. "Action", "Romance", "Horror").
///
/// ## Características:
/// - UUID único con restricción de unicidad
/// - Índice en el campo `genre` para optimizar búsquedas
/// - Relación muchos-a-muchos con Manga
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

/// Modelo de Demografía para persistencia con SwiftData.
///
/// Representa la demografía objetivo del manga (ej. "Shounen", "Seinen", "Shoujo").
///
/// ## Características:
/// - UUID único con restricción de unicidad
/// - Índice en el campo `demographic` para optimizar búsquedas
/// - Relación muchos-a-muchos con Manga
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


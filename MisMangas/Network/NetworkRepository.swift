//
//  NetworkRepository.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 9/12/25.
//

import Foundation
import NetworkAPI

/// Repositorio de red que implementa todas las operaciones de comunicación con la API de mangas.
/// Implementa NetworkInteractor para acceder a las funciones genéricas de peticiones HTTP.
struct NetworkRepository: NetworkInteractor {
    
    /// Obtiene la lista completa de autores disponibles en la API.
    /// - Returns: Array de AuthorDTO con la información de todos los autores
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getAuthors() async throws -> [AuthorDTO] {
        try await getJSON(.get(url: .getAuthors), type: [AuthorDTO].self)
    }
    
    /// Obtiene la lista de los mejores mangas según la clasificación de la API.
    /// - Returns: Array de MangaDTO con los mangas mejor valorados o destacados
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getBestMangas() async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getBestMangas), type: [MangaDTO].self)
    }
    
    /// Obtiene todos los mangas creados por un autor específico.
    /// - Parameter id: Identificador único del autor
    /// - Returns: Array de MangaDTO con todos los mangas del autor especificado
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getMangaByAuthor(id: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByAuthor(id: id)), type: [MangaDTO].self)
    }
    
    /// Obtiene todos los mangas que pertenecen a un tema específico.
    /// - Parameter theme: El tema por el cual filtrar los mangas
    /// - Returns: Array de MangaDTO con todos los mangas del tema especificado
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getMangaByTheme(theme: Theme) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByTheme(theme: theme)), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista completa de demografías disponibles en la API.
    /// - Returns: Array de DemographicDTO con todas las categorías demográficas
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getDemographics() async throws -> [DemographicDTO] {
        try await getJSON(.get(url: .getDemographics), type: [DemographicDTO].self)
    }
    
    /// Obtiene todos los mangas dirigidos a una demografía específica.
    /// - Parameter demographic: La categoría demográfica por la cual filtrar (ej: Shonen, Seinen, etc.)
    /// - Returns: Array de MangaDTO con todos los mangas de la demografía especificada
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getMangaByDemographic(demographic: Demographic) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByDemographic(demographic: demographic)), type: [MangaDTO].self)
    }
    
    /// Obtiene todos los mangas que pertenecen a un género específico.
    /// - Parameter genre: El género por el cual filtrar los mangas
    /// - Returns: Array de MangaDTO con todos los mangas del género especificado
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getMangaByGenre(genre: Genre) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByGenre(genre: genre)), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista completa de géneros disponibles en la API.
    /// - Returns: Array de GenreDTO con todos los géneros de manga disponibles
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getGenres() async throws -> [GenreDTO] {
        try await getJSON(.get(url: .getGenres), type: [GenreDTO].self)
    }
    
    /// Obtiene la lista completa de todos los mangas disponibles en la API.
    /// - Returns: Array de MangaDTO con todos los mangas del catálogo
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getMangas() async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getMangas), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista completa de temas disponibles en la API.
    /// - Returns: Array de ThemeDTO con todos los temas de manga disponibles
    /// - Throws: NetworkError si falla la petición o la decodificación
    func getThemes() async throws -> [ThemeDTO] {
        try await getJSON(.get(url: .getThemes), type: [ThemeDTO].self)
    }
}

struct RepositoryTest: NetworkInteractor {
    func getMangas() async throws -> [Manga] {
        [.test]
    }
    
    func getManga(id: Int) async throws -> Manga {
        .test
    }
}

//
//  NetworkRepository.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 9/12/25.
//

import Foundation
import NetworkAPI

/// Repositorio que implementa las operaciones de red con la API de mangas.
struct NetworkRepository: NetworkInteractor {
    
    /// Obtiene la lista de autores.
    func getAuthors() async throws -> [AuthorDTO] {
        try await getJSON(.get(url: .getAuthors), type: [AuthorDTO].self)
    }
    
    /// Obtiene los mejores mangas.
    func getBestMangas() async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getBestMangas), type: [MangaDTO].self)
    }
    
    /// Obtiene los mangas de un autor específico.
    func getMangaByAuthor(id: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByAuthor(id: id)), type: [MangaDTO].self)
    }
    
    /// Obtiene los mangas de un tema específico.
    func getMangaByTheme(theme: Theme) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByTheme(theme: theme)), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista de demografías.
    func getDemographics() async throws -> [DemographicDTO] {
        try await getJSON(.get(url: .getDemographics), type: [DemographicDTO].self)
    }
    
    /// Obtiene los mangas de una demografía específica.
    func getMangaByDemographic(demographic: Demographic) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByDemographic(demographic: demographic)), type: [MangaDTO].self)
    }
    
    /// Obtiene los mangas de un género específico.
    func getMangaByGenre(genre: Genre) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangaByGenre(genre: genre)), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista de géneros.
    func getGenres() async throws -> [GenreDTO] {
        try await getJSON(.get(url: .getGenres), type: [GenreDTO].self)
    }
    
    /// Obtiene la lista completa de mangas.
    func getMangas() async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getMangas), type: [MangaDTO].self)
    }
    
    /// Obtiene la lista de mangas de una página.
    func getMangasPage(page: Int) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getMangas(page: page)), type: Items.self).items
    }
    
    /// Obtiene la lista de temas.
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

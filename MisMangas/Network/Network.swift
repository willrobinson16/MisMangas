//
//  NetworkRepository.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 9/12/25.
//

import Foundation
import NetworkAPI

/// Repositorio que implementa las operaciones de red con la API de mangas.

protocol NetworkRepository: Sendable, NetworkInteractor {
    func getAuthors() async throws -> [AuthorDTO]
    func getBestMangas() async throws -> MangaPageDTO
    func getMangaByAuthor(id: String) async throws -> [MangaDTO]
    func getMangaByTheme(theme: Theme) async throws -> [MangaDTO]
    func getDemographics() async throws -> [DemographicDTO]
    func getMangaByDemographic(demographic: Demographic) async throws -> [MangaDTO]
    func getMangaByGenre(genre: Genre) async throws -> [MangaDTO]
    func getGenres() async throws -> [GenreDTO]
    func getMangas() async throws -> MangaPageDTO
    func getMangasPage(page: Int, itemsPerPage: Int) async throws -> MangaPageDTO
    func getThemes() async throws -> [ThemeDTO]
    func searchMangasBeginsWith(_ title: String) async throws -> [MangaDTO]
    func searchMangasContains(_ title: String) async throws -> [MangaDTO]
    func getManga(id: Int) async throws -> MangaDTO
    func searchAuthor(_ name: String) async throws -> AuthorDTO
    func customSearch(_ search: CustomSearch) async throws -> [MangaDTO]
}
struct Network: NetworkRepository {
    
    // MARK: - List Endpoints
    
    /// Obtiene la lista de autores.
    func getAuthors() async throws -> [AuthorDTO] {
        try await getJSON(.get(url: .getAuthors), type: [AuthorDTO].self)
    }
    
    /// Obtiene los mejores mangas.
    func getBestMangas() async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getBestMangas), type: MangaPageDTO.self)
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
    func getMangas() async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangas), type: MangaPageDTO.self)
    }
    
    /// Obtiene la lista de mangas de una página específica.
    func getMangasPage(page: Int, itemsPerPage: Int = 10) async throws -> MangaPageDTO {
        try await getJSON(.get(url: .getMangas(page: page, itemsPerPage: itemsPerPage)), type: MangaPageDTO.self)
    }
    
    /// Obtiene la lista de temas.
    func getThemes() async throws -> [ThemeDTO] {
        try await getJSON(.get(url: .getThemes), type: [ThemeDTO].self)
    }
    
    // MARK: - Search Endpoints
    
    /// Busca mangas cuyo título comienza con el texto especificado.
    func searchMangasBeginsWith(_ title: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangasBeginsWith(title)), type: [MangaDTO].self)
    }
    
    /// Busca mangas cuyo título contiene el texto especificado.
    func searchMangasContains(_ title: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangasContains(title)), type: [MangaDTO].self)
    }
    
    /// Obtiene un manga específico por su ID.
    func getManga(id: Int) async throws -> MangaDTO {
        try await getJSON(.get(url: .manga(id: id)), type: MangaDTO.self)
    }
    
    /// Busca un autor por su nombre.
    func searchAuthor(_ name: String) async throws -> AuthorDTO {
        try await getJSON(.get(url: .author(name)), type: AuthorDTO.self)
    }
    
    /// Realiza una búsqueda personalizada de mangas con múltiples criterios.
    func customSearch(_ search: CustomSearch) async throws -> [MangaDTO] {
        let body = try JSONEncoder().encode(search)
        return try await getJSON(.post(url: .customSearch, body: body), type: [MangaDTO].self)
    }
    
//    // MARK: - Authentication Endpoints (opcional, si las necesitas)
//    
//    /// Registra un nuevo usuario.
//    /// - Parameter userData: Los datos del usuario a registrar.
//    func register(userData: Data) async throws {
//        var request = URLRequest.post(url: .register)
//        request.httpBody = userData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        try await postJSON(request, status: 201)
//    }
//    
//    /// Inicia sesión con las credenciales del usuario.
//    /// - Parameter credentials: Las credenciales de acceso.
//    /// - Returns: El token de autenticación u otra respuesta del servidor.
//    func login<T: Codable>(credentials: Data) async throws -> T {
//        var request = URLRequest.post(url: .login)
//        request.httpBody = credentials
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        return try await getJSON(request, type: T.self)
//    }
//    
//    /// Renueva el token de autenticación.
//    /// - Parameter token: El token actual a renovar.
//    /// - Returns: El nuevo token de autenticación.
//    func renewToken<T: Codable>(token: String) async throws -> T {
//        var request = URLRequest.post(url: .renewToken)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        return try await getJSON(request, type: T.self)
//    }
}

// MARK: - Test Repository

struct RepositoryTest: NetworkInteractor {
    func getMangas() async throws -> [Manga] {
        [.test]
    }
    
    func getManga(id: Int) async throws -> Manga {
        .test
    }
}

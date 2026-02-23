//
//  NetworkRepository.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 9/12/25.
//

import Foundation
import NetworkAPI

/// Repositorio que implementa las operaciones de red con la API de mangas.
///
/// Proporciona métodos para todas las operaciones disponibles en la API REST,
/// incluyendo listados, búsquedas, filtrados y autenticación.
///
/// ## Características principales:
/// - Integración completa con la API de mangas
/// - Métodos tipados con `async/await`
/// - Manejo de errores con `NetworkError`
/// - Soporte para paginación
/// - Búsquedas por título (begins with / contains)
/// - Filtrado por autor, tema, género y demografía
///
/// ## Uso típico:
/// ```swift
/// let network = Network()
/// let mangas = try await network.getBestMangas()
/// ```
struct Network: NetworkInteractor {
    
    // MARK: - List Endpoints

    /// Obtiene la lista completa de autores desde la API
    /// - Returns: Array de autores disponibles
    /// - Throws: `NetworkError` si falla la petición
    func getAuthors() async throws -> [AuthorDTO] {
        try await getJSON(.get(url: .getAuthors), type: [AuthorDTO].self)
    }

    /// Obtiene la lista de los mejores mangas (mejor puntuados)
    /// - Returns: Array de mangas ordenados por score descendente
    /// - Throws: `NetworkError` si falla la petición
    func getBestMangas() async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getBestMangas), type: [MangaDTO].self)
    }

    /// Obtiene todos los mangas de un autor específico
    /// - Parameter id: ID del autor (UUID en formato String)
    /// - Returns: Array de mangas del autor
    /// - Throws: `NetworkError` si falla la petición
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

    /// Obtiene una página específica de mangas con paginación
    /// - Parameters:
    ///   - page: Número de página (comienza en 1)
    ///   - itemsPerPage: Cantidad de items por página (por defecto 10)
    /// - Returns: Array de mangas de la página solicitada
    /// - Throws: `NetworkError` si falla la petición
    func getMangasPage(page: Int, itemsPerPage: Int = 10) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .getMangas(page: page, itemsPerPage: itemsPerPage)), type: Items.self).items
    }
    
    /// Obtiene la lista de temas.
    func getThemes() async throws -> [ThemeDTO] {
        try await getJSON(.get(url: .getThemes), type: [ThemeDTO].self)
    }
    
    // MARK: - Search Endpoints

    /// Busca mangas cuyo título comienza con el texto especificado (case-insensitive)
    /// - Parameter title: Texto de búsqueda (debe comenzar con este texto)
    /// - Returns: Array de mangas que coinciden con el criterio
    /// - Throws: `NetworkError` si falla la petición
    func searchMangasBeginsWith(_ title: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangasBeginsWith(title)), type: [MangaDTO].self)
    }

    /// Busca mangas cuyo título contiene el texto especificado (case-insensitive)
    /// - Parameter title: Texto de búsqueda (puede aparecer en cualquier parte del título)
    /// - Returns: Array de mangas que coinciden con el criterio
    /// - Throws: `NetworkError` si falla la petición
    func searchMangasContains(_ title: String) async throws -> [MangaDTO] {
        try await getJSON(.get(url: .mangasContains(title)), type: [MangaDTO].self)
    }

    /// Obtiene la información completa de un manga específico por su ID
    /// - Parameter id: ID del manga
    /// - Returns: Datos completos del manga
    /// - Throws: `NetworkError` si falla la petición o el manga no existe
    func getManga(id: Int) async throws -> MangaDTO {
        try await getJSON(.get(url: .manga(id: id)), type: MangaDTO.self)
    }
    
    /// Busca un autor por su nombre.
    func searchAuthor(_ name: String) async throws -> AuthorDTO {
        try await getJSON(.get(url: .author(name)), type: AuthorDTO.self)
    }

    /// Realiza una búsqueda personalizada de mangas con múltiples criterios
    ///
    /// Permite combinar filtros por género, tema, autor, demografía, etc.
    ///
    /// - Parameter search: Objeto con los criterios de búsqueda
    /// - Returns: Array de mangas que cumplen todos los criterios
    /// - Throws: `NetworkError` si falla la petición
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

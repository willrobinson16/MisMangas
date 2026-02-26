//
//  DataContainer.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 30/12/25.
//

import SwiftUI
import SwiftData
import NetworkAPI

/// Actor de datos para gestión de carga y persistencia de mangas desde la API.
///
/// `DataContainer` es un `@ModelActor` que proporciona acceso seguro al `ModelContext`
/// en un contexto de concurrencia. Se encarga de cargar datos desde la red y persistirlos
/// en SwiftData, gestionando paginación y evitando duplicados.
///
/// ## Características principales:
/// - Aislamiento de actor para operaciones concurrentes seguras
/// - Paginación automática con persistencia del número de página
/// - Integración con NetworkRepository para obtener datos de la API
/// - Gestión de autores y mangas con detección de duplicados
///
/// ## Uso típico:
/// ```swift
/// let container = DataContainer(modelContainer: context.container)
/// try await container.loadInitialData()
/// try await container.loadNextPage()
/// ```
@ModelActor
actor DataContainer {
    private let network = Network()

    /// Número de página actual para paginación de mangas (persistido en UserDefaults)
    @AppStorage("page") private var actualPage = 1

    /// Número de página actual para paginación de bestMangas (persistido en UserDefaults)
    @AppStorage("bestMangasPage") private var bestMangasPage = 1

    /// Número de página actual para paginación de autores (persistido en UserDefaults)
    @AppStorage("authorsPage") private var authorsPage = 1

    /// Carga los datos iniciales: mangas y bestMangas de la primera página
    /// Los autores se cargarán paginados cuando el usuario entre al tab de Autores
    /// - Throws: `NetworkError` si falla la petición a la API o errores de persistencia de SwiftData
    func loadInitialData() async throws {
        async let getMangas = network.getMangasPage(page: actualPage)

        let mangas = try await getMangas
        try loadMangas(mangas: mangas.items)

        // Cargar bestMangas en paralelo (no bloquea la carga inicial)
        try await loadBestMangasInitial()
    }

    /// Obtiene los mejores mangas desde la API
    /// - Returns: Página con los mangas mejor puntuados
    /// - Throws: `NetworkError` si falla la petición
    func getBestMangas() async throws -> MangaPageDTO {
        try await network.getBestMangas()
    }

    /// Persiste una lista de mangas en SwiftData usando funciones globales de persistencia
    /// - Parameter mangas: Array de DTOs de manga a persistir
    /// - Throws: Errores de SwiftData si falla la persistencia
    func loadMangas(mangas: [MangaDTO]) throws {
        // Usar la función global para insertar/actualizar mangas
        try insertOrUpdateMangas(in: modelContext, from: mangas)
    }

    /// Persiste autores en SwiftData, evitando duplicados
    /// - Parameter authors: Array de DTOs de autor a persistir
    /// - Throws: Errores de SwiftData si falla la persistencia
    func loadAuthors(authors: [AuthorDTO]) throws {
        // Obtener autores existentes
        let existingAuthors = try modelContext.fetch(FetchDescriptor<Author>())
        let existingIDs = Set(existingAuthors.map(\.id))
        
        // Insertar solo los nuevos
        for author in authors where !existingIDs.contains(author.id) {
            let newAuthor = Author(id: author.id, firstName: author.firstName, lastName: author.lastName, role: author.role)
            modelContext.insert(newAuthor)
        }
        
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    /// Carga la siguiente página de mangas en la paginación
    ///
    /// Incrementa el contador de página, obtiene los mangas de esa página y los persiste.
    /// Si la página está vacía, asume que no hay más datos y revierte el contador.
    /// En caso de error, también revierte el contador para permitir reintentos.
    ///
    /// - Throws: `NetworkError` si falla la petición o errores de persistencia
    func loadNextPage() async throws {
        actualPage += 1

        do {
            let mangas = try await network.getMangasPage(page: actualPage)

            // Si no devuelve mangas, es que no hay más
            if mangas.items.isEmpty {
                actualPage -= 1  // Volver a la página anterior
                return
            }

            try loadMangas(mangas: mangas.items)
        } catch {
            actualPage -= 1  // Volver a la página anterior
            throw error
        }
    }

    /// Carga la primera página de bestMangas y la persiste en SwiftData
    /// - Throws: `NetworkError` si falla la petición o errores de persistencia
    func loadBestMangasInitial() async throws {
        do {
            let bestMangas = try await network.getBestMangasPage(page: bestMangasPage)

            if bestMangas.items.isEmpty {
                return
            }

            try loadMangas(mangas: bestMangas.items)
        } catch {
            throw error
        }
    }

    /// Carga la siguiente página de bestMangas en la paginación
    ///
    /// Incrementa el contador de página, obtiene los bestMangas de esa página y los persiste.
    /// Si la página está vacía, asume que no hay más datos y revierte el contador.
    ///
    /// - Throws: `NetworkError` si falla la petición o errores de persistencia
    func loadBestMangasNextPage() async throws {
        bestMangasPage += 1

        do {
            let bestMangas = try await network.getBestMangasPage(page: bestMangasPage)

            // Si no devuelve mangas, es que no hay más
            if bestMangas.items.isEmpty {
                bestMangasPage -= 1  // Volver a la página anterior
                return
            }

            try loadMangas(mangas: bestMangas.items)
        } catch {
            bestMangasPage -= 1  // Volver a la página anterior
            throw error
        }
    }

    /// Carga la siguiente página de autores en la paginación
    ///
    /// Incrementa el contador de página, obtiene los autores de esa página y los persiste.
    /// Si la página está vacía, asume que no hay más datos y revierte el contador.
    ///
    /// - Throws: `NetworkError` si falla la petición o errores de persistencia
    func loadAuthorsNextPage() async throws {
        authorsPage += 1

        do {
            let authors = try await network.getAuthorsPage(page: authorsPage)

            // Si no devuelve autores, es que no hay más
            if authors.items.isEmpty {
                authorsPage -= 1  // Volver a la página anterior
                return
            }

            try loadAuthors(authors: authors.items)
        } catch {
            authorsPage -= 1  // Volver a la página anterior
            throw error
        }
    }

    /// Resetea el contador de página de autores a 0 para recargar desde el inicio
    ///
    /// NO elimina autores existentes (ya que tienen relaciones con mangas).
    /// Solo reinicia el contador de paginación.
    func resetAuthorsPage() {
        authorsPage = 0
    }
}

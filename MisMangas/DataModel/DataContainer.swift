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

    /// Carga los datos iniciales: mangas, autores y bestMangas de la primera página
    /// - Throws: `NetworkError` si falla la petición a la API o errores de persistencia de SwiftData
    func loadInitialData() async throws {
        async let getMangasAuthors = getMangasAndAuthors()

        let (mangas, authors) = try await getMangasAuthors
        try loadAuthors(authors: authors)
        try loadMangas(mangas: mangas.items)

        // Cargar bestMangas en paralelo (no bloquea la carga inicial)
        try await loadBestMangasInitial()
    }

    /// Obtiene mangas y autores de manera concurrente usando async let
    /// - Returns: Tupla con la página de mangas y la lista de autores
    /// - Throws: `NetworkError` si falla alguna de las peticiones
    func getMangasAndAuthors() async throws -> (MangaPageDTO, [AuthorDTO]) {
        async let getAuthors = network.getAuthors()
        async let getMangas = network.getMangasPage(page: actualPage)
        return try await (getMangas, getAuthors)
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
                print("ℹ️ No hay más mangas en la página \(actualPage)")
                actualPage -= 1  // Volver a la página anterior
                return
            }

            try loadMangas(mangas: mangas.items)
            print("✅ Cargada página \(actualPage) con \(mangas.items.count) mangas")
        } catch {
            print("❌ Error cargando página \(actualPage): \(error)")
            actualPage -= 1  // Volver a la página anterior
            throw error
        }
    }

    /// Carga la primera página de bestMangas y la persiste en SwiftData
    /// - Throws: `NetworkError` si falla la petición o errores de persistencia
    func loadBestMangasInitial() async throws {
        do {
            print("🏆 Cargando bestMangas página \(bestMangasPage)...")
            let bestMangas = try await network.getBestMangasPage(page: bestMangasPage)

            if bestMangas.items.isEmpty {
                print("⚠️ No se recibieron bestMangas")
                return
            }

            try loadMangas(mangas: bestMangas.items)
            print("✅ Cargados \(bestMangas.items.count) bestMangas (página \(bestMangasPage))")
        } catch {
            print("❌ Error cargando bestMangas: \(error)")
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
                print("ℹ️ No hay más bestMangas en la página \(bestMangasPage)")
                bestMangasPage -= 1  // Volver a la página anterior
                return
            }

            try loadMangas(mangas: bestMangas.items)
            print("✅ Cargada página \(bestMangasPage) de bestMangas con \(bestMangas.items.count) mangas")
        } catch {
            print("❌ Error cargando página \(bestMangasPage) de bestMangas: \(error)")
            bestMangasPage -= 1  // Volver a la página anterior
            throw error
        }
    }
}

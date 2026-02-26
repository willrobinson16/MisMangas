//
//  AuthorDetailViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import Foundation

/// ViewModel para gestionar la vista de detalle de un autor.
///
/// Carga y gestiona los mangas en los que ha trabajado un autor específico,
/// con soporte para paginación.
///
/// ## Características:
/// - Aislado a `@MainActor` para actualizaciones seguras de UI
/// - Gestión de paginación de mangas del autor
/// - Estados de carga y error
/// - Mantiene los mangas en memoria (no persiste en SwiftData)
/// - Límite máximo de 100 mangas para optimizar memoria
///
/// ## Uso en SwiftUI:
/// ```swift
/// @State private var viewModel = AuthorDetailViewModel()
///
/// .task {
///     await viewModel.loadMangasByAuthor(authorID: author.id)
/// }
/// ```
@Observable @MainActor
final class AuthorDetailViewModel {
    private let network = Network()

    /// Lista de mangas del autor actual
    var mangas: [MangaDTO] = []

    /// Indica si se está realizando una carga actualmente
    var isLoading = false

    /// Mensaje de error en caso de que falle la carga
    var errorMessage: String?

    /// ID del autor actual
    private var currentAuthorID: String?

    /// Página actual de mangas del autor
    private var currentPage = 1

    /// Flag para saber si hay más páginas disponibles
    private var hasMorePages = true

    /// Límite máximo de mangas en memoria para evitar saturación
    private let maxMangasInMemory = 100

    // MARK: - Cache System

    /// Caché de mangas por autor: [AuthorID: [MangaDTO]]
    /// Evita llamadas de red repetidas para el mismo autor
    private static var mangasCache: [String: [MangaDTO]] = [:]

    /// Caché de páginas cargadas por autor: [AuthorID: Int]
    private static var pageCache: [String: Int] = [:]

    /// Caché de flags hasMore por autor: [AuthorID: Bool]
    private static var hasMoreCache: [String: Bool] = [:]

    /// Cambia a un nuevo autor, usando caché si está disponible
    ///
    /// Este método NO destruye la vista, solo actualiza los datos.
    /// Usa caché para evitar llamadas de red innecesarias.
    ///
    /// - Parameter authorID: UUID del nuevo autor
    func switchToAuthor(_ authorID: UUID) async {
        let authorIDString = authorID.uuidString

        // Si ya estamos viendo este autor, no hacer nada
        guard currentAuthorID != authorIDString else { return }

        // IMPORTANTE: Limpiar mangas del autor anterior inmediatamente
        mangas = []
        currentAuthorID = authorIDString

        // PASO 1: Verificar si hay datos en caché
        if let cachedMangas = Self.mangasCache[authorIDString] {
            // ✅ DATOS EN CACHÉ: cargar inmediatamente sin red
            mangas = cachedMangas
            currentPage = Self.pageCache[authorIDString] ?? 1
            hasMorePages = Self.hasMoreCache[authorIDString] ?? true
            return
        }

        // PASO 2: No hay caché, cargar desde red
        await loadMangasByAuthor(authorID: authorID)
    }

    /// Carga los mangas de un autor específico (primera página)
    ///
    /// Reinicia el estado y carga la primera página de mangas del autor.
    ///
    /// - Parameter authorID: UUID del autor
    func loadMangasByAuthor(authorID: UUID) async {
        let authorIDString = authorID.uuidString

        // Reiniciar estado si es un autor diferente
        if currentAuthorID != authorIDString {
            mangas = []
            currentPage = 1
            hasMorePages = true
            currentAuthorID = authorIDString
        }

        guard !isLoading, hasMorePages else { return }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await network.getMangaByAuthorPage(
                id: authorIDString,
                page: currentPage,
                per: 10
            )

            if result.items.isEmpty {
                hasMorePages = false
            } else {
                // Filtrar duplicados antes de agregar
                let existingIDs = Set(mangas.map { $0.id })
                let newMangas = result.items.filter { !existingIDs.contains($0.id) }

                mangas.append(contentsOf: newMangas)

                // Guardar en caché
                Self.mangasCache[authorIDString] = mangas
                Self.pageCache[authorIDString] = currentPage
                Self.hasMoreCache[authorIDString] = hasMorePages

                // Limitar mangas en memoria para evitar saturación
                if mangas.count >= maxMangasInMemory {
                    hasMorePages = false
                }

            }
        } catch {
            errorMessage = "No se pudieron cargar los mangas del autor"
        }

        isLoading = false
    }

    /// Carga la siguiente página de mangas del autor
    ///
    /// Incrementa el contador de página y carga más mangas.
    func loadNextPage() async {
        guard let authorID = currentAuthorID, !isLoading, hasMorePages else { return }

        currentPage += 1

        isLoading = true
        errorMessage = nil

        do {
            let result = try await network.getMangaByAuthorPage(
                id: authorID,
                page: currentPage,
                per: 10
            )

            if result.items.isEmpty {
                hasMorePages = false
                currentPage -= 1  // Revertir incremento
            } else {
                // Filtrar duplicados antes de agregar
                let existingIDs = Set(mangas.map { $0.id })
                let newMangas = result.items.filter { !existingIDs.contains($0.id) }

                mangas.append(contentsOf: newMangas)

                // Actualizar caché
                Self.mangasCache[authorID] = mangas
                Self.pageCache[authorID] = currentPage
                Self.hasMoreCache[authorID] = hasMorePages

                // Limitar mangas en memoria para evitar saturación
                if mangas.count >= maxMangasInMemory {
                    hasMorePages = false
                }

            }
        } catch {
            errorMessage = "No se pudo cargar más mangas"
            currentPage -= 1  // Revertir incremento en caso de error
        }

        isLoading = false
    }

    /// Reinicia la carga desde cero
    ///
    /// Resetea completamente el estado y recarga desde la primera página.
    /// Útil para pull-to-refresh.
    func retry() async {
        // Resetear estado completamente
        mangas = []
        currentPage = 1
        hasMorePages = true
        errorMessage = nil

        if let authorID = currentAuthorID, let uuid = UUID(uuidString: authorID) {
            await loadMangasByAuthor(authorID: uuid)
        }
    }
}

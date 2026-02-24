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

    /// Lista de mangas del autor
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

    /// Carga los mangas de un autor específico (primera página)
    ///
    /// Reinicia el estado y carga la primera página de mangas del autor.
    ///
    /// - Parameter authorID: UUID del autor
    func loadMangasByAuthor(authorID: UUID) async {
        // Reiniciar estado si es un autor diferente
        if currentAuthorID != authorID.uuidString {
            mangas = []
            currentPage = 1
            hasMorePages = true
            currentAuthorID = authorID.uuidString
        }

        guard !isLoading, hasMorePages else { return }

        isLoading = true
        errorMessage = nil

        do {
            print("📖 Cargando mangas del autor (página \(currentPage))...")
            let result = try await network.getMangaByAuthorPage(
                id: authorID.uuidString,
                page: currentPage
            )

            if result.items.isEmpty {
                hasMorePages = false
                print("ℹ️ No hay más mangas para este autor")
            } else {
                mangas.append(contentsOf: result.items)

                // Limitar mangas en memoria para evitar saturación
                if mangas.count >= maxMangasInMemory {
                    hasMorePages = false
                    print("⚠️ Límite de \(maxMangasInMemory) mangas alcanzado. No se cargarán más páginas.")
                }

                print("✅ Cargados \(result.items.count) mangas del autor (total: \(mangas.count))")
            }
        } catch {
            errorMessage = "No se pudieron cargar los mangas del autor"
            print("❌ Error loading author mangas: \(error)")
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
            print("📖 Cargando página \(currentPage) de mangas del autor...")
            let result = try await network.getMangaByAuthorPage(
                id: authorID,
                page: currentPage
            )

            if result.items.isEmpty {
                hasMorePages = false
                currentPage -= 1  // Revertir incremento
                print("ℹ️ No hay más mangas para este autor")
            } else {
                mangas.append(contentsOf: result.items)

                // Limitar mangas en memoria para evitar saturación
                if mangas.count >= maxMangasInMemory {
                    hasMorePages = false
                    print("⚠️ Límite de \(maxMangasInMemory) mangas alcanzado. No se cargarán más páginas.")
                }

                print("✅ Cargados \(result.items.count) mangas del autor (página \(currentPage), total: \(mangas.count))")
            }
        } catch {
            errorMessage = "No se pudo cargar más mangas"
            currentPage -= 1  // Revertir incremento en caso de error
            print("❌ Error loading next page of author mangas: \(error)")
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

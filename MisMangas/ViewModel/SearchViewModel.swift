//
//  SearchViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 2/2/26.
//

import Foundation

/// ViewModel para gestionar la búsqueda de mangas en tiempo real.
///
/// Proporciona funcionalidad de búsqueda con debounce automático para evitar
/// peticiones excesivas a la API mientras el usuario escribe.
///
/// ## Características:
/// - Búsqueda en tiempo real con debounce de 500ms
/// - Cancelación automática de búsquedas anteriores
/// - Búsqueda case-insensitive
/// - Requisito mínimo de 3 caracteres para realizar búsqueda
///
/// ## Uso en SwiftUI:
/// ```swift
/// @State private var searchVM = SearchViewModel()
///
/// TextField("Buscar manga...", text: $searchVM.search)
/// ```
@Observable @MainActor
final class SearchViewModel {
    /// Texto de búsqueda ingresado por el usuario
    ///
    /// Cuando cambia, cancela la búsqueda anterior y programa una nueva búsqueda
    /// después de 500ms (debounce) para evitar peticiones innecesarias.
    var search = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task {
                // Espera 0.5 segundos después de que el usuario deje de escribir
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                await searchMangasBeginsWith()
            }
        }
    }
    let network = Network()

    /// Tarea activa de búsqueda (para poder cancelarla)
    private var searchTask: Task<Void, Never>?

    /// Resultados de la búsqueda actual
    var mangaResult: [MangaDTO] = []

    /// Busca mangas cuyo título comienza con el texto ingresado
    ///
    /// Requiere al menos 3 caracteres para realizar la búsqueda.
    /// Si el texto es menor, limpia los resultados.
    func searchMangasBeginsWith() async {
        guard search.count > 2 else {
            mangaResult = []
            return
        }
        do {
            mangaResult = try await network.searchMangasBeginsWith(search.lowercased())
        } catch {
            print(error)
        }
    }

    /// Limpia los resultados de búsqueda
    func clearResults() {
        mangaResult = []
    }}

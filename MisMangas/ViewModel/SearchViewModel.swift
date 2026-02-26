//
//  SearchViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 2/2/26.
//

import Foundation

/// ViewModel para gestionar búsqueda avanzada de mangas con múltiples filtros.
///
/// Proporciona funcionalidad de búsqueda rápida por título y búsqueda avanzada
/// con filtros de autor, géneros, temas y demografía, usando CustomSearch (POST).
///
/// ## Características:
/// - Búsqueda rápida por título con debounce de 500ms
/// - Filtros avanzados opcionales (autor, géneros, temas, demografía)
/// - Toggle entre "comienza con" y "contiene"
/// - Gestión de filtros activos con chips visuales
/// - Cancelación automática de búsquedas anteriores
///
/// ## Uso en SwiftUI:
/// ```swift
/// @State private var searchVM = SearchViewModel()
///
/// TextField("Buscar manga...", text: $searchVM.searchTitle)
/// ```
@Observable @MainActor
final class SearchViewModel {
    let network = Network()

    // MARK: - Search Properties

    /// Texto de búsqueda por título (barra principal)
    var searchTitle: String = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                await performSearch()
            }
        }
    }

    /// Nombre del autor (filtro avanzado)
    var authorFirstName: String = ""

    /// Apellido del autor (filtro avanzado)
    var authorLastName: String = ""

    /// Géneros seleccionados (filtro avanzado)
    var selectedGenres: Set<String> = []

    /// Temas seleccionados (filtro avanzado)
    var selectedThemes: Set<String> = []

    /// Demografías seleccionadas (filtro avanzado)
    var selectedDemographics: Set<String> = []

    /// Toggle: false = "begins with", true = "contains"
    var useContains: Bool = false

    // MARK: - State

    /// Resultados de la búsqueda actual
    var mangaResult: [MangaDTO] = []

    /// Tarea activa de búsqueda (para poder cancelarla)
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed Properties

    /// Indica si hay filtros avanzados activos
    var hasActiveFilters: Bool {
        !authorFirstName.isEmpty ||
        !authorLastName.isEmpty ||
        !selectedGenres.isEmpty ||
        !selectedThemes.isEmpty ||
        !selectedDemographics.isEmpty
    }

    /// Número total de filtros activos (para badge)
    var activeFiltersCount: Int {
        var count = 0
        if !authorFirstName.isEmpty { count += 1 }
        if !authorLastName.isEmpty { count += 1 }
        count += selectedGenres.count
        count += selectedThemes.count
        count += selectedDemographics.count
        return count
    }

    /// Genera lista de chips para mostrar filtros activos
    var activeFilterChips: [String] {
        var chips: [String] = []

        if !authorFirstName.isEmpty {
            chips.append("Autor: \(authorFirstName)")
        }
        if !authorLastName.isEmpty {
            chips.append("Apellido: \(authorLastName)")
        }
        chips.append(contentsOf: selectedGenres.map { "Género: \($0)" })
        chips.append(contentsOf: selectedThemes.map { "Tema: \($0)" })
        chips.append(contentsOf: selectedDemographics.map { "Demografía: \($0)" })

        return chips
    }

    // MARK: - Search Methods

    /// Realiza búsqueda avanzada usando CustomSearch (POST /search/manga)
    func performSearch() async {
        // Si no hay título ni filtros, limpiar resultados
        guard !searchTitle.isEmpty || hasActiveFilters else {
            mangaResult = []
            return
        }

        // Construir objeto CustomSearch
        let searchRequest = CustomSearch(
            searchTitle: searchTitle.isEmpty ? nil : searchTitle.lowercased(),
            searchAuthorFirstName: authorFirstName.isEmpty ? nil : authorFirstName,
            searchAuthorLastName: authorLastName.isEmpty ? nil : authorLastName,
            searchGenres: selectedGenres.isEmpty ? nil : Array(selectedGenres),
            searchThemes: selectedThemes.isEmpty ? nil : Array(selectedThemes),
            searchDemographics: selectedDemographics.isEmpty ? nil : Array(selectedDemographics),
            searchContains: useContains
        )

        do {
            let page = try await network.customSearch(searchRequest, page: 1, per: 20)
            mangaResult = page.items
        } catch {
            // Ignorar cancelaciones (son normales cuando el usuario escribe rápido)
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return
            }

            // Solo loggear errores reales
            mangaResult = []
        }
    }

    /// Elimina un filtro específico a partir del texto del chip
    func removeFilter(_ chipText: String) {
        if chipText.hasPrefix("Autor: ") {
            authorFirstName = ""
        } else if chipText.hasPrefix("Apellido: ") {
            authorLastName = ""
        } else if chipText.hasPrefix("Género: ") {
            let genre = chipText.replacingOccurrences(of: "Género: ", with: "")
            selectedGenres.remove(genre)
        } else if chipText.hasPrefix("Tema: ") {
            let theme = chipText.replacingOccurrences(of: "Tema: ", with: "")
            selectedThemes.remove(theme)
        } else if chipText.hasPrefix("Demografía: ") {
            let demo = chipText.replacingOccurrences(of: "Demografía: ", with: "")
            selectedDemographics.remove(demo)
        }

        // Re-ejecutar búsqueda automáticamente
        Task {
            await performSearch()
        }
    }

    /// Limpia todos los filtros avanzados
    func clearAllFilters() {
        authorFirstName = ""
        authorLastName = ""
        selectedGenres.removeAll()
        selectedThemes.removeAll()
        selectedDemographics.removeAll()

        Task {
            await performSearch()
        }
    }

    /// Limpia resultados de búsqueda
    func clearResults() {
        mangaResult = []
    }
}

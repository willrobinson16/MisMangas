//
//  AuthorsViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import Foundation
import SwiftData

/// ViewModel para gestionar la carga paginada de autores.
///
/// Trabaja en conjunto con SwiftData: los datos se persisten en la base de datos
/// y se leen mediante @Query en las vistas. Este ViewModel solo gestiona la carga
/// de páginas adicionales.
///
/// ## Características:
/// - Aislado a `@MainActor` para actualizaciones seguras de UI
/// - Gestión de paginación mediante DataContainer
/// - Estados de carga y error
/// - Los datos se leen de SwiftData con @Query, no se mantienen en el ViewModel
///
/// ## Uso en SwiftUI:
/// ```swift
/// @Environment(\.modelContext) var context
/// @State private var viewModel = AuthorsViewModel()
/// @Query private var authors: [Author]
///
/// .onAppear {
///     viewModel.setModelContext(context)
/// }
/// ```
@Observable @MainActor
final class AuthorsViewModel {
    private var modelContext: ModelContext?

    /// Indica si se está realizando una carga actualmente
    var isLoading = false

    /// Mensaje de error en caso de que falle la carga
    var errorMessage: String?

    /// Establece el ModelContext para operaciones de persistencia
    /// - Parameter context: El ModelContext de SwiftData a utilizar
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    /// Carga la siguiente página de autores
    ///
    /// Llama a DataContainer para obtener la siguiente página de la API y persistirla
    /// en SwiftData. La vista se actualizará automáticamente mediante @Query.
    func loadNextPage() async {
        guard !isLoading, let context = modelContext else { return }

        isLoading = true
        errorMessage = nil

        do {
            let container = DataContainer(modelContainer: context.container)
            try await container.loadAuthorsNextPage()
            print("✅ Página de autores cargada correctamente")
        } catch {
            errorMessage = "No se pudo cargar más autores"
            print("❌ Error loading next page of authors: \(error)")
        }

        isLoading = false
    }

    /// Reinicia la carga de autores
    ///
    /// Útil para botones de "Reintentar" en caso de error.
    func retry() async {
        await loadNextPage()
    }

    /// Resetea la paginación a 0 y recarga la siguiente página (página 1)
    ///
    /// NO elimina autores existentes, solo reinicia el contador de paginación.
    /// Útil para pull-to-refresh.
    func resetAndReload() async {
        guard let context = modelContext else { return }

        // Resetear contador a 0
        let container = DataContainer(modelContainer: context.container)
        await container.resetAuthorsPage()

        // Cargar siguiente página (será página 1)
        await loadNextPage()
    }
}

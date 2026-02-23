//
//  BestMangasViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 14/2/26.
//

import Foundation
import SwiftData

/// ViewModel para gestionar la carga paginada de los mejores mangas.
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
/// @State private var viewModel = BestMangasViewModel()
/// @Query(sort: \Manga.score, order: .reverse) private var bestMangas: [Manga]
///
/// .onAppear {
///     viewModel.setModelContext(context)
/// }
/// ```
@Observable @MainActor
final class BestMangasViewModel {
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

    /// Carga la siguiente página de bestMangas
    ///
    /// Llama a DataContainer para obtener la siguiente página de la API y persistirla
    /// en SwiftData. La vista se actualizará automáticamente mediante @Query.
    func loadNextPage() async {
        guard !isLoading, let context = modelContext else { return }

        isLoading = true
        errorMessage = nil

        do {
            let container = DataContainer(modelContainer: context.container)
            try await container.loadBestMangasNextPage()
            print("✅ Página de bestMangas cargada correctamente")
        } catch {
            errorMessage = "No se pudo cargar más bestMangas"
            print("❌ Error loading next page of bestMangas: \(error)")
        }

        isLoading = false
    }

    /// Reinicia la carga de los mejores mangas
    ///
    /// Útil para botones de "Reintentar" en caso de error.
    func retry() async {
        await loadNextPage()
    }
}

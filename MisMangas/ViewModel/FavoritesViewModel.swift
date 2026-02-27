//
//  FavoritesViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import Foundation
import SwiftData

/// ViewModel para gestionar los mangas favoritos del usuario.
///
/// Proporciona funciones para añadir, eliminar, verificar y contar mangas favoritos,
/// interactuando directamente con SwiftData.
///
/// ## Características:
/// - Gestión completa de favoritos (CRUD)
/// - Toggle inteligente para añadir/eliminar
/// - Verificación de estado de favorito
/// - Conteo total de favoritos
///
/// ## Uso en SwiftUI:
/// ```swift
/// @Environment(FavoritesViewModel.self) private var favoritesVM
///
/// .onAppear {
///     favoritesVM.setModelContext(context)
/// }
/// ```
@Observable @MainActor
final class FavoritesViewModel {
    private var modelContext: ModelContext?

    /// Establece el ModelContext para operaciones de persistencia
    /// - Parameter context: El ModelContext de SwiftData a utilizar
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    /// Añade un manga a la lista de favoritos
    ///
    /// Verifica que el manga no esté ya en favoritos antes de añadirlo.
    /// Crea un `FavoriteManga` con el ID del manga y lo persiste en SwiftData.
    ///
    /// - Parameter manga: El manga a añadir a favoritos
    func addFavorite(manga: Manga) {
        guard let context = modelContext else { return }
        
        // Insertar favorito de inmediato
//        let favorite = FavoriteManga(id: manga.id)
        
        if isFavorite(manga.id) {
            return
        }
        
        let favorite = FavoriteManga(id: manga.id)
        
        context.insert(favorite)
        try? context.save()
        
    }

    /// Elimina un manga de la lista de favoritos
    /// - Parameter mangaID: ID del manga a eliminar de favoritos
    func removeFavorite(_ mangaID: Int) {
        guard let context = modelContext else { return }
        
        let fetch = FetchDescriptor<FavoriteManga>(predicate: #Predicate { $0.id == mangaID }
        )
        
        if let favorite = try? context.fetch(fetch).first {
            context.delete(favorite)
            try? context.save()
        }
    }

    /// Verifica si un manga está en la lista de favoritos
    /// - Parameter mangaID: ID del manga a verificar
    /// - Returns: `true` si el manga está en favoritos, `false` en caso contrario
    func isFavorite(_ mangaID: Int) -> Bool {
        guard let context = modelContext else { return false }

        let fetch = FetchDescriptor<FavoriteManga>(predicate: #Predicate { $0.id == mangaID })
        
        return (try? context.fetch(fetch).first) != nil
    }

    /// Alterna el estado de favorito de un manga (añade si no está, elimina si está)
    /// - Parameter manga: El manga cuyo estado de favorito se va a alternar
    func toggleFavorite(_ manga: Manga) {
        if isFavorite(manga.id) {
            removeFavorite(manga.id)
        } else {
            addFavorite(manga: manga)
        }
    }

    /// Obtiene el número total de mangas en favoritos
    /// - Returns: Cantidad de mangas favoritos
    func favoritesCount() -> Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<FavoriteManga>()
        return (try? context.fetchCount(fetch)) ?? 0
    }
}

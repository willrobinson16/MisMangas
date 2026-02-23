//
//  FavoriteManga.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import Foundation
import SwiftData

/// Modelo de Manga Favorito para persistencia con SwiftData.
///
/// Representa un manga marcado como favorito por el usuario. Solo almacena el ID del manga
/// y la fecha en que fue agregado, creando una relación ligera con el modelo Manga principal.
///
/// ## Características:
/// - ID único con restricción de unicidad (ID del manga referenciado)
/// - Fecha de agregado automática
/// - Modelo minimalista para optimizar el almacenamiento
///
/// ## Uso:
/// ```swift
/// let favorite = FavoriteManga(id: manga.id)
/// context.insert(favorite)
/// ```
@Model
final class FavoriteManga {
    /// ID del manga favorito (debe coincidir con un Manga existente)
    @Attribute(.unique) var id: Int

    /// Fecha en la que el manga fue agregado a favoritos
    var dataAdded: Date

    /// Inicializa un nuevo manga favorito
    /// - Parameter id: ID del manga a marcar como favorito
    init(id: Int) {
        self.id = id
        self.dataAdded = Date()
    }
}

//
//  MangaPageDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Paginated Manga Response

/// Data Transfer Object para respuestas paginadas de mangas desde la API.
///
/// Contiene metadatos de paginación y la lista de mangas de la página actual.
///
/// ## Estructura:
/// ```json
/// {
///   "metadata": {
///     "page": 1,
///     "itemsPerPage": 10,
///     "totalItems": 150,
///     "totalPages": 15
///   },
///   "items": [...]
/// }
/// ```
struct MangaPageDTO: Codable {
    /// Metadatos de paginación (página actual, total, etc.)
    let metadata: PageMetadataDTO
    /// Lista de mangas de la página actual
    let items: [MangaDTO]
}

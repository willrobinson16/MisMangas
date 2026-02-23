//
//  ThemeDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Theme Response DTO

/// Data Transfer Object para temas narrativos de un manga desde la API.
///
/// Representa temas como "Adventure", "Fantasy", "School Life", etc.
///
/// ## Ejemplo:
/// ```json
/// {
///   "id": "550E8400-E29B-41D4-A716-446655440002",
///   "theme": "Adventure"
/// }
/// ```
struct ThemeDTO: Codable, Identifiable, Hashable {
    /// ID único del tema (UUID)
    let id: UUID
    /// Nombre del tema
    let theme: String
}

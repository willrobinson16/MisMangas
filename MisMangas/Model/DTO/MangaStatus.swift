//
//  MangaStatus.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Manga Status

/// Enumeración que representa el estado de publicación de un manga.
///
/// Los valores raw coinciden con los valores devueltos por la API (snake_case).
///
/// ## Valores posibles:
/// - `discontinued`: Manga discontinuado, no se publicará más
/// - `onHiatus`: Manga en pausa temporal
/// - `currentlyPublishing`: Manga actualmente en publicación
/// - `finished`: Manga finalizado
/// - `none`: Estado desconocido o no especificado
enum MangaStatus: String, Codable {
    case discontinued = "discontinued"
    case onHiatus = "on_hiatus"
    case currentlyPublishing = "currently_publishing"
    case finished = "finished"
    case none = "none"
}

//
//  DemographicDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Demographic Response DTO

/// Data Transfer Object para demografías objetivo de manga desde la API.
///
/// Representa la audiencia objetivo como "Shounen", "Seinen", "Shoujo", etc.
///
/// ## Ejemplo:
/// ```json
/// {
///   "id": "550E8400-E29B-41D4-A716-446655440003",
///   "demographic": "Shounen"
/// }
/// ```
struct DemographicDTO: Codable, Identifiable, Hashable {
    /// ID único de la demografía (UUID)
    let id: UUID
    /// Nombre de la demografía objetivo
    let demographic: String
}

extension DemographicDTO {
    /// Convierte el DTO a un modelo SwiftData `Demographic`
    var toDemographic: Demographic {
        Demographic(id: id, demographic: demographic)
    }
}

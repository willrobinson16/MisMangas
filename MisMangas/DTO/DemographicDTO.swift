//
//  DemographicDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Demographic Response DTO
/// Target demographic
struct DemographicDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let demographic: String
}

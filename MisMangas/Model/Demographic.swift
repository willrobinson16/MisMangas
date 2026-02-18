//
//  Demographic.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import Foundation

/// Demographic model matching DemographicDTO structure
struct Demographic: Codable, Identifiable, Hashable {
    let id: UUID
    let demographic: String
}

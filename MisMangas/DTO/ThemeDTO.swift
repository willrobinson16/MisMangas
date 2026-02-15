//
//  ThemeDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Theme Response DTO
/// Theme or setting
struct ThemeDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let theme: String
}

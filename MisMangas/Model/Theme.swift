//
//  Theme.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import Foundation

/// Theme model matching ThemeDTO structure
struct Theme: Codable, Identifiable, Hashable {
    let id: UUID
    let theme: String
}

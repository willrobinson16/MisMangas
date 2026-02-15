//
//  AuthorRole.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Author Role
enum AuthorRole: String, Codable {
    case art = "art"
    case storyAndArt = "storyAndArt"
    case story = "story"
    case none = "none"
}

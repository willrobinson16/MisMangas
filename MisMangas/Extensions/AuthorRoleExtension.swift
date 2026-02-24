//
//  AuthorRoleExtension.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import SwiftUI

extension AuthorRole {
    /// Icono del sistema según el rol del autor
    var icon: String {
        switch self {
        case .story:
            "text.book.closed"
        case .art:
            "paintbrush"
        case .storyAndArt:
            "pencil.and.outline"
        case .none:
            "person"
        }
    }

    /// Icono filled del sistema según el rol del autor
    var iconFilled: String {
        switch self {
        case .story:
            "text.book.closed.fill"
        case .art:
            "paintbrush.fill"
        case .storyAndArt:
            "pencil.and.outline"
        case .none:
            "person.fill"
        }
    }

    /// Color asociado al rol del autor
    var color: Color {
        switch self {
        case .story:
            .blue
        case .art:
            .orange
        case .storyAndArt:
            .purple
        case .none:
            .gray
        }
    }
}

extension Author {
    /// Nombre completo del autor (firstName + lastName)
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

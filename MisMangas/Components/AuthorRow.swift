//
//  AuthorRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import SwiftUI
import SwiftData

/// Componente de fila para mostrar información de un autor de manga.
///
/// Muestra el nombre completo del autor y su rol principal.
/// Diseñado para ser usado en listas de autores.
struct AuthorRow: View {
    let author: Author

    var body: some View {
        HStack(spacing: 16) {
            // Icono del rol
            Image(systemName: author.role.icon)
                .font(.title2)
                .foregroundStyle(author.role.color)
                .frame(width: 40, height: 40)
                .background(author.role.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                // Nombre del autor
                Text(author.fullName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Rol del autor
                Text(author.role.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Chevron para indicar navegación
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        AuthorRow(author: Author(
            id: UUID(),
            firstName: "Eiichiro",
            lastName: "Oda",
            role: .storyAndArt
        ))

        AuthorRow(author: Author(
            id: UUID(),
            firstName: "Yusuke",
            lastName: "Murata",
            role: .art
        ))

        AuthorRow(author: Author(
            id: UUID(),
            firstName: "ONE",
            lastName: "",
            role: .story
        ))
    }
}

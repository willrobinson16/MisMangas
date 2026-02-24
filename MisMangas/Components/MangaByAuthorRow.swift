//
//  MangaByAuthorRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import SwiftUI

/// Componente de fila para mostrar un manga en la vista de detalle de un autor.
///
/// Muestra el título del manga y el rol específico del autor en ese manga.
struct MangaByAuthorRow: View {
    let manga: MangaDTO
    let authorID: UUID

    /// Busca el rol del autor en este manga específico
    private var authorRoleInManga: AuthorRole? {
        manga.authors.first { $0.id == authorID }?.role
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Título del manga
            Text(manga.title)
                .font(.headline)
                .foregroundStyle(.primary)

            // Rol del autor en este manga
            if let role = authorRoleInManga {
                HStack(spacing: 6) {
                    Image(systemName: role.icon)
                        .font(.caption)
                        .foregroundStyle(role.color)

                    Text(role.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Score del manga
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text(String(format: "%.2f", manga.score))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

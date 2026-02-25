//
//  CollectionEntryRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import SwiftUI
import SwiftData

/// Fila para mostrar una entrada de la colección del usuario
struct CollectionEntryRow: View {
    let entry: UserMangaCollection
    let manga: Manga
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 25) {
            // Imagen del manga
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 60, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                // Título
                Text(manga.title)
                    .font(.headline)
                    .lineLimit(2)

                // Autor
                Text(manga.authorsString)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Estado de colección
                collectionStatusView

                // Progreso de lectura
                if entry.hasStartedReading {
                    readingProgressView
                }
            }

            Spacer()

            // Badges
            VStack(alignment: .trailing, spacing: 4) {
                if entry.completeCollection {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }

                if entry.hasStartedReading {
                    Image(systemName: "book.pages.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                }
            }
        }
        .frame(minHeight: 90) // Asegurar que el row tenga al menos la altura de la imagen
        .padding()
    }

    private var collectionStatusView: some View {
        HStack(spacing: 4) {
            Image(systemName: "books.vertical.fill")
                .font(.caption2)
                .foregroundStyle(.orange)

            Text("\(entry.completeCollection ? (manga.volumes ?? 0) : entry.volumesOwnedCount)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let totalVolumes = manga.volumes {
                Text("/ \(totalVolumes)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                // Barra de progreso
                if let progress = entry.collectionProgress(totalVolumes: totalVolumes) {
                    ProgressView(value: progress)
                        .frame(width: 40)
                        .tint(.orange)
                }
            }
        }
    }

    private var readingProgressView: some View {
        HStack(spacing: 4) {
            Image(systemName: "book.pages")
                .font(.caption2)
                .foregroundStyle(.blue)

            if let currentVolume = entry.readingVolume {
                Text("Vol. \(currentVolume)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let totalVolumes = manga.volumes, totalVolumes > 0 {
                    let progress = min(Double(currentVolume) / Double(totalVolumes), 1.0)
                    ProgressView(value: progress)
                        .frame(width: 40)
                        .tint(.blue)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    CollectionEntryRow(
        entry: .test,
        manga: .test,
        namespace: namespace
    )
}

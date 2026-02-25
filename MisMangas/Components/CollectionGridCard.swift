//
//  CollectionGridCard.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import SwiftUI
import SwiftData

/// Tarjeta de colección para vista grid
struct CollectionGridCard: View {
    let entry: UserMangaCollection
    let manga: Manga
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 4) {
            // Imagen con badge verde encima (como CompleteMangaCard)
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 100, height: 150)
                .overlay(alignment: .topTrailing) {
                    // Mostrar badge si está marcada como completa O tiene todos los volúmenes
                    let hasCompleteCollection = entry.completeCollection || (manga.volumes != nil && entry.volumesOwnedCount == manga.volumes)

                    if hasCompleteCollection {
                        Image(systemName: "checkmark.seal.fill")
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.green)
                            .font(.title3)
                            .shadow(radius: 2)
                            .padding(6)
                    }
                }

            // Título
            Text(manga.title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 100)
                .multilineTextAlignment(.center)

            // Volúmenes
            HStack(spacing: 4) {
                Image(systemName: "books.vertical.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)

                // Verificar si tiene colección completa (marcada O tiene todos los volúmenes)
                let hasCompleteCollection = entry.completeCollection || (manga.volumes != nil && entry.volumesOwnedCount == manga.volumes)

                if hasCompleteCollection {
                    if let totalVolumes = manga.volumes {
                        Text("\(totalVolumes)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("∞")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                } else {
                    Text("\(entry.volumesOwnedCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Barra de progreso
            if let readingVolume = entry.readingVolume,
               readingVolume > 0,
               let totalVolumes = totalVolumesForProgress, totalVolumes > 0 {
                let progress = min(Double(readingVolume) / Double(totalVolumes), 1.0)
                ProgressView(value: progress)
                    .tint(.blue)
                    .frame(width: 100, height: 3)
            }
        }
    }

    /// Total de volúmenes para calcular el progreso de lectura
    private var totalVolumesForProgress: Int? {
        entry.totalVolumesForProgress(mangaTotalVolumes: manga.volumes)
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    CollectionGridCard(
        entry: .test,
        manga: .test,
        namespace: namespace
    )
    .padding()
}

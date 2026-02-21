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
        VStack(spacing: 8) {
            // Imagen del manga con badges
            MainPictureView(picture: manga.mainPictureS, namespace: namespace)
                .frame(width: 150, height: 225)
                .overlay(alignment: .topTrailing) {
                    badges
                }

            // Título
            Text(manga.title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Info de colección
            VStack(spacing: 4) {
                // Volúmenes poseídos
                HStack(spacing: 4) {
                    Image(systemName: "books.vertical.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)

                    Text("\(entry.volumesOwnedCount)")
                        .font(.caption)

                    if let totalVolumes = manga.volumes {
                        Text("/ \(totalVolumes)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Progreso de lectura
                if let readingVolume = entry.readingVolume {
                    HStack(spacing: 4) {
                        Image(systemName: "book.pages")
                            .font(.caption2)
                            .foregroundStyle(.blue)

                        Text("Vol. \(readingVolume)")
                            .font(.caption)
                    }
                }

                // Barra de progreso
                if let totalVolumes = manga.volumes,
                   let progress = entry.collectionProgress(totalVolumes: totalVolumes) {
                    ProgressView(value: progress)
                        .tint(.orange)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var badges: some View {
        VStack(spacing: 4) {
            if entry.completeCollection {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
                    .shadow(radius: 2)
            }

            if entry.hasStartedReading {
                Image(systemName: "book.pages.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
                    .shadow(radius: 2)
            }
        }
        .padding(8)
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

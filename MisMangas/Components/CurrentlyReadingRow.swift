//
//  CurrentlyReadingRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import SwiftUI
import SwiftData

/// Fila para mostrar un manga que se está leyendo actualmente
struct CurrentlyReadingRow: View {
    let entry: UserMangaCollection
    let manga: Manga
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 12) {
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 50, height: 75)

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                if let volume = entry.readingVolume {
                    Text("Vol. \(volume)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }

                if let totalVolumes = manga.volumes,
                   let progress = entry.readingProgress(totalVolumes: totalVolumes) {
                    ProgressView(value: progress)
                        .tint(.blue)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview(traits: .sampleData) {
    CurrentlyReadingRow(
        entry: .test,
        manga: .test
    )
    .padding()
}

//
//  CompleteMangaCard.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import SwiftUI
import SwiftData

/// Tarjeta compacta para mostrar un manga con colección completa
struct CompleteMangaCard: View {
    let manga: Manga
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 4) {
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 100, height: 150)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                        .shadow(radius: 2)
                        .padding(6)
                }

            Text(manga.title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 100)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview(traits: .sampleData) {
    CompleteMangaCard(manga: .test)
        .padding()
}

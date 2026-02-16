//
//  MangaRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI
import SwiftData

struct MangaRow: View {
    @Environment(\.modelContext) var context
    @Environment(FavoritesViewModel.self) private var favoritesVM
    
    @Query private var favoritesMangas: [FavoriteManga]
    
    let manga: Manga
    let namespace: Namespace.ID
    
    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 60, height: 90)
            
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text(manga.title)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    if favoritesIDs.contains(manga.id) {
                        withAnimation {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                if let titleJapanese = manga.titleJapanese {
                    Text(titleJapanese)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(manga.authorsString)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let startDate = manga.startDate {
                    Text(startDate.prefix(4))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.footnote)
                    Text(manga.scoreS)
                        .font(.callout)
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    MangaRow(manga: .test, namespace: namespace)
        .environment(FavoritesViewModel())
}

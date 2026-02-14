//
//  MangaView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI
import SwiftData

struct MangaView: View {
    let manga: Manga
    let namespace: Namespace.ID
    
    @Environment(FavoritesViewModel.self) private var favoritesVM
    @State private var mainPictureVM = MainPictureVM()
    
    @Query private var favoriteMangas: [FavoriteManga]
    
    private var isFavorite: Bool {
        favoriteMangas.contains { $0.id == manga.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                MainPictureView(picture: manga.mainPicture, namespace: namespace, big: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(manga.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(manga.authorsString)
                        .font(.title)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        favoritesVM.toggleFavorite(manga)
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.title)
                            .foregroundStyle(isFavorite ? .yellow : .gray)
                    }
                    
                    if let chapters = manga.chapters {
                        Text("Capítulos: \(chapters)")
                    }
                    
                    if let volumes = manga.volumes {
                        Text("Volúmenes: \(volumes)")
                    }
                    
                    if let background = manga.background {
                        Text(background)
                    }
                    
                    RatingView(rating: manga.score)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            mainPictureVM.getImage(mainPicture: manga.mainPicture)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    MangaView(manga: .test, namespace: namespace)
        .environment(FavoritesViewModel())
        .modelContainer(for: FavoriteManga.self)
}

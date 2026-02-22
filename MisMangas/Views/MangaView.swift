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
    @Environment(UserCollectionViewModel.self) private var collectionVM

    @State private var mainPictureVM = MainPictureVM()
    
    @Query private var favoriteMangas: [FavoriteManga]
    @Query private var userCollection: [UserMangaCollection]
    
    private var isFavorite: Bool {
        favoriteMangas.contains { $0.id == manga.id }
    }
    
    private var isInCollection: Bool {
        userCollection.contains { $0.mangaID == manga.id }
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
                    
                    HStack (spacing: 20){
                        Button {
                            favoritesVM.toggleFavorite(manga)
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title)
                                .foregroundStyle(isFavorite ? .red : .gray)
                        }
                        Button {
                            collectionVM.toggleInCollection(manga)
                        } label: {
                            Image(systemName: isInCollection ? "books.vertical.fill" : "books.vertical")
                                .font(.title)
                                .foregroundStyle(isInCollection ? .blue : .gray)
                        }
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
            print(manga.mainPicture?.absoluteString ?? "")
            print(manga.url?.absoluteString ?? "")
            print(manga.genres)
            print(manga.demographics)
            print(manga.themes)
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

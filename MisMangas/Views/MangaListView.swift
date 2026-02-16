//
//  MangaListView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 13/2/26.
//

import SwiftUI
import SwiftData

struct MangaListView: View {
    @Environment(\.modelContext) var context
    @Environment(FavoritesViewModel.self) private var favoritesVM
    @Environment(UserCollectionViewModel.self) private var collectionVM
    
    @Query private var mangas: [Manga]
    @Query private var favoritesMangas: [FavoriteManga]
    @Query private var userCollection: [UserMangaCollection]
    
    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }
    
    private var collectionIDs: Set<Int> {
        Set(userCollection.map { $0.mangaID })
    }
    
    var mangasSorted: [Manga] {
        mangas.sorted { $0.title < $1.title }
    }
    
    let namespace: Namespace.ID
    
    var body: some View {
        ForEach(mangasSorted) { manga in
            let isFavorite = favoritesIDs.contains(manga.id)
            let isInCollection = collectionIDs.contains(manga.id)
            
            NavigationLink(value: manga) {
                MangaRow(manga: manga, namespace: namespace)
            }
            .swipeActions {
                Button {
                    favoritesVM.toggleFavorite(manga)
                } label: {
                    Label(isFavorite ? "Quitar" : "Añadir",
                          systemImage: isFavorite ? "heart.slash" : "heart.fill")
                }
                .tint(isFavorite ? .secondary : .red)
            }
            .swipeActions(edge: .leading) {
                Button {
                    collectionVM.toggleInCollection(manga)
                } label: {
                    Label(isInCollection ? "Quitar" : "Añadir",
                          systemImage: isInCollection ? "bookmark.slash.fill" : "bookmark.fill")
                }
                .tint(isInCollection ? .secondary : .blue)
            }
            
        }
        if mangasSorted.count > 1 {
            ProgressView()
                .onAppear {
                    let modelContainer = DataContainer(modelContainer: context.container)
                    Task {
                        do {
                            try await modelContainer.loadNextPage()
                        } catch {
                            print(error)
                        }
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    NavigationStack {
        MangaListView(namespace: namespace)
            .environment(FavoritesViewModel())
            .environment(UserCollectionViewModel())
    }
}

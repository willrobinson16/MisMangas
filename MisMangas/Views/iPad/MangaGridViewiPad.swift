//
//  MangaGridViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 26/2/26.
//

import SwiftUI
import SwiftData

struct MangaGridViewiPad: View {
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
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 24) {
            ForEach(mangasSorted) { manga in
                let isFavorite = favoritesIDs.contains(manga.id)
                let isInCollection = collectionIDs.contains(manga.id)

                NavigationLink(value: manga) {
                    MangaRow(manga: manga, namespace: namespace)
                }
                .buttonStyle(.plain)
                .mangaSwipeActions(
                    mangaID: manga.id,
                    manga: manga,
                    isFavorite: isFavorite,
                    isInCollection: isInCollection,
                    favoritesVM: favoritesVM,
                    collectionVM: collectionVM
                )
            }

            if mangasSorted.count > 1 {
                ProgressView()
                    .gridCellColumns(2)
                    .onAppear {
                        let modelContainer = DataContainer(modelContainer: context.container)
                        Task {
                            do {
                                try await modelContainer.loadNextPage()
                            } catch {
                            }
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    NavigationStack {
        MangaGridViewiPad(namespace: namespace)
            .environment(FavoritesViewModel())
            .environment(UserCollectionViewModel())
    }
}

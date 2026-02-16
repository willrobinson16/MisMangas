//
//  SearchView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 2/2/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(FavoritesViewModel.self) private var favoritesVM
    @Environment(UserCollectionViewModel.self) private var collectionVM
    
    @Query private var favoritesMangas: [FavoriteManga]
    @Query private var userCollection: [UserMangaCollection]

    @State private var searchVM = SearchViewModel()
    
    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }
    
    private var collectionIDs: Set<Int> {
        Set(userCollection.map { $0.mangaID })
    }
    
    @Namespace var namespace: Namespace.ID
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchVM.mangaResult.isEmpty {
                    searchView
                } else {
                    List(searchVM.mangaResult) { mangaDTO in
                        let isFavorite = favoritesIDs.contains(mangaDTO.id)
                        let isInCollection = collectionIDs.contains(mangaDTO.id)
                        
                        NavigationLink(value: mangaDTO) {
                            MangaRow(manga: mangaDTO.toManga, namespace: namespace)
                        }
                        .swipeActions {
                            Button {
                                favoritesVM.toggleFavorite(mangaDTO.toManga)
                            } label: {
                                Label(isFavorite ? "Quitar" : "Añadir",
                                      systemImage: isFavorite ? "heart.slash" : "heart.fill")
                            }
                            .tint(isFavorite ? .secondary : .red)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                collectionVM.toggleInCollection(mangaDTO.toManga)
                            } label: {
                                Label(isInCollection ? "Quitar" : "Añadir",
                                      systemImage: isInCollection ? "bookmark.slash.fill" : "bookmark.fill")
                            }
                            .tint(isInCollection ? .secondary : .blue)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: MangaDTO.self) { mangaDTO in
                MangaView(manga: mangaDTO.toManga, namespace: namespace)
            }
            .searchable(text: $searchVM.search, prompt: "Buscar Manga")
            .autocorrectionDisabled()
            .onChange(of: searchVM.search) {
                if searchVM.search.isEmpty {
                    searchVM.clearResults()
                }
                else if searchVM.search.count >= 1 {
                    Task {
                        await searchVM.searchMangasBeginsWith()
                    }
                }
            }
        }
    }
    
    var searchView: some View {
        Group {
            if searchVM.mangaResult.isEmpty {
                if !searchVM.search.isEmpty{
                    ContentUnavailableView("No hay manga", systemImage: "books.vertical.fill", description: Text("No se encuentra el manga correspondiente en la base de datos."))
                } else {
                    ContentUnavailableView("Buscar un manga", systemImage: "magnifyingglass.circle", description: Text("Introduce un título para buscar un manga en la base de datos por título."))
                }
            }
        }
    }
}

#Preview {
    SearchView()
}

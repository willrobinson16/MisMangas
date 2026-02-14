//
//  FavoritesView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(FavoritesViewModel.self) private var favoritesVM
    
    @Query private var mangas: [Manga]
    @Query private var favoriteMangas: [FavoriteManga]
    
    @Namespace private var namespace
    
    private var favorites: [Manga] {
        let favoriteIDs = Set(favoriteMangas.map { $0.id })
        return mangas.filter { favoriteIDs.contains($0.id) }
    }
    
    private var favoriteIDs: Set<Int> {
        Set(favoriteMangas.map { $0.id })
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView("Favoritos", systemImage: "star.circle", description: Text("Aún no has añadido mangas a favoritos"))
                } else {
                    List {
                        ForEach(favorites) { manga in
                            NavigationLink(value: manga) {
                                MangaRow(manga: manga, namespace: namespace)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    favoritesVM.removeFavorite(manga.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Favoritos")
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        FavoritesView()
            .environment(FavoritesViewModel())
            .modelContainer(for: FavoriteManga.self)
    }
}

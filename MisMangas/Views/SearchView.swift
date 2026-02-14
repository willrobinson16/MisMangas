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
    
    @Query private var favoritesMangas: [FavoriteManga]
    
    @State private var vm = SearchViewModel()
    
    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }
    
    @Namespace var namespace: Namespace.ID
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.mangaResult.isEmpty {
                    searchView
                } else {
                    List(vm.mangaResult) { mangaDTO in
                        let isFavorite = favoritesIDs.contains(mangaDTO.id)
                        NavigationLink(value: mangaDTO) {
                            MangaRow(manga: mangaDTO.toManga, namespace: namespace)
                        }
                        .swipeActions {
                            Button {
                                favoritesVM.toggleFavorite(mangaDTO.toManga)
                            } label: {
                                Label(isFavorite ? "Quitar" : "Añadir",
                                      systemImage: isFavorite ? "star" : "star.fill")
                            }
                            .tint(isFavorite ? .secondary : .yellow)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: MangaDTO.self) { mangaDTO in
                MangaView(manga: mangaDTO.toManga, namespace: namespace)
            }
            .searchable(text: $vm.search, prompt: "Buscar Manga")
            .autocorrectionDisabled()
            .onChange(of: vm.search) {
                if vm.search.isEmpty {
                    vm.clearResults()
                }
                else if vm.search.count >= 1 {
                    Task {
                        await vm.searchMangasBeginsWith()
                    }
                }
            }
        }
    }
    
    var searchView: some View {
        Group {
            if vm.mangaResult.isEmpty {
                if !vm.search.isEmpty{
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

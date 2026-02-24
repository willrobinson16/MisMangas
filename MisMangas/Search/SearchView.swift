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
    @State private var showAdvancedFilters = false

    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }

    private var collectionIDs: Set<Int> {
        Set(userCollection.map { $0.mangaID })
    }

    @Namespace var namespace: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Chips de filtros activos
                if searchVM.hasActiveFilters {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(searchVM.activeFilterChips, id: \.self) { chip in
                                FilterChip(text: chip) {
                                    searchVM.removeFilter(chip)
                                }
                            }

                            // Botón para limpiar todos los filtros
                            Button {
                                searchVM.clearAllFilters()
                            } label: {
                                Text("Limpiar todo")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }

                // MARK: - Resultados o empty state
                if searchVM.mangaResult.isEmpty {
                    searchView
                } else {
                    List(searchVM.mangaResult) { mangaDTO in
                        let isFavorite = favoritesIDs.contains(mangaDTO.id)
                        let isInCollection = collectionIDs.contains(mangaDTO.id)

                        NavigationLink(value: mangaDTO) {
                            MangaRow(manga: mangaDTO.toManga, namespace: namespace)
                        }
                        .mangaSwipeActions(
                            manga: mangaDTO.toManga,
                            isFavorite: isFavorite,
                            isInCollection: isInCollection,
                            favoritesVM: favoritesVM,
                            collectionVM: collectionVM
                        )
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: MangaDTO.self) { mangaDTO in
                MangaView(manga: mangaDTO.toManga, namespace: namespace)
            }
            .searchable(text: $searchVM.searchTitle, prompt: "Buscar manga...")
            .autocorrectionDisabled()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdvancedFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(searchVM.hasActiveFilters ? .multicolor : .monochrome)
                            .overlay(alignment: .topTrailing) {
                                if searchVM.activeFiltersCount > 0 {
                                    Text("\(searchVM.activeFiltersCount)")
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showAdvancedFilters) {
                AdvancedSearchFiltersSheet(viewModel: searchVM)
            }
        }
    }

    var searchView: some View {
        Group {
            if searchVM.mangaResult.isEmpty {
                if !searchVM.searchTitle.isEmpty || searchVM.hasActiveFilters {
                    ContentUnavailableView(
                        "Sin resultados",
                        systemImage: "magnifyingglass",
                        description: Text("No se encontraron mangas con los criterios especificados.")
                    )
                } else {
                    VStack(spacing: 16) {
                        ContentUnavailableView(
                            "Buscar mangas",
                            systemImage: "books.vertical",
                            description: Text("Usa la barra de búsqueda o los filtros avanzados para encontrar mangas.")
                        )

                        Button {
                            showAdvancedFilters = true
                        } label: {
                            Label("Abrir filtros avanzados", systemImage: "line.3.horizontal.decrease.circle")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environment(FavoritesViewModel())
        .environment(UserCollectionViewModel())
}

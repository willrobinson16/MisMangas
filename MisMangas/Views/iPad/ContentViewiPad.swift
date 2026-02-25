//
//  ContentViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI
import SwiftData

/// Vista principal para iPad con layout de grid adaptativo.
///
/// Aprovecha el espacio de la pantalla grande del iPad mostrando los mangas
/// en una cuadrícula adaptativa en lugar de una lista vertical.
///
/// ## Características:
/// - Grid adaptativo con columnas de mínimo 300pt
/// - Sección de Top Mangas con scroll horizontal
/// - Sección de Todos los Mangas en cuadrícula
/// - Pull-to-refresh, paginación, swipe actions
struct ContentViewiPad: View {
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

    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Section 1: Top Mangas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Mangas")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            BestMangasGridView(namespace: namespace)
                        }
                    }

                    // Section 2: Todos los Mangas (Grid)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Todos los Mangas")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
                            ForEach(mangasSorted) { manga in
                                let isFavorite = favoritesIDs.contains(manga.id)
                                let isInCollection = collectionIDs.contains(manga.id)

                                NavigationLink(value: manga) {
                                    MangaRow(manga: manga, namespace: namespace)
                                }
                                .buttonStyle(.plain)
                                .mangaSwipeActions(
                                    manga: manga,
                                    isFavorite: isFavorite,
                                    isInCollection: isInCollection,
                                    favoritesVM: favoritesVM,
                                    collectionVM: collectionVM
                                )
                            }

                            // Paginación
                            if mangasSorted.count > 1 {
                                ProgressView()
                                    .gridCellColumns(2)
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
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Mis Mangas")
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .onAppear {
                favoritesVM.setModelContext(context)
            }
            .refreshable {
                let modelContainer = DataContainer(modelContainer: context.container)
                Task.detached {
                    do {
                        try await modelContainer.loadInitialData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ContentViewiPad()
        .environment(FavoritesViewModel())
        .environment(UserCollectionViewModel())
        .modelContainer(for: [Manga.self, FavoriteManga.self])
}

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
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            BestMangasGridView(namespace: namespace)
                        }
                    } header: {
                        Text("Top Mangas")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }

                    // Section 2: Todos los Mangas (Grid)
                    Section {
                        MangaGridViewiPad(namespace: namespace)
                    } header: {
                        Text("Todos los Mangas")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
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

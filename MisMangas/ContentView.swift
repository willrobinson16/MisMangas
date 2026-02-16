//
//  ContentView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Environment(FavoritesViewModel.self) private var favoritesVM
    
    @Query private var mangas: [Manga]
    @Query private var favoritesMangas: [FavoriteManga]
    
    private var favoritesIDs: Set<Int> {
        Set(favoritesMangas.map { $0.id })
    }
    
    var mangasSorted: [Manga] {
        mangas.sorted { $0.title < $1.title }
    }
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            Group {
                List {
                    // Section 1: Mejores mangas
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
                    // Section 2: Todos los mangas
                    Section {
                        MangaListView(namespace: namespace)
                    } header: {
                        Text("Todos los Mangas")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                }
                .listStyle(.plain)
            }
            .navigationTitle("Mis Mangas")
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
            .toolbarRole(.editor)
        }
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

#Preview(traits: .sampleData) {
    ContentView()
        .environment(FavoritesViewModel())
        .modelContainer(for: [Manga.self, FavoriteManga.self])
}

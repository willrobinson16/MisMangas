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
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: Grid layout
            ContentViewiPad()
        } else {
            // iPhone: List layout
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        NavigationStack {
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
            .navigationTitle("Mis Mangas")
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .task {
                favoritesVM.setModelContext(context)

                // Cargar datos si la base de datos está vacía
                let descriptor = FetchDescriptor<Manga>()
                if let count = try? context.fetchCount(descriptor), count == 0 {
                    print("📦 Base de datos vacía, cargando datos iniciales...")
                    do {
                        // Cargar mangas directamente desde la API usando el context actual
                        let network = Network()
                        let mangasPage = try await network.getMangasPage(page: 1)
                        let bestMangasPage = try await network.getBestMangasPage(page: 1)

                        // Combinar ambos resultados
                        let allMangas = mangasPage.items + bestMangasPage.items

                        // Guardar en SwiftData usando el context de la vista
                        try insertOrUpdateMangas(in: context, from: allMangas)

                        print("✅ Datos iniciales cargados correctamente (\(allMangas.count) mangas)")
                    } catch {
                        print("❌ Error cargando datos: \(error)")
                    }
                }
            }
            .refreshable {
                let modelContainer = DataContainer(modelContainer: context.container)
                do {
                    try await modelContainer.loadInitialData()
                } catch {
                    print("❌ Error en refresh: \(error)")
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

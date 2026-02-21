//
//  UserCollectionView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import SwiftUI
import SwiftData

/// Vista principal de la colección del usuario
struct UserCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserCollectionViewModel.self) private var collectionVM

    @Query(sort: \UserMangaCollection.lastUpdated, order: .reverse) private var collectionEntries: [UserMangaCollection]
    @Query private var mangas: [Manga]

    @Namespace private var namespace

    @State private var selectedEntryID: UUID?
    @State private var showEditSheet = false
    @State private var viewMode: ViewMode = .list
    @State private var selectedAuthors: Set<String> = []
    @State private var selectedDemographics: Set<String> = []
    @State private var selectedThemes: Set<String> = []
    @State private var selectedGenres: Set<String> = []

    enum ViewMode {
        case list
        case grid
    }

    // Diccionario para acceso rápido a mangas por ID
    private var mangasDict: [Int: Manga] {
        Dictionary(uniqueKeysWithValues: mangas.map { ($0.id, $0) })
    }

    // Entradas filtradas (solo las que tienen manga existente)
    private var filteredEntries: [UserMangaCollection] {
        collectionEntries.filter { entry in
            guard let manga = mangasDict[entry.mangaID] else { return false }

            // Aplicar filtros
            if !selectedAuthors.isEmpty {
                let mangaAuthors = Set(manga.authors.map { "\($0.firstName) \($0.lastName)" })
                if mangaAuthors.isDisjoint(with: selectedAuthors) { return false }
            }

            if !selectedDemographics.isEmpty {
                let mangaDemographics = Set(manga.demographics.map { $0.demographic })
                if mangaDemographics.isDisjoint(with: selectedDemographics) { return false }
            }

            if !selectedThemes.isEmpty {
                let mangaThemes = Set(manga.themes.map { $0.theme })
                if mangaThemes.isDisjoint(with: selectedThemes) { return false }
            }

            if !selectedGenres.isEmpty {
                let mangaGenres = Set(manga.genres.map { $0.genre })
                if mangaGenres.isDisjoint(with: selectedGenres) { return false }
            }

            return true
        }
    }

    // Listas únicas para filtros
    private var allAuthors: [String] {
        let authorSet = Set(mangas.flatMap { $0.authors }.map { "\($0.firstName) \($0.lastName)" })
        return authorSet.sorted()
    }

    private var allDemographics: [String] {
        let demoSet = Set(mangas.flatMap { $0.demographics }.map { $0.demographic })
        return demoSet.sorted()
    }

    private var allThemes: [String] {
        let themeSet = Set(mangas.flatMap { $0.themes }.map { $0.theme })
        return themeSet.sorted()
    }

    private var allGenres: [String] {
        let genreSet = Set(mangas.flatMap { $0.genres }.map { $0.genre })
        return genreSet.sorted()
    }

    // Encuentra la entrada seleccionada del @Query (no una copia)
    private var selectedEntry: UserMangaCollection? {
        guard let id = selectedEntryID else { return nil }
        return collectionEntries.first { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            Group {
                if collectionEntries.isEmpty {
                    ContentUnavailableView(
                        "Colección Vacía",
                        systemImage: "books.vertical",
                        description: Text("Aún no has añadido mangas a tu colección.\nVisita la lista de mangas y añade tus favoritos.")
                    )
                } else {
                    switch viewMode {
                    case .list:
                        collectionListView
                    case .grid:
                        collectionGridView
                    }
                }
            }
            .animation(.default, value: viewMode)
            .navigationTitle("Mi Colección")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        filterMenu
                        viewModeToggle
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let collection = selectedEntry,
                   let manga = mangasDict[collection.mangaID] {
                    EditCollectionSheet(
                        entry: collection,
                        manga: manga,
                        collectionVM: collectionVM
                    )
                }
            }
            .onAppear {
                collectionVM.setModelContext(modelContext)
            }
        }
    }

    // MARK: - List View

    private var collectionListView: some View {
        List {
            ForEach(filteredEntries) { entry in
                if let manga = mangasDict[entry.mangaID] {
                    CollectionEntryRow(
                        entry: entry,
                        manga: manga,
                        namespace: namespace
                    )
                    .onTapGesture {
                        selectedEntryID = entry.id
                        showEditSheet = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            collectionVM.removeFromCollection(entry.mangaID)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        if entry.hasStartedReading {
                            Button {
                                collectionVM.readNextVolume(mangaID: entry.mangaID)
                            } label: {
                                Label("Siguiente", systemImage: "arrow.right.circle")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Grid View

    private var collectionGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredEntries) { entry in
                    if let manga = mangasDict[entry.mangaID] {
                        CollectionGridCard(
                            entry: entry,
                            manga: manga,
                            namespace: namespace
                        )
                        .onTapGesture {
                            selectedEntryID = entry.id
                            showEditSheet = true
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                collectionVM.removeFromCollection(entry.mangaID)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }

                            if entry.hasStartedReading {
                                Button {
                                    collectionVM.readNextVolume(mangaID: entry.mangaID)
                                } label: {
                                    Label("Siguiente volumen", systemImage: "arrow.right.circle")
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - View Mode Toggle

    private var viewModeToggle: some View {
        Button {
            withAnimation {
                viewMode = viewMode == .list ? .grid : .list
            }
        } label: {
            Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
        }
    }

    // MARK: - Filter Menu

    private var filterMenu: some View {
        Menu {
            Menu {
                Button {
                    selectedAuthors.removeAll()
                } label: {
                    Label("Todos", systemImage: selectedAuthors.isEmpty ? "checkmark" : "")
                }

                ForEach(allAuthors, id: \.self) { author in
                    Button {
                        if selectedAuthors.contains(author) {
                            selectedAuthors.remove(author)
                        } else {
                            selectedAuthors.insert(author)
                        }
                    } label: {
                        Label(author, systemImage: selectedAuthors.contains(author) ? "checkmark" : "")
                    }
                }
            } label: {
                Label("Autores", systemImage: "person.2")
            }

            Menu {
                Button {
                    selectedGenres.removeAll()
                } label: {
                    Label("Todos", systemImage: selectedGenres.isEmpty ? "checkmark" : "")
                }

                ForEach(allGenres, id: \.self) { genre in
                    Button {
                        if selectedGenres.contains(genre) {
                            selectedGenres.remove(genre)
                        } else {
                            selectedGenres.insert(genre)
                        }
                    } label: {
                        Label(genre, systemImage: selectedGenres.contains(genre) ? "checkmark" : "")
                    }
                }
            } label: {
                Label("Géneros", systemImage: "theatermasks")
            }

            Menu {
                Button {
                    selectedDemographics.removeAll()
                } label: {
                    Label("Todos", systemImage: selectedDemographics.isEmpty ? "checkmark" : "")
                }

                ForEach(allDemographics, id: \.self) { demographic in
                    Button {
                        if selectedDemographics.contains(demographic) {
                            selectedDemographics.remove(demographic)
                        } else {
                            selectedDemographics.insert(demographic)
                        }
                    } label: {
                        Label(demographic, systemImage: selectedDemographics.contains(demographic) ? "checkmark" : "")
                    }
                }
            } label: {
                Label("Demografía", systemImage: "person.3")
            }

            Menu {
                Button {
                    selectedThemes.removeAll()
                } label: {
                    Label("Todos", systemImage: selectedThemes.isEmpty ? "checkmark" : "")
                }

                ForEach(allThemes, id: \.self) { theme in
                    Button {
                        if selectedThemes.contains(theme) {
                            selectedThemes.remove(theme)
                        } else {
                            selectedThemes.insert(theme)
                        }
                    } label: {
                        Label(theme, systemImage: selectedThemes.contains(theme) ? "checkmark" : "")
                    }
                }
            } label: {
                Label("Temas", systemImage: "tag")
            }

            Divider()

            Button(role: .destructive) {
                selectedAuthors.removeAll()
                selectedGenres.removeAll()
                selectedDemographics.removeAll()
                selectedThemes.removeAll()
            } label: {
                Label("Limpiar filtros", systemImage: "xmark.circle")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

// MARK: - Preview

#Preview("With Data", traits: .sampleData) {
    UserCollectionView()
        .environment(UserCollectionViewModel())
}

#Preview("Empty State") {
    UserCollectionView()
        .modelContainer(for: UserMangaCollection.self, inMemory: true)
        .environment(UserCollectionViewModel())
}

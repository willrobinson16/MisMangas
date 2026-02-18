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

    enum ViewMode {
        case list
        case grid
    }

    // Diccionario para acceso rápido a mangas por ID
    private var mangasDict: [Int: Manga] {
        Dictionary(uniqueKeysWithValues: mangas.map { ($0.id, $0) })
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
            .navigationTitle("Mi Colección")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    viewModeToggle
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
            ForEach(collectionEntries) { entry in
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
                } else {
                    Text("Manga no encontrado")
                        .foregroundStyle(.secondary)
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
                ForEach(collectionEntries) { entry in
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

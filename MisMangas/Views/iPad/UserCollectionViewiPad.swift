//
//  UserCollectionViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 25/2/26.
//

import SwiftUI
import SwiftData

/// Vista de colección optimizada para iPad con diseño enriquecido.
///
/// Aprovecha el espacio del iPad con rows detallados que muestran
/// toda la información relevante del manga y su estado en la colección.
///
/// ## Características:
/// - Rows enriquecidos con imagen, info del manga y progreso
/// - Grid view adaptativo para iPad
/// - Filtros por autor, género, demografía y temas
/// - Toggle entre vista lista y grid
struct UserCollectionViewiPad: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserCollectionViewModel.self) private var collectionVM

    @Query(sort: \UserMangaCollection.lastUpdated, order: .reverse) private var collectionEntries: [UserMangaCollection]

    @Namespace private var namespace

    @State private var selectedEntryID: UUID?
    @State private var showEditSheet = false
    @State private var viewMode: ViewMode = .list
    @State private var selectedAuthors: Set<String> = []
    @State private var selectedDemographics: Set<String> = []
    @State private var selectedThemes: Set<String> = []
    @State private var selectedGenres: Set<String> = []

    // CACHE: Mangas y diccionario cacheados para evitar fetches repetidos
    @State private var cachedMangas: [Manga] = []
    @State private var cachedMangasDict: [Int: Manga] = [:]
    @State private var lastCachedIDs: Set<Int> = []

    // Diccionario para acceso rápido a mangas por ID (usa cache)
    private var mangasDict: [Int: Manga] {
        cachedMangasDict
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

    // Listas únicas para filtros (usa cache para evitar recálculos)
    private var allAuthors: [String] {
        let authorSet = Set(cachedMangas.flatMap { $0.authors }.map { "\($0.firstName) \($0.lastName)" })
        return authorSet.sorted()
    }

    private var allDemographics: [String] {
        let demoSet = Set(cachedMangas.flatMap { $0.demographics }.map { $0.demographic })
        return demoSet.sorted()
    }

    private var allThemes: [String] {
        let themeSet = Set(cachedMangas.flatMap { $0.themes }.map { $0.theme })
        return themeSet.sorted()
    }

    private var allGenres: [String] {
        let genreSet = Set(cachedMangas.flatMap { $0.genres }.map { $0.genre })
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
                        enrichedListView
                    case .grid:
                        collectionGridView
                    }
                }
            }
            .animation(.default, value: viewMode)
            .navigationTitle("Mi Colección")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        filterMenu
                        viewModeToggle
                    }
                }
            }
            .toolbarTitleDisplayMode(.inlineLarge)
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
            .task {
                collectionVM.setModelContext(modelContext)
                updateMangasCache()
            }
            .onChange(of: collectionEntries.map(\.mangaID)) { _, newIDs in
                let newIDSet = Set(newIDs)

                // Solo actualizar cache si los IDs realmente cambiaron
                if newIDSet != lastCachedIDs {
                    updateMangasCache()
                    lastCachedIDs = newIDSet
                }
            }
        }
    }

    // MARK: - Cache Management

    /// Actualiza el cache de mangas desde SwiftData
    /// Solo se ejecuta cuando la colección realmente cambia (añadir/eliminar mangas)
    private func updateMangasCache() {
        let mangaIDs = collectionEntries.map { $0.mangaID }
        let descriptor = FetchDescriptor<Manga>(
            predicate: #Predicate<Manga> { manga in
                mangaIDs.contains(manga.id)
            }
        )

        cachedMangas = (try? modelContext.fetch(descriptor)) ?? []
        cachedMangasDict = Dictionary(uniqueKeysWithValues: cachedMangas.map { ($0.id, $0) })

        print("🔄 Cache actualizado: \(cachedMangas.count) mangas")
    }

    // MARK: - Enriched List View (iPad)

    @ViewBuilder
    private var enrichedListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredEntries) { entry in
                    if let manga = mangasDict[entry.mangaID] {
                        EnrichedCollectionRow(
                            entry: entry,
                            manga: manga,
                            namespace: namespace,
                            onTap: {
                                selectedEntryID = entry.id
                                showEditSheet = true
                            },
                            onDelete: {
                                collectionVM.removeFromCollection(entry.mangaID)
                            },
                            onNextVolume: entry.hasStartedReading ? {
                                collectionVM.readNextVolume(mangaID: entry.mangaID)
                            } : nil
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Grid View

    @ViewBuilder
    private var collectionGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
            ], spacing: 20) {
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
        .background(Color(.systemGroupedBackground))
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
                    if selectedAuthors.isEmpty {
                        Label("Todos", systemImage: "checkmark")
                    } else {
                        Text("Todos")
                    }
                }

                ForEach(allAuthors, id: \.self) { author in
                    Button {
                        if selectedAuthors.contains(author) {
                            selectedAuthors.remove(author)
                        } else {
                            selectedAuthors.insert(author)
                        }
                    } label: {
                        if selectedAuthors.contains(author) {
                            Label(author, systemImage: "checkmark")
                        } else {
                            Text(author)
                        }
                    }
                }
            } label: {
                Label("Autores", systemImage: "person.2")
            }

            Menu {
                Button {
                    selectedGenres.removeAll()
                } label: {
                    if selectedGenres.isEmpty {
                        Label("Todos", systemImage: "checkmark")
                    } else {
                        Text("Todos")
                    }
                }

                ForEach(allGenres, id: \.self) { genre in
                    Button {
                        if selectedGenres.contains(genre) {
                            selectedGenres.remove(genre)
                        } else {
                            selectedGenres.insert(genre)
                        }
                    } label: {
                        if selectedGenres.contains(genre) {
                            Label(genre, systemImage: "checkmark")
                        } else {
                            Text(genre)
                        }
                    }
                }
            } label: {
                Label("Géneros", systemImage: "theatermasks")
            }

            Menu {
                Button {
                    selectedDemographics.removeAll()
                } label: {
                    if selectedDemographics.isEmpty {
                        Label("Todos", systemImage: "checkmark")
                    } else {
                        Text("Todos")
                    }
                }

                ForEach(allDemographics, id: \.self) { demographic in
                    Button {
                        if selectedDemographics.contains(demographic) {
                            selectedDemographics.remove(demographic)
                        } else {
                            selectedDemographics.insert(demographic)
                        }
                    } label: {
                        if selectedDemographics.contains(demographic) {
                            Label(demographic, systemImage: "checkmark")
                        } else {
                            Text(demographic)
                        }
                    }
                }
            } label: {
                Label("Demografía", systemImage: "person.3")
            }

            Menu {
                Button {
                    selectedThemes.removeAll()
                } label: {
                    if selectedThemes.isEmpty {
                        Label("Todos", systemImage: "checkmark")
                    } else {
                        Text("Todos")
                    }
                }

                ForEach(allThemes, id: \.self) { theme in
                    Button {
                        if selectedThemes.contains(theme) {
                            selectedThemes.remove(theme)
                        } else {
                            selectedThemes.insert(theme)
                        }
                    } label: {
                        if selectedThemes.contains(theme) {
                            Label(theme, systemImage: "checkmark")
                        } else {
                            Text(theme)
                        }
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

// MARK: - Enriched Collection Row for iPad

/// Row enriquecido para la colección en iPad con toda la información del manga
private struct EnrichedCollectionRow: View {
    let entry: UserMangaCollection
    let manga: Manga
    let namespace: Namespace.ID
    let onTap: () -> Void
    let onDelete: () -> Void
    let onNextVolume: (() -> Void)?

    var body: some View {
        HStack(spacing: 20) {
            // Imagen del manga
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 90, height: 135)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)

            // Información del manga
            VStack(alignment: .leading, spacing: 8) {
                // Título
                Text(manga.title)
                    .font(.title3.bold())
                    .lineLimit(2)

                // Título en japonés (si existe)
                if let japaneseTitle = manga.titleJapanese, !japaneseTitle.isEmpty {
                    Text(japaneseTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Autor(es)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(manga.authorsString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Año y valoración
                HStack(spacing: 12) {
                    if let year = manga.startYear {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text("\(year)")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if manga.mean > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", manga.mean))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // Estado de colección y progreso
                HStack(spacing: 16) {
                    // Volúmenes poseídos
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "books.vertical.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(entry.completeCollection ? (manga.volumes ?? 0) : entry.volumesOwnedCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let totalVolumes = manga.volumes {
                                Text("/ \(totalVolumes)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        // Barra de progreso de colección
                        if let totalVolumes = manga.volumes,
                           let progress = entry.collectionProgress(totalVolumes: totalVolumes) {
                            HStack(spacing: 6) {
                                ProgressView(value: progress)
                                    .tint(.orange)
                                    .frame(width: 100)

                                Text("\(Int(progress * 100))%")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Progreso de lectura
                    if entry.hasStartedReading {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "book.pages")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)

                                if let currentVolume = entry.readingVolume {
                                    Text("Vol. \(currentVolume)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            // Barra de progreso de lectura
                            if let totalVolumes = manga.volumes,
                               let progress = entry.readingProgress(totalVolumes: totalVolumes) {
                                HStack(spacing: 6) {
                                    ProgressView(value: progress)
                                        .tint(.blue)
                                        .frame(width: 100)

                                    Text("\(Int(progress * 100))%")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()

            // Badges
            VStack(alignment: .trailing, spacing: 8) {
                if entry.completeCollection {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }

                if entry.hasStartedReading {
                    Image(systemName: "book.pages.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
            }
        }
        .frame(minHeight: 135)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar", systemImage: "trash")
            }

            if let onNextVolume {
                Button(action: onNextVolume) {
                    Label("Siguiente volumen", systemImage: "arrow.right.circle")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("With Data", traits: .sampleData) {
    UserCollectionViewiPad()
        .environment(UserCollectionViewModel())
}

#Preview("Empty State") {
    UserCollectionViewiPad()
        .modelContainer(for: UserMangaCollection.self, inMemory: true)
        .environment(UserCollectionViewModel())
}

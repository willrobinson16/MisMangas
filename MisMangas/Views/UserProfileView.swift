//
//  UserProfileView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import SwiftUI
import SwiftData

/// Vista de perfil del usuario con estadísticas y progreso
struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserCollectionViewModel.self) private var collectionVM
    @Environment(FavoritesViewModel.self) private var favoritesVM

    @Query private var mangas: [Manga]
    @Query private var favoriteManga: [FavoriteManga]
    @Query private var userCollection: [UserMangaCollection]
    
    @Namespace private var namespace

    @State private var userName: String = "Usuario"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Sección de perfil
                    profileSection

                    // Estadísticas de colección
                    collectionStatsSection

                    // Estadísticas de favoritos
                    favoritesStatsSection

                    // Mangas en progreso
                    currentlyReadingSection

                    // Colecciones completas
                    completeCollectionsSection
                }
                .padding()
            }
            .navigationTitle("Mi Perfil")
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .onAppear {
            collectionVM.setModelContext(modelContext)
            favoritesVM.setModelContext(modelContext)
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text(userName)
                .font(.title2.bold())

            Text("Usuario desde 2026")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Collection Stats

    private var collectionStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mi Colección")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Mangas",
                    value: "\(collectionVM.collectionCount)",
                    icon: "books.vertical.fill",
                    color: .orange
                )

                StatCard(
                    title: "Volúmenes",
                    value: "\(collectionVM.totalVolumesOwned)",
                    icon: "book.closed.fill",
                    color: .blue
                )

                StatCard(
                    title: "Completos",
                    value: "\(collectionVM.completeCollectionsCount)",
                    icon: "checkmark.seal.fill",
                    color: .green
                )

                StatCard(
                    title: "Leyendo",
                    value: "\(collectionVM.currentlyReadingCount)",
                    icon: "book.pages.fill",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Favorites Stats

    private var favoritesStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favoritos")
                .font(.headline)

            StatCard(
                title: "Favoritos",
                value: "\(favoritesVM.favoritesCount())",
                icon: "heart.fill",
                color: .red
            )
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Currently Reading

    private var currentlyReadingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Leyendo Actualmente")
                    .font(.headline)
                Spacer()
                if currentlyReadingEntries.count > 3 {
                    NavigationLink {
                        currentlyReadingFullList
                    } label: {
                        Text("Ver todos")
                            .font(.caption)
                    }
                }
            }

            if currentlyReadingEntries.isEmpty {
                Text("No estás leyendo ningún manga")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(currentlyReadingEntries.prefix(3)) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        CurrentlyReadingRow(entry: entry, manga: manga)
                    }
                }
            }
        }
    }

    // MARK: - Complete Collections

    private var completeCollectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Colecciones Completas")
                    .font(.headline)
                Spacer()
                if completeCollectionEntries.count > 5 {
                    NavigationLink {
                        completeCollectionsFullList
                    } label: {
                        Text("Ver todos")
                            .font(.caption)
                    }
                }
            }

            if completeCollectionEntries.isEmpty {
                Text("Aún no has completado ninguna colección")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(150))], spacing: 12) {
                        ForEach(completeCollectionEntries.prefix(5)) { entry in
                            if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                                NavigationLink(value: manga) {
                                    CompleteMangaCard(manga: manga)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    // MARK: - Full Lists

    private var currentlyReadingFullList: some View {
        List {
            ForEach(currentlyReadingEntries) { entry in
                if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                    CurrentlyReadingRow(entry: entry, manga: manga)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Leyendo Actualmente")
    }

    private var completeCollectionsFullList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 16)
            ], spacing: 20) {
                ForEach(completeCollectionEntries) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        NavigationLink(value: manga) {
                            CompleteMangaCard(manga: manga)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Colecciones Completas")
    }

    // MARK: - Computed Properties

    private var currentlyReadingEntries: [UserMangaCollection] {
        userCollection.filter { $0.readingVolume != nil }
            .sorted { $0.lastUpdated > $1.lastUpdated }
    }

    private var completeCollectionEntries: [UserMangaCollection] {
        userCollection.filter { $0.completeCollection }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
}

#Preview("With Data", traits: .sampleData) {
    UserProfileView()
        .environment(UserCollectionViewModel())
        .environment(FavoritesViewModel())
}

#Preview("Empty State") {
    UserProfileView()
        .modelContainer(for: [UserMangaCollection.self, FavoriteManga.self, Manga.self], inMemory: true)
        .environment(UserCollectionViewModel())
        .environment(FavoritesViewModel())
}

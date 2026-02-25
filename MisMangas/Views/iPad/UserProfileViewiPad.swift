//
//  UserProfileViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI
import SwiftData

/// Vista de perfil optimizada para iPad con diseño enriquecido.
///
/// Aprovecha el espacio del iPad con cards visuales, previews de mangas
/// y diseño dinámico con información detallada.
///
/// ## Características:
/// - Cards de estadísticas enriquecidas con previews
/// - Layout fluido con diferentes tamaños de componentes
/// - Información visual con portadas de mangas
/// - Mejor jerarquía y uso de espacios
struct UserProfileViewiPad: View {
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
                    // HEADER: Perfil prominente
                    enhancedProfileSection

                    // GRID DE ESTADÍSTICAS ENRIQUECIDAS
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        // Card: Mangas en Colección (con previews)
                        mangasCollectionCard

                        // Card: Leyendo Actualmente (con previews)
                        currentlyReadingCard

                        // Card: Colecciones Completas (con previews)
                        completeCollectionsCard

                        // Card: Favoritos (con previews)
                        favoritesCard
                    }

                    // SECCIÓN DETALLADA: Actividad Reciente
                    recentActivitySection
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
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

    // MARK: - Enhanced Profile Section

    private var enhancedProfileSection: some View {
        HStack(spacing: 24) {
            // Avatar grande
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)

            VStack(alignment: .leading, spacing: 8) {
                Text(userName)
                    .font(.system(size: 32, weight: .bold))

                Text("Usuario desde 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Mini stats rápidas
                HStack(spacing: 16) {
                    QuickStat(
                        value: "\(collectionVM.collectionCount)",
                        label: "Mangas",
                        color: .orange
                    )
                    QuickStat(
                        value: "\(collectionVM.totalVolumesOwned)",
                        label: "Volúmenes",
                        color: .blue
                    )
                    QuickStat(
                        value: "\(favoritesVM.favoritesCount())",
                        label: "Favoritos",
                        color: .red
                    )
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Enhanced Stat Cards

    private var mangasCollectionCard: some View {
        EnhancedStatCard(
            title: "Mi Colección",
            value: "\(collectionVM.collectionCount)",
            subtitle: "\(collectionVM.totalVolumesOwned) volúmenes totales",
            icon: "books.vertical.fill",
            color: .orange
        ) {
            // Preview de 3 mangas recientes de la colección
            HStack(spacing: 8) {
                ForEach(userCollection.prefix(3)) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        NavigationLink(value: manga) {
                            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                                .frame(width: 50, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(radius: 2)
                        }
                    }
                }

                if userCollection.count > 3 {
                    Text("+\(userCollection.count - 3)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 75)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private var currentlyReadingCard: some View {
        EnhancedStatCard(
            title: "Leyendo Ahora",
            value: "\(collectionVM.currentlyReadingCount)",
            subtitle: "en progreso",
            icon: "book.pages.fill",
            color: .blue
        ) {
            // Preview de mangas que estás leyendo
            HStack(spacing: 8) {
                ForEach(currentlyReadingEntries.prefix(3)) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        NavigationLink(value: manga) {
                            ZStack(alignment: .bottom) {
                                MainPictureView(picture: manga.mainPicture, namespace: namespace)
                                    .frame(width: 50, height: 75)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                // Badge con volumen actual
                                if let vol = entry.readingVolume {
                                    Text("Vol.\(vol)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                        .padding(3)
                                }
                            }
                            .shadow(radius: 2)
                        }
                    }
                }

                if currentlyReadingEntries.count > 3 {
                    Text("+\(currentlyReadingEntries.count - 3)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 75)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private var completeCollectionsCard: some View {
        EnhancedStatCard(
            title: "Completas",
            value: "\(collectionVM.completeCollectionsCount)",
            subtitle: "colecciones finalizadas",
            icon: "checkmark.seal.fill",
            color: .green
        ) {
            // Preview de colecciones completas
            HStack(spacing: 8) {
                ForEach(completeCollectionEntries.prefix(3)) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        NavigationLink(value: manga) {
                            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                                .frame(width: 50, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green, .white)
                                        .font(.caption)
                                        .shadow(radius: 1)
                                        .offset(x: 3, y: -3)
                                }
                                .shadow(radius: 2)
                        }
                    }
                }

                if completeCollectionEntries.count > 3 {
                    Text("+\(completeCollectionEntries.count - 3)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 75)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    private var favoritesCard: some View {
        let favoriteIDs = Set(favoriteManga.map { $0.id })
        let favoriteMangas = mangas.filter { favoriteIDs.contains($0.id) }

        return EnhancedStatCard(
            title: "Favoritos",
            value: "\(favoritesVM.favoritesCount())",
            subtitle: "mangas destacados",
            icon: "heart.fill",
            color: .red
        ) {
            // Preview de favoritos
            HStack(spacing: 8) {
                ForEach(favoriteMangas.prefix(3)) { manga in
                    NavigationLink(value: manga) {
                        MainPictureView(picture: manga.mainPicture, namespace: namespace)
                            .frame(width: 50, height: 75)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                    .shadow(radius: 1)
                                    .offset(x: 3, y: -3)
                            }
                            .shadow(radius: 2)
                    }
                }

                if favoriteMangas.count > 3 {
                    Text("+\(favoriteMangas.count - 3)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 75)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actividad Reciente")
                .font(.title2.bold())

            // Tabs para alternar entre "Leyendo" y "Completas"
            if !currentlyReadingEntries.isEmpty || !completeCollectionEntries.isEmpty {
                VStack(spacing: 16) {
                    // Leyendo Actualmente
                    if !currentlyReadingEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Leyendo Actualmente", systemImage: "book.pages.fill")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                Spacer()
                                if currentlyReadingEntries.count > 4 {
                                    NavigationLink {
                                        currentlyReadingFullList
                                    } label: {
                                        Text("Ver todos (\(currentlyReadingEntries.count))")
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)
                            ], spacing: 20) {
                                ForEach(currentlyReadingEntries.prefix(6)) { entry in
                                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                                        NavigationLink(value: manga) {
                                            ReadingMangaCard(entry: entry, manga: manga, namespace: namespace)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                    }

                    // Colecciones Completas
                    if !completeCollectionEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Colecciones Completas", systemImage: "checkmark.seal.fill")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                Spacer()
                                if completeCollectionEntries.count > 8 {
                                    NavigationLink {
                                        completeCollectionsFullList
                                    } label: {
                                        Text("Ver todos (\(completeCollectionEntries.count))")
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
                            ], spacing: 20) {
                                ForEach(completeCollectionEntries.prefix(8)) { entry in
                                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                                        NavigationLink(value: manga) {
                                            CompleteMangaCard(manga: manga)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                    }
                }
            } else {
                ContentUnavailableView(
                    "Sin actividad reciente",
                    systemImage: "book.closed",
                    description: Text("Comienza a añadir mangas a tu colección")
                )
                .frame(height: 200)
            }
        }
    }

    // MARK: - Full Lists

    private var currentlyReadingFullList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)
            ], spacing: 20) {
                ForEach(currentlyReadingEntries) { entry in
                    if let manga = mangas.first(where: { $0.id == entry.mangaID }) {
                        NavigationLink(value: manga) {
                            ReadingMangaCard(entry: entry, manga: manga, namespace: namespace)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Leyendo Actualmente")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var completeCollectionsFullList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120, maximum: 180), spacing: 16)
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
        .navigationTitle("Colecciones Completadas")
        .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Auxiliary Components

/// Mini estadística para el header del perfil
private struct QuickStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

/// Card de estadística enriquecido con preview de contenido
private struct EnhancedStatCard<Content: View>: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    @ViewBuilder let preview: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header del card
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold))

                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }

                Spacer()
            }

            // Subtitle
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            // Preview de contenido
            preview
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

/// Card para mostrar mangas en progreso (vista grid)
private struct ReadingMangaCard: View {
    let entry: UserMangaCollection
    let manga: Manga
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 8) {
            // Imagen del manga
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 3)

            // Título
            Text(manga.title)
                .font(.caption.bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 30)

            // Volumen actual
            if let volume = entry.readingVolume {
                Text("Vol. \(volume)")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }

            // Barra de progreso
            if let totalVolumes = manga.volumes,
               let progress = entry.readingProgress(totalVolumes: totalVolumes) {
                ProgressView(value: progress)
                    .tint(.blue)
                    .frame(width: 100)
            }
        }
        .padding(12)
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

/// Row enriquecido para "Leyendo Actualmente" en iPad con toda la información
private struct EnrichedReadingRow: View {
    let entry: UserMangaCollection
    let manga: Manga
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 16) {
            // Imagen del manga
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)

            // Información del manga
            VStack(alignment: .leading, spacing: 6) {
                // Título
                Text(manga.title)
                    .font(.headline)
                    .lineLimit(2)

                // Título en japonés (si existe)
                if let japaneseTitle = manga.titleJapanese, !japaneseTitle.isEmpty {
                    Text(japaneseTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Autor(es)
                Text(manga.authorsString)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Año y valoración
                HStack(spacing: 8) {
                    if let year = manga.startYear {
                        Text("\(year)")
                            .font(.caption)
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

                // Volumen y progreso de lectura
                VStack(alignment: .leading, spacing: 4) {
                    if let volume = entry.readingVolume {
                        HStack(spacing: 4) {
                            Image(systemName: "book.pages")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                            Text("Vol. \(volume)")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }

                    // Barra de progreso
                    if let totalVolumes = manga.volumes,
                       let progress = entry.readingProgress(totalVolumes: totalVolumes) {
                        HStack(spacing: 6) {
                            ProgressView(value: progress)
                                .tint(.blue)
                                .frame(maxWidth: 150)

                            Text("\(Int(progress * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

// MARK: - Previews

#Preview("With Data", traits: .sampleData) {
    UserProfileViewiPad()
        .environment(UserCollectionViewModel())
        .environment(FavoritesViewModel())
}

#Preview("Empty State") {
    UserProfileViewiPad()
        .modelContainer(for: [UserMangaCollection.self, FavoriteManga.self, Manga.self], inMemory: true)
        .environment(UserCollectionViewModel())
        .environment(FavoritesViewModel())
}

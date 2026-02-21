//
//  UserCollectionViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation
import SwiftData

// NOTA: Existen DOS tipos llamados "Manga":
// 1. struct Manga en /Model/Manga.swift (DTO para red)
// 2. @Model class Manga en /DataModel/Model.swift (SwiftData)
// El parámetro de addToCollection recibe el struct DTO
// FetchDescriptor usa automáticamente la clase SwiftData

/// ViewModel for managing the user's manga collection
/// Tracks ownership, reading progress, and volume possession
@Observable @MainActor
final class UserCollectionViewModel {
    private var modelContext: ModelContext?

    /// Sets the model context for data persistence
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    // MARK: - Collection Management

    /// Adds a manga to the user's collection
    /// - Parameters:
    ///   - manga: The manga struct (DTO) to add
    ///   - volumes: Optional array of volume numbers already owned
    func addToCollection(manga: Manga, volumes: [Int] = []) {
        guard let context = modelContext else { return }

        // Check if already in collection
        if isInCollection(manga.id) {
            return
        }

        // Crear o encontrar el Manga SwiftData
        ensureMangaExists(manga, in: context)

        // Crear entrada de colección
        let collection = UserMangaCollection(
            mangaID: manga.id,
            volumesOwned: volumes
        )

        context.insert(collection)
        try? context.save()
    }

    /// Asegura que el Manga SwiftData existe en la base de datos
    private func ensureMangaExists(_ mangaDTO: Manga, in context: ModelContext) {
        // Verificar si ya existe usando FetchDescriptor (que usa la clase @Model automáticamente)
        let descriptor = FetchDescriptor<Manga>(
            predicate: #Predicate { $0.id == mangaDTO.id }
        )

        // Si ya existe, no hacer nada
        if (try? context.fetch(descriptor).first) != nil {
            return
        }

        // Crear entidades relacionadas
        let themesSD = mangaDTO.themes.map { Theme(id: $0.id, theme: $0.theme) }
        let authorsSD = mangaDTO.authors.map { Author(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, role: $0.role) }
        let genresSD = mangaDTO.genres.map { Genre(id: $0.id, genre: $0.genre) }
        let demographicsSD = mangaDTO.demographics.map { Demographic(id: $0.id, demographic: $0.demographic) }

        // Crear Manga SwiftData (la clase, no el struct)
        let mangaSD = Manga(
            id: mangaDTO.id,
            status: mangaDTO.status.rawValue,
            background: mangaDTO.background,
            title: mangaDTO.title,
            titleEnglish: mangaDTO.titleEnglish,
            titleJapanese: mangaDTO.titleJapanese,
            score: mangaDTO.score,
            chapters: mangaDTO.chapters,
            startDate: mangaDTO.startDate,
            endDate: mangaDTO.endDate,
            mainPicture: mangaDTO.mainPictureURL,
            synopsis: mangaDTO.synopsis,
            url: mangaDTO.urlCleaned,
            volumes: mangaDTO.volumes,
            themes: themesSD,
            authors: authorsSD,
            genres: genresSD,
            demographics: demographicsSD
        )

        context.insert(mangaSD)
    }

    /// Removes a manga from the user's collection
    /// - Parameter mangaID: The ID of the manga to remove
    func removeFromCollection(_ mangaID: Int) {
        guard let context = modelContext else { return }

        let fetch = FetchDescriptor<UserMangaCollection>(predicate: #Predicate { $0.mangaID == mangaID }
        )

        if let collection = try? context.fetch(fetch).first {
            context.delete(collection)
            try? context.save()
        }
    }

    /// Checks if a manga is in the user's collection
    /// - Parameter mangaID: The ID of the manga to check
    /// - Returns: True if the manga is in the collection
    func isInCollection(_ mangaID: Int) -> Bool {
        guard let context = modelContext else { return false }

        let fetch = FetchDescriptor<UserMangaCollection>(
            predicate: #Predicate { $0.mangaID == mangaID }
        )

        return (try? context.fetch(fetch).first) != nil
    }
    
    func toggleInCollection(_ manga: Manga) {
        if isInCollection(manga.id) {
            removeFromCollection(manga.id)
        } else {
            addToCollection(manga: manga)
        }
    }

    /// Gets the collection entry for a specific manga
    /// - Parameter mangaID: The ID of the manga
    /// - Returns: The collection entry if found
    func getCollectionEntry(_ mangaID: Int) -> UserMangaCollection? {
        guard let context = modelContext else { return nil }

        let fetch = FetchDescriptor<UserMangaCollection>(
            predicate: #Predicate { $0.mangaID == mangaID }
        )

        return try? context.fetch(fetch).first
    }

    // MARK: - Reading Progress

    /// Updates the current reading volume
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volume: The volume number being read (nil to clear)
    func updateReadingVolume(mangaID: Int, volume: Int?) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.readingVolume = volume
        collection.lastUpdated = Date()

        try? context.save()
    }

    /// Marks the next volume as being read
    /// - Parameter mangaID: The ID of the manga
    func readNextVolume(mangaID: Int) {
        guard let collection = getCollectionEntry(mangaID) else { return }

        let nextVolume = (collection.readingVolume ?? 0) + 1
        updateReadingVolume(mangaID: mangaID, volume: nextVolume)
    }

    /// Increments the reading volume by 1
    /// - Parameter mangaID: The ID of the manga
    func incrementReadingVolume(mangaID: Int) {
        guard let collection = getCollectionEntry(mangaID) else { return }

        let nextVolume = (collection.readingVolume ?? 0) + 1
        updateReadingVolume(mangaID: mangaID, volume: nextVolume)
    }

    /// Decrements the reading volume by 1
    /// - Parameter mangaID: The ID of the manga
    func decrementReadingVolume(mangaID: Int) {
        guard let collection = getCollectionEntry(mangaID) else { return }

        if let current = collection.readingVolume, current > 0 {
            updateReadingVolume(mangaID: mangaID, volume: current - 1)
        } else {
            updateReadingVolume(mangaID: mangaID, volume: nil)
        }
    }

    /// Gets the current reading volume
    /// - Parameter mangaID: The ID of the manga
    /// - Returns: The current reading volume number, or nil if not reading
    func getCurrentReadingVolume(_ mangaID: Int) -> Int? {
        getCollectionEntry(mangaID)?.readingVolume
    }

    // MARK: - Volume Ownership

    /// Adds a volume to the owned volumes list
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumeNumber: The volume number to add
    func addVolume(mangaID: Int, volumeNumber: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.addVolume(volumeNumber)
        try? context.save()
    }

    /// Removes a volume from the owned volumes list
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumeNumber: The volume number to remove
    func removeVolume(mangaID: Int, volumeNumber: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.removeVolume(volumeNumber)
        try? context.save()
    }

    /// Adds multiple volumes at once
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumes: Array of volume numbers to add
    func addVolumes(mangaID: Int, volumes: [Int]) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.addVolumes(volumes)
        try? context.save()
    }

    /// Checks if a specific volume is owned
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumeNumber: The volume number to check
    /// - Returns: True if the volume is owned
    func ownsVolume(mangaID: Int, volumeNumber: Int) -> Bool {
        getCollectionEntry(mangaID)?.ownsVolume(volumeNumber) ?? false
    }

    /// Gets all owned volumes for a manga
    /// - Parameter mangaID: The ID of the manga
    /// - Returns: Sorted array of owned volume numbers
    func getOwnedVolumes(_ mangaID: Int) -> [Int] {
        getCollectionEntry(mangaID)?.volumesOwned.sorted() ?? []
    }

    // MARK: - Complete Collection

    /// Toggles the complete collection flag
    /// - Parameter mangaID: The ID of the manga
    func toggleCompleteCollection(mangaID: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.completeCollection.toggle()
        collection.lastUpdated = Date()

        try? context.save()
    }

    /// Sets the complete collection flag
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - isComplete: Whether the collection is complete
    func setCompleteCollection(mangaID: Int, isComplete: Bool) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.completeCollection = isComplete
        collection.lastUpdated = Date()

        try? context.save()
    }

    /// Checks if the user has the complete collection
    /// - Parameter mangaID: The ID of the manga
    /// - Returns: True if marked as complete collection
    func hasCompleteCollection(_ mangaID: Int) -> Bool {
        getCollectionEntry(mangaID)?.completeCollection ?? false
    }

    // MARK: - Statistics

    /// Total number of manga in the collection
    var collectionCount: Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<UserMangaCollection>()
        return (try? context.fetchCount(fetch)) ?? 0
    }

    /// Total number of volumes owned across all manga
    var totalVolumesOwned: Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<UserMangaCollection>()
        let collections = (try? context.fetch(fetch)) ?? []

        return collections.reduce(0) { $0 + $1.volumesOwnedCount }
    }

    /// Number of manga with complete collections
    var completeCollectionsCount: Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<UserMangaCollection>(
            predicate: #Predicate { $0.completeCollection == true }
        )

        return (try? context.fetchCount(fetch)) ?? 0
    }

    /// Number of manga currently being read
    var currentlyReadingCount: Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<UserMangaCollection>()
        let collections = (try? context.fetch(fetch)) ?? []

        return collections.filter { $0.readingVolume != nil }.count
    }

    /// Gets reading progress for a manga
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - totalVolumes: Total number of volumes for this manga
    /// - Returns: Reading progress as percentage (0.0 - 1.0), or nil if not applicable
    func readingProgress(mangaID: Int, totalVolumes: Int?) -> Double? {
        getCollectionEntry(mangaID)?.readingProgress(totalVolumes: totalVolumes)
    }

    /// Gets collection completion progress for a manga
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - totalVolumes: Total number of volumes for this manga
    /// - Returns: Collection progress as percentage (0.0 - 1.0), or nil if not applicable
    func collectionProgress(mangaID: Int, totalVolumes: Int?) -> Double? {
        getCollectionEntry(mangaID)?.collectionProgress(totalVolumes: totalVolumes)
    }
}

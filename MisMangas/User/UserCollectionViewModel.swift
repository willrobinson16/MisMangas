//
//  UserCollectionViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation
import SwiftData

// NOTA: Este ViewModel trabaja con IDs de manga, no con objetos completos.
// Esto evita acoplamiento innecesario y permite trabajar con cualquier fuente:
// - @Model Manga desde SwiftData (@Query)
// - MangaDTO desde API
//
// La persistencia en SwiftData se maneja mediante fetch del manga por ID.

/// ViewModel for managing the user's manga collection
/// Tracks ownership, reading progress, and volume possession
@Observable @MainActor
final class UserCollectionViewModel {
    private var modelContext: ModelContext?

    /// Estado de sincronización con el servidor
    var isSyncing: Bool = false

    /// Mensaje de error de sincronización
    var syncError: String?

    /// Indica si hay cambios pendientes de sincronizar
    var hasPendingChanges: Bool = false

    /// Sets the model context for data persistence
    func setModelContext(_ context: ModelContext) {
        modelContext = context

        // Verificar si hay cambios pendientes al inicializar
        Task {
            await checkPendingChanges()
        }
    }

    // MARK: - Synchronization

    /// Sincroniza todos los cambios pendientes con el servidor.
    ///
    /// Este método debe llamarse:
    /// - Al recuperar conexión a internet
    /// - Manualmente por el usuario (botón "Sincronizar")
    /// - Al iniciar sesión
    func syncPendingChanges() async {
        guard let context = modelContext else { return }
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil

        let (success, failed) = await SyncManager.shared.syncPendingChanges(context: context)

        if failed > 0 {
            syncError = "Sincronizados \(success) mangas. \(failed) fallaron."
        }

        // Actualizar estado de cambios pendientes
        await checkPendingChanges()

        isSyncing = false
    }

    /// Realiza una sincronización completa desde el servidor.
    ///
    /// **Importante**: Sobrescribe datos locales con los del servidor.
    /// Solo usar si el servidor es la fuente de verdad.
    func fullSyncFromServer() async {
        guard let context = modelContext else { return }
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil

        do {
            let count = try await SyncManager.shared.fullSyncFromServer(context: context)

            // Actualizar estado de cambios pendientes
            await checkPendingChanges()

        } catch {
            syncError = "Error en sincronización completa: \(error.localizedDescription)"
        }

        isSyncing = false
    }

    /// Verifica si hay cambios pendientes de sincronización.
    func checkPendingChanges() async {
        guard let context = modelContext else {
            hasPendingChanges = false
            return
        }

        hasPendingChanges = SyncManager.shared.hasPendingChanges(context: context)
    }

    // MARK: - Collection Management

    /// Adds a manga to the user's collection
    /// - Parameters:
    ///   - mangaID: The ID of the manga to add
    ///   - volumes: Optional array of volume numbers already owned
    func addToCollection(mangaID: Int, volumes: [Int] = []) {
        guard let context = modelContext else { return }

        // Check if already in collection
        if isInCollection(mangaID) {
            return
        }

        // Verificar que el manga existe en SwiftData
        let fetchManga = FetchDescriptor<Manga>(predicate: #Predicate { $0.id == mangaID })
        guard (try? context.fetch(fetchManga).first) != nil else {
            return
        }

        // Crear entrada de colección
        let collection = UserMangaCollection(
            mangaID: mangaID,
            volumesOwned: volumes
        )

        context.insert(collection)
        try? context.save()

        // Sincronizar con servidor en background
        Task {
            do {
                let repo = Collection()
                let request = collection.toRequest()
                try await repo.addOrUpdateCollection(request)
            } catch {
                // Marcar como pendiente para sincronizar después
                collection.markAsPendingSync(operation: .add)
                try? context.save()
            }
        }
    }

    /// Removes a manga from the user's collection
    /// - Parameter mangaID: The ID of the manga to remove
    func removeFromCollection(_ mangaID: Int) {
        guard let context = modelContext else { return }

        let fetch = FetchDescriptor<UserMangaCollection>(predicate: #Predicate { $0.mangaID == mangaID }
        )

        if let collection = try? context.fetch(fetch).first {
            // Eliminar inmediatamente de SwiftData local
            context.delete(collection)
            try? context.save()

            // Sincronizar eliminación con el servidor en background
            Task {
                do {
                    let repo = Collection()
                    try await repo.deleteCollectionManga(mangaID: mangaID)
                } catch {
                }
            }
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
    
    func toggleInCollection(mangaID: Int) {
        if isInCollection(mangaID) {
            removeFromCollection(mangaID)
        } else {
            addToCollection(mangaID: mangaID)
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

        // Marcar como pendiente de sincronización
        collection.markAsPendingSync(operation: .update)

        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
    }

    /// Marks the next volume as being read
    /// - Parameter mangaID: The ID of the manga
    func readNextVolume(mangaID: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        // Obtener el manga para verificar el total de volúmenes
        let fetchManga = FetchDescriptor<Manga>(predicate: #Predicate { $0.id == mangaID })
        guard let manga = try? context.fetch(fetchManga).first else { return }

        let currentVolume = collection.readingVolume ?? 0
        let nextVolume = currentVolume + 1

        // Calcular el máximo de volúmenes permitido
        let maxVolumes: Int
        if collection.completeCollection {
            // Si tiene colección completa, usar el total del manga
            maxVolumes = manga.volumes ?? Int.max
        } else {
            // Si no, usar el máximo entre volumesOwned y total del manga
            let ownedMax = collection.volumesOwned.max() ?? 0
            maxVolumes = min(ownedMax, manga.volumes ?? Int.max)
        }

        // Solo incrementar si no se ha alcanzado el máximo
        if nextVolume <= maxVolumes {
            updateReadingVolume(mangaID: mangaID, volume: nextVolume)
        } else {
        }
    }

    /// Increments the reading volume by 1
    /// - Parameter mangaID: The ID of the manga
    func incrementReadingVolume(mangaID: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        // Obtener el manga para verificar el total de volúmenes
        let fetchManga = FetchDescriptor<Manga>(predicate: #Predicate { $0.id == mangaID })
        guard let manga = try? context.fetch(fetchManga).first else { return }

        let currentVolume = collection.readingVolume ?? 0
        let nextVolume = currentVolume + 1

        // Calcular el máximo de volúmenes permitido
        let maxVolumes: Int
        if collection.completeCollection {
            // Si tiene colección completa, usar el total del manga
            maxVolumes = manga.volumes ?? Int.max
        } else {
            // Si no, usar el máximo entre volumesOwned y total del manga
            let ownedMax = collection.volumesOwned.max() ?? 0
            maxVolumes = min(ownedMax, manga.volumes ?? Int.max)
        }

        // Solo incrementar si no se ha alcanzado el máximo
        if nextVolume <= maxVolumes {
            updateReadingVolume(mangaID: mangaID, volume: nextVolume)
        } else {
        }
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
        collection.markAsPendingSync(operation: .update)
        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
    }

    /// Removes a volume from the owned volumes list
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumeNumber: The volume number to remove
    func removeVolume(mangaID: Int, volumeNumber: Int) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.removeVolume(volumeNumber)
        collection.markAsPendingSync(operation: .update)
        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
    }

    /// Adds multiple volumes at once
    /// - Parameters:
    ///   - mangaID: The ID of the manga
    ///   - volumes: Array of volume numbers to add
    func addVolumes(mangaID: Int, volumes: [Int]) {
        guard let context = modelContext,
              let collection = getCollectionEntry(mangaID) else { return }

        collection.addVolumes(volumes)
        collection.markAsPendingSync(operation: .update)
        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
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
        collection.markAsPendingSync(operation: .update)

        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
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
        collection.markAsPendingSync(operation: .update)

        try? context.save()

        // Actualizar estado de cambios pendientes
        Task {
            await checkPendingChanges()
        }
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

        // Fetchear todos los mangas de la colección
        let mangaIDs = collections.map { $0.mangaID }
        let mangaFetch = FetchDescriptor<Manga>(
            predicate: #Predicate { manga in
                mangaIDs.contains(manga.id)
            }
        )
        let mangas = (try? context.fetch(mangaFetch)) ?? []
        let mangasDict = Dictionary(uniqueKeysWithValues: mangas.map { ($0.id, $0) })

        // Calcular el total considerando colecciones completas
        return collections.reduce(0) { total, collection in
            if collection.completeCollection {
                // Si la colección está completa, usar el total de volúmenes del manga
                let mangaVolumes = mangasDict[collection.mangaID]?.volumes ?? 0
                return total + mangaVolumes
            } else {
                // Si no está completa, usar el count del array volumesOwned
                return total + collection.volumesOwnedCount
            }
        }
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

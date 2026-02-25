//
//  UserMangaCollection.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation
import SwiftData

/// Represents a user's manga collection entry with ownership and reading progress tracking
@Model
final class UserMangaCollection {
    #Index<UserMangaCollection>([\.mangaID])
    @Attribute(.unique) var id: UUID

    /// Reference to the manga ID
    var mangaID: Int

    /// Current volume being read (nil if not started or between volumes)
    var readingVolume: Int?

    /// Whether the user owns the complete collection
    var completeCollection: Bool

    /// Array of volume numbers that the user owns
    /// Stored as Data to avoid faulting issues with primitive arrays in SwiftData
    private var volumesOwnedData: Data

    /// Date when this entry was added to the collection
    var dateAdded: Date

    /// Date when this entry was last updated
    var lastUpdated: Date

    /// Flag que indica si este registro tiene cambios pendientes de sincronizar con el servidor
    var isPendingSync: Bool

    /// Tipo de operación pendiente de sincronizar (add, update, delete)
    var pendingSyncOperation: String?

    init(
        id: UUID = UUID(),
        mangaID: Int,
        readingVolume: Int? = nil,
        completeCollection: Bool = false,
        volumesOwned: [Int] = [],
        isPendingSync: Bool = false,
        pendingSyncOperation: String? = nil
    ) {
        self.id = id
        self.mangaID = mangaID
        self.readingVolume = readingVolume
        self.completeCollection = completeCollection
        self.volumesOwnedData = (try? JSONEncoder().encode(volumesOwned)) ?? Data()
        self.dateAdded = Date()
        self.lastUpdated = Date()
        self.isPendingSync = isPendingSync
        self.pendingSyncOperation = pendingSyncOperation
    }
}

// MARK: - Computed Properties
extension UserMangaCollection {
    /// Gets the array of owned volumes
    var volumesOwned: [Int] {
        (try? JSONDecoder().decode([Int].self, from: volumesOwnedData)) ?? []
    }
    
    /// Total number of volumes owned
    var volumesOwnedCount: Int {
        volumesOwned.count
    }

    /// Whether the user has started reading this manga
    var hasStartedReading: Bool {
        readingVolume != nil
    }

    /// Reading progress as a percentage (0.0 - 1.0)
    /// Returns nil if total volumes is unknown
    func readingProgress(totalVolumes: Int?) -> Double? {
        guard let total = totalVolumes, total > 0,
              let current = readingVolume else {
            return nil
        }
        return max(0.0, min(1.0, Double(current) / Double(total)))
    }

    /// Collection completion percentage (0.0 - 1.0)
    /// Returns nil if total volumes is unknown
    func collectionProgress(totalVolumes: Int?) -> Double? {
        guard let total = totalVolumes, total > 0 else {
            return nil
        }
        return max(0.0, min(1.0, Double(volumesOwnedCount) / Double(total)))
    }

    /// Total de volúmenes para calcular el progreso de lectura
    /// - Parameter mangaTotalVolumes: Total de volúmenes del manga (opcional)
    /// - Returns: Total de volúmenes considerando si la colección está completa o no
    func totalVolumesForProgress(mangaTotalVolumes: Int?) -> Int? {
        if completeCollection {
            return mangaTotalVolumes
        } else {
            let ownedVolumes = volumesOwned
            if !ownedVolumes.isEmpty {
                return ownedVolumes.max()
            }
            return mangaTotalVolumes
        }
    }

    /// Whether a specific volume is owned
    func ownsVolume(_ volumeNumber: Int) -> Bool {
        volumesOwned.contains(volumeNumber)
    }
}

// MARK: - Volume Management Methods
extension UserMangaCollection {
    /// Adds a volume to the collection
    func addVolume(_ volumeNumber: Int) {
        var volumes = volumesOwned
        if !volumes.contains(volumeNumber) {
            volumes.append(volumeNumber)
            volumes.sort()
            volumesOwnedData = (try? JSONEncoder().encode(volumes)) ?? Data()
            lastUpdated = Date()
        }
    }
    
    /// Removes a volume from the collection
    func removeVolume(_ volumeNumber: Int) {
        var volumes = volumesOwned
        if let index = volumes.firstIndex(of: volumeNumber) {
            volumes.remove(at: index)
            volumesOwnedData = (try? JSONEncoder().encode(volumes)) ?? Data()
            lastUpdated = Date()
        }
    }
    
    /// Adds multiple volumes at once
    func addVolumes(_ newVolumes: [Int]) {
        var volumes = volumesOwned
        let toAdd = Set(newVolumes).subtracting(volumes)
        if !toAdd.isEmpty {
            volumes.append(contentsOf: toAdd)
            volumes.sort()
            volumesOwnedData = (try? JSONEncoder().encode(volumes)) ?? Data()
            lastUpdated = Date()
        }
    }
    
    /// Replaces all volumes with a new array
    func setVolumes(_ newVolumes: [Int]) {
        let sorted = newVolumes.sorted()
        volumesOwnedData = (try? JSONEncoder().encode(sorted)) ?? Data()
        lastUpdated = Date()
    }
    
    /// Clears all volumes
    func clearVolumes() {
        volumesOwnedData = (try? JSONEncoder().encode([Int]())) ?? Data()
        lastUpdated = Date()
    }
}

// MARK: - Sync Management
extension UserMangaCollection {
    /// Marca este registro como pendiente de sincronización con el servidor
    func markAsPendingSync(operation: SyncOperation) {
        self.isPendingSync = true
        self.pendingSyncOperation = operation.rawValue
        self.lastUpdated = Date()
    }

    /// Marca este registro como sincronizado con el servidor
    func markAsSynced() {
        self.isPendingSync = false
        self.pendingSyncOperation = nil
        self.lastUpdated = Date()
    }
}

/// Tipo de operación pendiente de sincronización
enum SyncOperation: String, Codable, Sendable {
    case add = "add"
    case update = "update"
    case delete = "delete"
}

// MARK: - DTO Conversion
extension UserMangaCollection {
    /// Converts to DTO representation (requires manga data)
    func toDTO(manga: MangaDTO) -> UserMangaCollectionDTO {
        UserMangaCollectionDTO(
            id: id,
            readingVolume: readingVolume,
            completeCollection: completeCollection,
            volumesOwned: volumesOwned,
            manga: manga
        )
    }

    /// Converts to Request DTO for server (only manga ID, not full object)
    func toRequest() -> UserMangaCollectionRequest {
        UserMangaCollectionRequest(
            id: id,
            manga: mangaID,  // ← Solo el ID, no el objeto completo
            readingVolume: readingVolume,
            completeCollection: completeCollection,
            volumesOwned: volumesOwned
        )
    }

    /// Creates from DTO
    static func from(_ dto: UserMangaCollectionDTO) -> UserMangaCollection {
        UserMangaCollection(
            id: dto.id,
            mangaID: dto.manga.id,
            readingVolume: dto.readingVolume,
            completeCollection: dto.completeCollection,
            volumesOwned: dto.volumesOwned
        )
    }
}

// MARK: - Test Data
extension UserMangaCollection {
    /// Test collection entry
    @MainActor static let test = UserMangaCollection(
        id: UUID(),
        mangaID: 13,
        readingVolume: 5,
        completeCollection: false,
        volumesOwned: [1, 2, 3, 4, 5],
        isPendingSync: false
    )
}

//
//  SyncManager.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import SwiftData

/// Actor que gestiona la sincronización automática de la colección del usuario
/// entre SwiftData local y el servidor remoto.
///
/// ## Estrategia:
/// - Al recuperar conexión, detecta registros con `isPendingSync = true`
/// - Los envía al servidor en orden (add, update, delete)
/// - Una vez confirmados, marca como sincronizados en SwiftData
/// - Maneja errores parciales (si falla uno, continúa con el resto)
///
/// ## Uso:
/// ```swift
/// let syncManager = SyncManager.shared
/// await syncManager.syncPendingChanges(context: modelContext)
/// ```
actor SyncManager {

    /// Instancia compartida del SyncManager
    static let shared = SyncManager()

    /// Repositorio de colección para operaciones con el servidor
    private let collectionRepo: CollectionRepository = Collection()

    /// Repositorio de red para obtener información de mangas
    private let networkRepo: NetworkRepository = Network()

    private init() {}

    // MARK: - Public Methods

    /// Sincroniza todos los cambios pendientes con el servidor.
    ///
    /// Este método debe ser llamado:
    /// - Al recuperar conexión a internet
    /// - Manualmente por el usuario (botón "Sincronizar")
    /// - Al iniciar sesión
    ///
    /// - Parameter context: El ModelContext de SwiftData.
    /// - Returns: Tupla con éxitos y fallos (success, failed).
    nonisolated func syncPendingChanges(context: ModelContext) async -> (success: Int, failed: Int) {
        // Obtener registros pendientes
        let descriptor = FetchDescriptor<UserMangaCollection>(
            predicate: #Predicate { $0.isPendingSync == true }
        )

        guard let pending = try? context.fetch(descriptor) else {
            return (0, 0)
        }

        var successCount = 0
        var failedCount = 0

        for entry in pending {
            do {
                try await syncEntry(entry, context: context)
                successCount += 1
            } catch {
                failedCount += 1
            }
        }

        // Guardar cambios en SwiftData
        try? context.save()

        return (successCount, failedCount)
    }

    /// Sincroniza un registro individual con el servidor.
    ///
    /// - Parameters:
    ///   - entry: El registro de colección a sincronizar.
    ///   - context: El ModelContext de SwiftData.
    private nonisolated func syncEntry(_ entry: UserMangaCollection, context: ModelContext) async throws {
        guard let operation = entry.pendingSyncOperation,
              let syncOp = SyncOperation(rawValue: operation) else {
            // Si no hay operación válida, marcar como sincronizado
            entry.markAsSynced()
            return
        }

        switch syncOp {
        case .add, .update:
            try await syncAddOrUpdate(entry, context: context)

        case .delete:
            try await syncDelete(entry, context: context)
        }
    }

    /// Sincroniza una operación de añadir/actualizar con el servidor.
    private nonisolated func syncAddOrUpdate(_ entry: UserMangaCollection, context: ModelContext) async throws {
        // Convertir a Request DTO (solo manga ID, no objeto completo)
        let collectionRequest = entry.toRequest()

        // Enviar al servidor
        do {
            try await collectionRepo.addOrUpdateCollection(collectionRequest)
        } catch {
            throw error
        }

        // Marcar como sincronizado
        entry.markAsSynced()
    }

    /// Sincroniza una operación de eliminar con el servidor.
    private nonisolated func syncDelete(_ entry: UserMangaCollection, context: ModelContext) async throws {
        // Eliminar del servidor
        try await collectionRepo.deleteCollectionManga(mangaID: entry.mangaID)

        // Eliminar del SwiftData local
        context.delete(entry)
    }

    // MARK: - Full Sync from Server

    /// Realiza una sincronización completa descargando la colección desde el servidor.
    ///
    /// Este método:
    /// 1. Descarga la colección completa del servidor
    /// 2. Actualiza SwiftData local con los datos del servidor
    /// 3. Elimina registros que no estén en el servidor
    ///
    /// **Importante**: Este método sobrescribe datos locales con los del servidor.
    /// Solo usar si el servidor es la fuente de verdad.
    ///
    /// - Parameter context: El ModelContext de SwiftData.
    /// - Returns: Número de registros sincronizados.
    nonisolated func fullSyncFromServer(context: ModelContext) async throws -> Int {
        // Descargar colección del servidor
        let serverCollection = try await collectionRepo.getCollection()

        // IDs de mangas en el servidor
        let serverMangaIDs = Set(serverCollection.map { $0.manga.id })

        // Obtener colección local
        let localDescriptor = FetchDescriptor<UserMangaCollection>()
        let localCollection = try context.fetch(localDescriptor)

        // Actualizar o crear registros desde el servidor
        for dto in serverCollection {
            if let existing = localCollection.first(where: { $0.mangaID == dto.manga.id }) {
                // Actualizar existente
                existing.readingVolume = dto.readingVolume
                existing.completeCollection = dto.completeCollection
                existing.setVolumes(dto.volumesOwned)
                existing.markAsSynced()
            } else {
                // Crear nuevo
                let newEntry = UserMangaCollection.from(dto)
                newEntry.markAsSynced()
                context.insert(newEntry)
            }
        }

        // Eliminar registros locales que no estén en el servidor
        for local in localCollection {
            if !serverMangaIDs.contains(local.mangaID) {
                context.delete(local)
            }
        }

        // Guardar cambios
        try context.save()

        return serverCollection.count
    }

    // MARK: - Helper Methods

    /// Verifica si hay cambios pendientes de sincronización.
    ///
    /// - Parameter context: El ModelContext de SwiftData.
    /// - Returns: `true` si hay cambios pendientes, `false` en caso contrario.
    nonisolated func hasPendingChanges(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<UserMangaCollection>(
            predicate: #Predicate { $0.isPendingSync == true }
        )

        guard let count = try? context.fetchCount(descriptor) else {
            return false
        }

        return count > 0
    }
}

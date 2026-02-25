//
//  CollectionRepository.swift
//  MisMangas
//
//  Created by Claude Code on 25/2/26.
//

import Foundation
import NetworkAPI
import SwiftData

/// Repositorio para gestionar la colección personal de mangas del usuario en el servidor.
///
/// Todas las operaciones requieren autenticación JWT (Bearer token).
/// Gestiona sincronización entre SwiftData local y servidor remoto.
///
/// ## Estrategia de sincronización:
/// - Con conexión: operación local + sync inmediato al servidor
/// - Sin conexión: operación local + marca como pendiente (`isPendingSync = true`)
protocol CollectionRepository: Sendable, NetworkInteractor {
    /// Obtiene la colección completa del usuario desde el servidor.
    ///
    /// - Returns: Array de DTOs con información completa de cada manga.
    /// - Throws: `AuthError.unauthorized` si el token no es válido.
    func getCollection() async throws -> [UserMangaCollectionDTO]

    /// Obtiene un manga específico de la colección del usuario.
    ///
    /// - Parameter mangaID: ID del manga a obtener.
    /// - Returns: DTO con información completa del manga.
    /// - Throws: Error si el manga no está en la colección (404).
    func getCollectionManga(mangaID: Int) async throws -> UserMangaCollectionDTO

    /// Añade o actualiza un manga en la colección del usuario en el servidor.
    ///
    /// Si el manga ya existe en la colección, actualiza los datos.
    ///
    /// - Parameter collection: DTO del manga a añadir/actualizar.
    /// - Throws: `AuthError.unauthorized` si el token no es válido.
    func addOrUpdateCollection(_ collection: UserMangaCollectionRequest) async throws

    /// Elimina un manga de la colección del usuario en el servidor.
    ///
    /// - Parameter mangaID: ID del manga a eliminar.
    /// - Throws: Error si el manga no está en la colección (404).
    func deleteCollectionManga(mangaID: Int) async throws
}

// MARK: - Implementation

struct Collection: CollectionRepository {

    // MARK: - Get Collection

    func getCollection() async throws -> [UserMangaCollectionDTO] {
        let request = try await URLRequest.getAuthenticated(url: .collection)
        return try await getJSON(request, type: [UserMangaCollectionDTO].self)
    }

    // MARK: - Get Collection Manga

    func getCollectionManga(mangaID: Int) async throws -> UserMangaCollectionDTO {
        let request = try await URLRequest.getAuthenticated(url: .collectionManga(id: mangaID))
        return try await getJSON(request, type: UserMangaCollectionDTO.self)
    }

    // MARK: - Add or Update Collection

    func addOrUpdateCollection(_ collection: UserMangaCollectionRequest) async throws {
        let request = try await URLRequest.postAuthenticated(url: .collection, body: collection)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.unauthorized
        }

        // 200 (updated) o 201 (created) son válidos
        guard (200...201).contains(httpResponse.statusCode) else {
            // Mostrar respuesta del servidor si hay error
            if let responseBody = String(data: data, encoding: .utf8) {
                print("❌ Error POST /collection/manga - Status: \(httpResponse.statusCode)")
                print("📄 Response: \(responseBody)")
            }
            throw AuthError.unauthorized
        }
    }

    // MARK: - Delete Collection Manga

    func deleteCollectionManga(mangaID: Int) async throws {
        let request = try await URLRequest.deleteAuthenticated(url: .collectionManga(id: mangaID))

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.unauthorized
        }

        guard httpResponse.statusCode == 200 else {
            throw AuthError.unauthorized
        }
    }
}

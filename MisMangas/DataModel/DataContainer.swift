//
//  DataContainer.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 30/12/25.
//

import SwiftUI
import SwiftData
import NetworkAPI

@ModelActor
actor DataContainer {
    private let network = Network()
    
    @AppStorage("page") private var actualPage = 1
    
    func loadInitialData() async throws {
        let (mangas, authors) = try await getMangasAndAuthors()
        try loadAuthors(authors: authors)
        try loadMangas(mangas: mangas.items)
    }
    
    func getMangasAndAuthors() async throws -> (MangaPageDTO, [AuthorDTO]) {
        async let getAuthors = network.getAuthors()
        async let getMangas = network.getMangasPage(page: actualPage)
        return try await (getMangas, getAuthors)
    }
    
    func getBestMangas() async throws -> MangaPageDTO {
        try await network.getBestMangas()
    }
    
    func loadMangas(mangas: [MangaDTO]) throws {
        // Usar la función global para insertar/actualizar mangas
        try insertOrUpdateMangas(in: modelContext, from: mangas)
    }
    
    func loadAuthors(authors: [AuthorDTO]) throws {
        // Obtener autores existentes
        let existingAuthors = try modelContext.fetch(FetchDescriptor<Author>())
        let existingIDs = Set(existingAuthors.map(\.id))
        
        // Insertar solo los nuevos
        for author in authors where !existingIDs.contains(author.id) {
            let newAuthor = Author(id: author.id, firstName: author.firstName, lastName: author.lastName, role: author.role)
            modelContext.insert(newAuthor)
        }
        
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
    
    // Función de refresh para cargar la siguiente página
    func loadNextPage() async throws {
        actualPage += 1

        do {
            let mangas = try await network.getMangasPage(page: actualPage)

            // Si no devuelve mangas, es que no hay más
            if mangas.items.isEmpty {
                print("ℹ️ No hay más mangas en la página \(actualPage)")
                actualPage -= 1  // Volver a la página anterior
                return
            }

            try loadMangas(mangas: mangas.items)
            print("✅ Cargada página \(actualPage) con \(mangas.items.count) mangas")
        } catch {
            print("❌ Error cargando página \(actualPage): \(error)")
            actualPage -= 1  // Volver a la página anterior
            throw error
        }
    }
}

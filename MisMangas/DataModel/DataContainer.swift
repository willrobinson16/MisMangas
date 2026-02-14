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
        try loadMangas(mangas: mangas)
    }
    
    func getMangasAndAuthors() async throws -> ([MangaDTO], [AuthorDTO]) {
        async let getAuthors = network.getAuthors()
        async let getMangas = network.getMangasPage(page: actualPage)
        return try await (getMangas, getAuthors)
    }
    
    func getBestMangas() async throws -> [MangaDTO] {
        try await network.getBestMangas()
    }
    
    func loadMangas(mangas: [MangaDTO]) throws {
        for manga in mangas {
            // Buscar o crear authors
            var mangaAuthors: [Author] = []
            for authorDTO in manga.authors {
                let authorID = authorDTO.id
                var fetchAuthor = FetchDescriptor<Author>(predicate: #Predicate { $0.id == authorID })
                fetchAuthor.fetchLimit = 1
                let queryAuthor = try modelContext.fetch(fetchAuthor)
                
                if let existingAuthor = queryAuthor.first {
                    mangaAuthors.append(existingAuthor)
                } else {
                    let newAuthor = Author(id: authorDTO.id, firstName: authorDTO.firstName, lastName: authorDTO.lastName, role: authorDTO.role)
                    modelContext.insert(newAuthor)
                    mangaAuthors.append(newAuthor)
                }
            }
            
            // Buscar o crear themes
            var mangaThemes: [Theme] = []
            for themeDTO in manga.themes {
                let themeID = themeDTO.id
                var fetchTheme = FetchDescriptor<Theme>(predicate: #Predicate { $0.id == themeID })
                fetchTheme.fetchLimit = 1
                let queryTheme = try modelContext.fetch(fetchTheme)
                
                if let existingTheme = queryTheme.first {
                    mangaThemes.append(existingTheme)
                } else {
                    let newTheme = Theme(id: themeDTO.id, theme: themeDTO.theme)
                    modelContext.insert(newTheme)
                    mangaThemes.append(newTheme)
                }
            }
            
            // Buscar o crear genres
            var mangaGenres: [Genre] = []
            for genreDTO in manga.genres {
                let genreID = genreDTO.id
                var fetchGenre = FetchDescriptor<Genre>(predicate: #Predicate { $0.id == genreID })
                fetchGenre.fetchLimit = 1
                let queryGenre = try modelContext.fetch(fetchGenre)
                
                if let existingGenre = queryGenre.first {
                    mangaGenres.append(existingGenre)
                } else {
                    let newGenre = Genre(id: genreDTO.id, genre: genreDTO.genre)
                    modelContext.insert(newGenre)
                    mangaGenres.append(newGenre)
                }
            }
            
            // Buscar o crear demographics
            var mangaDemographics: [Demographic] = []
            for demographicDTO in manga.demographics {
                let demographicID = demographicDTO.id
                var fetchDemographic = FetchDescriptor<Demographic>(predicate: #Predicate { $0.id == demographicID })
                fetchDemographic.fetchLimit = 1
                let queryDemographic = try modelContext.fetch(fetchDemographic)
                
                if let existingDemographic = queryDemographic.first {
                    mangaDemographics.append(existingDemographic)
                } else {
                    let newDemographic = Demographic(id: demographicDTO.id, demographic: demographicDTO.demographic)
                    modelContext.insert(newDemographic)
                    mangaDemographics.append(newDemographic)
                }
            }
            
            // Buscar o actualizar el manga
            let mangaID = manga.id
            var fetchManga = FetchDescriptor<Manga>(predicate: #Predicate { $0.id == mangaID })
            fetchManga.fetchLimit = 1
            let queryManga = try modelContext.fetch(fetchManga)
            
            if let foundManga = queryManga.first {
                // Actualizar manga existente
                foundManga.status = statusToString(manga.status)
                foundManga.background = manga.background
                foundManga.title = manga.title
                foundManga.titleEnglish = manga.titleEnglish
                foundManga.titleJapanese = manga.titleJapanese
                foundManga.score = manga.score
                foundManga.chapters = manga.chapters
                foundManga.startDate = manga.startDate
                foundManga.endDate = manga.endDate
                foundManga.mainPicture = manga.mainPictureURL
                foundManga.synopsis = manga.synopsis
                foundManga.url = manga.urlCleaned
                foundManga.volumes = manga.volumes
                foundManga.themes = mangaThemes
                foundManga.authors = mangaAuthors
                foundManga.genres = mangaGenres
                foundManga.demographics = mangaDemographics
            } else {
                // Crear nuevo manga
                let newManga = Manga(
                    id: manga.id,
                    status: statusToString(manga.status),
                    background: manga.background,
                    title: manga.title,
                    titleEnglish: manga.titleEnglish,
                    titleJapanese: manga.titleJapanese,
                    score: manga.score,
                    chapters: manga.chapters,
                    startDate: manga.startDate,
                    endDate: manga.endDate,
                    mainPicture: manga.mainPictureURL,
                    synopsis: manga.synopsis,
                    url: manga.urlCleaned,
                    volumes: manga.volumes,
                    themes: mangaThemes,
                    authors: mangaAuthors,
                    genres: mangaGenres,
                    demographics: mangaDemographics
                )
                modelContext.insert(newManga)
            }
        }
        
        if modelContext.hasChanges {
            try modelContext.save()
        }
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
            if mangas.isEmpty {
                print("ℹ️ No hay más mangas en la página \(actualPage)")
                actualPage -= 1  // Volver a la página anterior
                return
            }
            
            try loadMangas(mangas: mangas)
            print("✅ Cargada página \(actualPage) con \(mangas.count) mangas")
        } catch {
            print("❌ Error cargando página \(actualPage): \(error)")
            actualPage -= 1  // Volver a la página anterior
            throw error
        }
    }
    
    // Helper function para convertir el enum MangaStatus a String
    private func statusToString(_ status: MangaStatus) -> String {
        return switch status {
        case .discontinued:
            "discontinued"
        case .onHiatus:
            "on_hiatus"
        case .currentlyPublishing:
            "currently_publishing"
        case .finished:
            "finished"
        case .none:
            "none"
        }
    }
}

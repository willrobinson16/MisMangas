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
    private let network = NetworkRepository()
    
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
    
    func loadMangas(mangas: [MangaDTO]) throws {
        // 1. Cargar todos los datos existentes de una vez
        let existingMangas = try modelContext.fetch(FetchDescriptor<Manga>())
        let existingAuthors = try modelContext.fetch(FetchDescriptor<Author>())
        let existingThemes = try modelContext.fetch(FetchDescriptor<Theme>())
        let existingGenres = try modelContext.fetch(FetchDescriptor<Genre>())
        let existingDemographics = try modelContext.fetch(FetchDescriptor<Demographic>())
        
        // 2. Convertir a diccionarios para búsqueda rápida
        let mangasDict = Dictionary(uniqueKeysWithValues: existingMangas.map { ($0.id, $0) })
        var authorsDict = Dictionary(uniqueKeysWithValues: existingAuthors.map { ($0.id, $0) })
        var themesDict = Dictionary(uniqueKeysWithValues: existingThemes.map { ($0.id, $0) })
        var genresDict = Dictionary(uniqueKeysWithValues: existingGenres.map { ($0.id, $0) })
        var demographicsDict = Dictionary(uniqueKeysWithValues: existingDemographics.map { ($0.id, $0) })
        
        // 3. Procesar cada manga
        for manga in mangas {
            // Buscar o crear autores
            var mangaAuthors: [Author] = []
            for author in manga.authors {
                if let existing = authorsDict[author.id] {
                    mangaAuthors.append(existing)
                } else {
                    let newAuthor = Author(id: author.id, firstName: author.firstName, lastName: author.lastName, role: author.role)
                    modelContext.insert(newAuthor)
                    authorsDict[author.id] = newAuthor
                    mangaAuthors.append(newAuthor)
                }
            }
            
            // Buscar o crear themes
            var mangaThemes: [Theme] = []
            for theme in manga.themes {
                if let existing = themesDict[theme.id] {
                    mangaThemes.append(existing)
                } else {
                    let newTheme = Theme(id: theme.id, theme: theme.theme)
                    modelContext.insert(newTheme)
                    themesDict[theme.id] = newTheme
                    mangaThemes.append(newTheme)
                }
            }
            
            // Buscar o crear genres
            var mangaGenres: [Genre] = []
            for genre in manga.genres {
                if let existing = genresDict[genre.id] {
                    mangaGenres.append(existing)
                } else {
                    let newGenre = Genre(id: genre.id, genre: genre.genre)
                    modelContext.insert(newGenre)
                    genresDict[genre.id] = newGenre
                    mangaGenres.append(newGenre)
                }
            }
            
            // Buscar o crear demographics
            var mangaDemographics: [Demographic] = []
            for demographic in manga.demographics {
                if let existing = demographicsDict[demographic.id] {
                    mangaDemographics.append(existing)
                } else {
                    let newDemographic = Demographic(id: demographic.id, demographic: demographic.demographic)
                    modelContext.insert(newDemographic)
                    demographicsDict[demographic.id] = newDemographic
                    mangaDemographics.append(newDemographic)
                }
            }
            
            // Verificar si el manga existe
            let mangaID = manga.id
            if let foundManga = mangasDict[mangaID] {
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
                foundManga.mainPicture = manga.mainPicture
                foundManga.synopsis = manga.synopsis
                foundManga.url = manga.url?.absoluteString
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
                    mainPicture: manga.mainPicture,
                    synopsis: manga.synopsis,
                    url: manga.url?.absoluteString,
                    volumes: manga.volumes,
                    themes: mangaThemes,
                    authors: mangaAuthors,
                    genres: mangaGenres,
                    demographics: mangaDemographics
                )
                modelContext.insert(newManga)
            }
        }
        
        // Guardar una sola vez
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
    
    func loadAuthors(authors: [AuthorDTO]) throws {
        // Obtener autores existentes (1 query)
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
        let mangas = try await network.getMangasPage(page: actualPage)
        try loadMangas(mangas: mangas)
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

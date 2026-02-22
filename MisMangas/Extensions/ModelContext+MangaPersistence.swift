//
//  ModelContext+MangaPersistence.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 22/2/26.
//

import Foundation
import SwiftData

// MARK: - Funciones globales para persistencia de Mangas
// Estas funciones NO tienen aislamiento de actor, funcionan en cualquier contexto

/// Inserta o actualiza un manga desde un DTO en el contexto proporcionado
/// - Parameters:
///   - context: El ModelContext donde persistir
///   - dto: El MangaDTO desde el cual crear/actualizar el manga
/// - Throws: Error de SwiftData si falla la persistencia
nonisolated func insertOrUpdateManga(in context: ModelContext, from dto: MangaDTO) throws {
    let mangaID = dto.id

    // Verificar si el manga ya existe
    let descriptor = FetchDescriptor<Manga>(
        predicate: #Predicate { $0.id == mangaID }
    )

    // Buscar/crear entidades relacionadas
    let themes = try fetchOrCreateThemes(in: context, from: dto.themes)
    let authors = try fetchOrCreateAuthors(in: context, from: dto.authors)
    let genres = try fetchOrCreateGenres(in: context, from: dto.genres)
    let demographics = try fetchOrCreateDemographics(in: context, from: dto.demographics)

    // Actualizar o crear manga
    if let existingManga = try context.fetch(descriptor).first {
        // Actualizar manga existente
        updateManga(existingManga, in: context, from: dto, themes: themes, authors: authors, genres: genres, demographics: demographics)
    } else {
        // Crear nuevo manga
        let newManga = createManga(from: dto, themes: themes, authors: authors, genres: genres, demographics: demographics)
        context.insert(newManga)
    }
}

/// Inserta o actualiza múltiples mangas y guarda los cambios
/// - Parameters:
///   - context: El ModelContext donde persistir
///   - dtos: Array de MangaDTOs a persistir
/// - Throws: Error de SwiftData si falla la persistencia
nonisolated func insertOrUpdateMangas(in context: ModelContext, from dtos: [MangaDTO]) throws {
    for dto in dtos {
        try insertOrUpdateManga(in: context, from: dto)
    }

    if context.hasChanges {
        try context.save()
    }
}

/// Inserta un manga @Model class (creado por .toManga) con sus relaciones
/// - Parameters:
///   - context: El ModelContext donde persistir
///   - manga: La instancia de Manga (@Model class) a persistir
/// - Throws: Error de SwiftData si falla la persistencia
nonisolated func insertOrUpdateManga(in context: ModelContext, _ manga: Manga) throws {
    let mangaID = manga.id

    // Verificar si el manga ya existe
    let descriptor = FetchDescriptor<Manga>(
        predicate: #Predicate { $0.id == mangaID }
    )

    if (try context.fetch(descriptor).first) != nil {
        return  // Ya existe, no hacer nada
    }

    // Persistir todas las relaciones PRIMERO
    for theme in manga.themes {
        let themeID = theme.id
        var fetchTheme = FetchDescriptor<Theme>(predicate: #Predicate { $0.id == themeID })
        fetchTheme.fetchLimit = 1

        if (try context.fetch(fetchTheme).first) == nil {
            context.insert(theme)
        }
    }

    for author in manga.authors {
        let authorID = author.id
        var fetchAuthor = FetchDescriptor<Author>(predicate: #Predicate { $0.id == authorID })
        fetchAuthor.fetchLimit = 1

        if (try context.fetch(fetchAuthor).first) == nil {
            context.insert(author)
        }
    }

    for genre in manga.genres {
        let genreID = genre.id
        var fetchGenre = FetchDescriptor<Genre>(predicate: #Predicate { $0.id == genreID })
        fetchGenre.fetchLimit = 1

        if (try context.fetch(fetchGenre).first) == nil {
            context.insert(genre)
        }
    }

    for demographic in manga.demographics {
        let demographicID = demographic.id
        var fetchDemographic = FetchDescriptor<Demographic>(predicate: #Predicate { $0.id == demographicID })
        fetchDemographic.fetchLimit = 1

        if (try context.fetch(fetchDemographic).first) == nil {
            context.insert(demographic)
        }
    }

    // Persistir el manga
    context.insert(manga)

    if context.hasChanges {
        try context.save()
    }
}

// MARK: - Theme Persistence

/// Busca o crea themes desde un array de DTOs
private nonisolated func fetchOrCreateThemes(in context: ModelContext, from dtos: [ThemeDTO]) throws -> [Theme] {
    var themes: [Theme] = []

    for dto in dtos {
        let themeID = dto.id
        var fetchTheme = FetchDescriptor<Theme>(predicate: #Predicate { $0.id == themeID })
        fetchTheme.fetchLimit = 1
        let queryTheme = try context.fetch(fetchTheme)

        if let existingTheme = queryTheme.first {
            themes.append(existingTheme)
        } else {
            let newTheme = Theme(id: dto.id, theme: dto.theme)
            context.insert(newTheme)
            themes.append(newTheme)
        }
    }

    return themes
}

// MARK: - Author Persistence

/// Busca o crea authors desde un array de DTOs
private nonisolated func fetchOrCreateAuthors(in context: ModelContext, from dtos: [AuthorDTO]) throws -> [Author] {
    var authors: [Author] = []

    for dto in dtos {
        let authorID = dto.id
        var fetchAuthor = FetchDescriptor<Author>(predicate: #Predicate { $0.id == authorID })
        fetchAuthor.fetchLimit = 1
        let queryAuthor = try context.fetch(fetchAuthor)

        if let existingAuthor = queryAuthor.first {
            authors.append(existingAuthor)
        } else {
            let newAuthor = Author(id: dto.id, firstName: dto.firstName, lastName: dto.lastName, role: dto.role)
            context.insert(newAuthor)
            authors.append(newAuthor)
        }
    }

    return authors
}

// MARK: - Genre Persistence

/// Busca o crea genres desde un array de DTOs
private nonisolated func fetchOrCreateGenres(in context: ModelContext, from dtos: [GenreDTO]) throws -> [Genre] {
    var genres: [Genre] = []

    for dto in dtos {
        let genreID = dto.id
        var fetchGenre = FetchDescriptor<Genre>(predicate: #Predicate { $0.id == genreID })
        fetchGenre.fetchLimit = 1
        let queryGenre = try context.fetch(fetchGenre)

        if let existingGenre = queryGenre.first {
            genres.append(existingGenre)
        } else {
            let newGenre = Genre(id: dto.id, genre: dto.genre)
            context.insert(newGenre)
            genres.append(newGenre)
        }
    }

    return genres
}

// MARK: - Demographic Persistence

/// Busca o crea demographics desde un array de DTOs
private nonisolated func fetchOrCreateDemographics(in context: ModelContext, from dtos: [DemographicDTO]) throws -> [Demographic] {
    var demographics: [Demographic] = []

    for dto in dtos {
        let demographicID = dto.id
        var fetchDemographic = FetchDescriptor<Demographic>(predicate: #Predicate { $0.id == demographicID })
        fetchDemographic.fetchLimit = 1
        let queryDemographic = try context.fetch(fetchDemographic)

        if let existingDemographic = queryDemographic.first {
            demographics.append(existingDemographic)
        } else {
            let newDemographic = Demographic(id: dto.id, demographic: dto.demographic)
            context.insert(newDemographic)
            demographics.append(newDemographic)
        }
    }

    return demographics
}

// MARK: - Manga Creation/Update

/// Actualiza un manga existente con datos del DTO
private nonisolated func updateManga(
    _ manga: Manga,
    in context: ModelContext,
    from dto: MangaDTO,
    themes: [Theme],
    authors: [Author],
    genres: [Genre],
    demographics: [Demographic]
) {
    manga.status = statusToString(dto.status)
    manga.background = dto.background
    manga.title = dto.title
    manga.titleEnglish = dto.titleEnglish
    manga.titleJapanese = dto.titleJapanese
    manga.score = dto.score
    manga.chapters = dto.chapters
    manga.startDate = dto.startDate
    manga.endDate = dto.endDate
    manga.mainPicture = dto.mainPictureURL
    manga.synopsis = dto.synopsis
    manga.url = dto.urlCleaned
    manga.volumes = dto.volumes
    manga.themes = themes
    manga.authors = authors
    manga.genres = genres
    manga.demographics = demographics
}

/// Crea un nuevo manga desde el DTO
private nonisolated func createManga(
    from dto: MangaDTO,
    themes: [Theme],
    authors: [Author],
    genres: [Genre],
    demographics: [Demographic]
) -> Manga {
    Manga(
        id: dto.id,
        status: statusToString(dto.status),
        background: dto.background,
        title: dto.title,
        titleEnglish: dto.titleEnglish,
        titleJapanese: dto.titleJapanese,
        score: dto.score,
        chapters: dto.chapters,
        startDate: dto.startDate,
        endDate: dto.endDate,
        mainPicture: dto.mainPictureURL,
        synopsis: dto.synopsis,
        url: dto.urlCleaned,
        volumes: dto.volumes,
        themes: themes,
        authors: authors,
        genres: genres,
        demographics: demographics
    )
}

// MARK: - Helper

/// Convierte el enum MangaStatus a String para persistencia
private nonisolated func statusToString(_ status: MangaStatus) -> String {
    switch status {
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

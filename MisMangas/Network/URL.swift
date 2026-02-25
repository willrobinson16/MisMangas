//
//  URL.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

let api = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!

extension URL {
    // MARK: - Base paths
    private static let listBase = api.appending(path: "list")
    private static let searchBase = api.appending(path: "search")
    
    // MARK: - List endpoints
    static let getMangas = listBase.appending(path: "mangas")
    static let getBestMangas = listBase.appending(path: "bestMangas")
    static let getAuthors = listBase.appending(path: "authors")
    static let getDemographics = listBase.appending(path: "demographics")
    static let getGenres = listBase.appending(path: "genres")
    static let getThemes = listBase.appending(path: "themes")
    
    static func mangaByAuthor(id: String) -> URL {
        listBase.appending(path: "mangaByAuthor").appending(path: id)
    }

    static func mangaByAuthor(id: String, page: Int, per: Int = 10) -> URL {
        listBase
            .appending(path: "mangaByAuthor")
            .appending(path: id)
            .appending(queryItems: [
                URLQueryItem(name: "per", value: "\(per)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
    }
    
    static func mangaByDemographic(demographic: Demographic) -> URL {
        listBase.appending(path: "mangaByDemographic").appending(path: "\(demographic)")
    }
    
    static func mangaByGenre(genre: Genre) -> URL {
        listBase.appending(path: "mangaByGenre").appending(path: "\(genre)")
    }
    
    static func mangaByTheme(theme: Theme) -> URL {
        listBase.appending(path: "mangaByTheme").appending(path: "\(theme)")
    }
    
    // MARK: - Search endpoints
    static func mangasBeginsWith(_ title: String) -> URL {
        searchBase.appending(path: "mangasBeginsWith").appending(path: title)
    }
    
    static func mangasContains(_ title: String) -> URL {
        searchBase.appending(path: "mangasContains").appending(path: title)
    }
    
    static func manga(id: Int) -> URL {
        searchBase.appending(path: "manga").appending(path: "\(id)")
    }
    
    static func author(_ name: String) -> URL {
        searchBase.appending(path: "author").appending(path: name)
    }
    
    static func customSearch(page: Int = 1, per: Int = 10) -> URL {
        searchBase
            .appending(path: "manga")
            .appending(queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per", value: "\(per)")
            ])
    }
    
    // MARK: - JWT Authentication endpoints
    static let jwtLogin = api.appendingPathComponent("users/jwt/login")
    static let jwtRefresh = api.appendingPathComponent("users/jwt/refresh")
    static let jwtMe = api.appendingPathComponent("users/jwt/me")

    // MARK: - User endpoints
    static let register = api.appendingPathComponent("users")

    // MARK: - Legacy Authentication endpoints (deprecated, usar JWT)
    static let login = api.appendingPathComponent("users/login")
    static let renewToken = api.appendingPathComponent("users/renew")

    // MARK: - Collection endpoints
    static let collection = api.appendingPathComponent("collection/manga")

    static func collectionManga(id: Int) -> URL {
        api.appending(path: "collection/manga").appending(path: "\(id)")
    }
    
    // MARK: - Pagination helper
    static func getMangas(page: Int, itemsPerPage: Int = 10) -> URL {
        listBase
            .appending(path: "mangas")
            .appending(queryItems: [
                URLQueryItem(name: "per", value: "\(itemsPerPage)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
    }

    static func getBestMangas(page: Int, per: Int = 10) -> URL {
        listBase
            .appending(path: "bestMangas")
            .appending(queryItems: [
                URLQueryItem(name: "per", value: "\(per)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
    }

    static func getAuthorsPaged(page: Int, per: Int = 10) -> URL {
        listBase
            .appending(path: "authorsPaged")
            .appending(queryItems: [
                URLQueryItem(name: "per", value: "\(per)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
    }
}

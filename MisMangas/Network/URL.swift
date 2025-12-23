//
//  URL.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

let api = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs#")!

/// Type-safe extension
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
    
    // Funciones que necesitan parámetros dinámicos
    static func getMangas(page: Int, itemsPerPage: Int = 10) -> URL {
        listBase
            .appending(path: "mangas")
            .appending(queryItems: [
                URLQueryItem(name: "per", value: "\(itemsPerPage)"),
                URLQueryItem(name: "page", value: "\(page)")
            ])
    }
    
    static func mangaByAuthor(id: String) -> URL {
        listBase.appending(path: "mangaByAuthor/\(id)")
    }
    
    static func mangaByDemographic(demographic: Demographic) -> URL {
        listBase.appending(path: "mangaByDemographic/\(demographic)")
    }
    
    static func mangaByGenre(genre: Genre) -> URL {
        listBase.appending(path: "mangaByGenre/\(genre)")
    }
    
    static func mangaByTheme(theme: Theme) -> URL {
        listBase.appending(path: "mangaByTheme/\(theme)")
    }
    
    // MARK: - Search endpoints
    static func mangasBeginsWith(_ title: String) -> URL {
        searchBase.appending(path: "mangasBeginsWith/\(title)")
    }
    
    static func mangasContains(_ title: String) -> URL {
        searchBase.appending(path: "mangasContains/\(title)")
    }
    
    static func manga(id: Int) -> URL {
        searchBase.appending(path: "manga/\(id)")
    }
    
    static func author(_ name: String) -> URL {
        searchBase.appending(path: "author/\(name)")
    }
    
    //TODO: comprobar para el CustomSearch
    static let customSearch = searchBase.appending(path: "manga")
}

//TODO: estudiar cómo incoroporarlo
struct CustomSearch: Codable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool
}

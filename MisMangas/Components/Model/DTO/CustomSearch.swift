//
//  CustomSearch.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Custom Search
/// Advanced manga search with multiple filters (all optional, combined with AND logic)
struct CustomSearch: Codable {
    let searchTitle: String?
    let searchAuthorFirstName: String?
    let searchAuthorLastName: String?
    let searchGenres: [String]?
    let searchThemes: [String]?
    let searchDemographics: [String]?
    let searchContains: Bool
}

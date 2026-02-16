//
//  PageMetadataDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Pagination metadata
struct PageMetadataDTO: Codable {
    let total: Int
    let page: Int
    let per: Int
}

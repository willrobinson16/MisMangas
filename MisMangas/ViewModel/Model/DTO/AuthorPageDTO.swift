//
//  AuthorPageDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Paginated Author Response
/// Paginated list of authors
struct AuthorPageDTO: Codable {
    let metadata: PageMetadataDTO
    let items: [AuthorDTO]
}

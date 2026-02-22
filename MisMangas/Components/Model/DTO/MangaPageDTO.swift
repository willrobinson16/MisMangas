//
//  MangaPageDTO.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Paginated Manga Response
/// Paginated list of manga
struct MangaPageDTO: Codable {
    let metadata: PageMetadataDTO
    let items: [MangaDTO]
}

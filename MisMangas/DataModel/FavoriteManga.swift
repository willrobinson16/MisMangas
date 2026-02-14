//
//  FavoriteManga.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import Foundation
import SwiftData

@Model
final class FavoriteManga {
    @Attribute(.unique) var id: Int
    var dataAdded: Date
    
    init(id: Int) {
        self.id = id
        self.dataAdded = Date()
    }
}

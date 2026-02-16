//
//  PreviewContainer.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 12/12/25.
//

import SwiftUI
import SwiftData

struct PreviewContainer: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for:
                Manga.self,
                FavoriteManga.self,
                UserMangaCollection.self,
                Author.self,
                Theme.self,
                Genre.self,
                Demographic.self,
                configurations: configuration
        )
        
        Manga.sampleMangas.forEach { manga in
            container.mainContext.insert(manga)
        }
        try container.mainContext.save()
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var sampleData: Self = .modifier(PreviewContainer())
}

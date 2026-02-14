//
//  FavoritesViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import Foundation
import SwiftData

@Observable @MainActor
final class FavoritesViewModel {
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }
    
    func addFavorite(manga: Manga) {
        guard let context = modelContext else { return }
        
        // Insertar favorito de inmediato
        let favorite = FavoriteManga(id: manga.id)
        context.insert(favorite)
        try? context.save()
        
        // Cargar datos completos en background
        Task {
            let mangaID = manga.id
            let fetchManga = FetchDescriptor<Manga>(predicate: #Predicate { m in
                m.id == mangaID
            })
            
            if (try? context.fetch(fetchManga).first) == nil {
                do {
                    print("📥 Cargando manga completo desde API: \(manga.title)")
                    
                    let network = Network()
                    let mangaDTO = try await network.getManga(id: manga.id)
                    
                    let dataContainer = DataContainer(modelContainer: context.container)
                    try await dataContainer.loadMangas(mangas: [mangaDTO])
                    
                    print("✅ Manga cargado y guardado correctamente")
                } catch {
                    print("❌ Error cargando manga: \(error)")
                }
            }
        }
    }
    
    func removeFavorite(_ mangaID: Int) {
        guard let context = modelContext else { return }
        
        let fetch = FetchDescriptor<FavoriteManga>(predicate: #Predicate { $0.id == mangaID })
        if let favorite = try? context.fetch(fetch).first {
            context.delete(favorite)
            try? context.save()
        }
    }
    
    func isFavorite(_ mangaID: Int) -> Bool {
        guard let context = modelContext else { return false }

        let fetch = FetchDescriptor<FavoriteManga>(predicate: #Predicate { $0.id == mangaID })
        return (try? context.fetch(fetch).first) != nil
//        let count = (try? context.fetchCount(fetch)) ?? 0
//        return count > 0
    }
    
    func toggleFavorite(_ manga: Manga) {
        if isFavorite(manga.id) {
            removeFavorite(manga.id)
        } else {
            addFavorite(manga: manga)
        }
    }
    
    func favoritesCount() -> Int {
        guard let context = modelContext else { return 0 }

        let fetch = FetchDescriptor<FavoriteManga>()
        return (try? context.fetchCount(fetch)) ?? 0
    }
}

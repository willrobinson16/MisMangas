//
//  BestMangasViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 14/2/26.
//

import Foundation

@Observable @MainActor
final class BestMangasViewModel {
    private let network = Network()
    
    var bestMangas: [MangaDTO] = []
    var isLoading = false
    var errorMessage: String?
    private var hasLoaded = false
    
    func loadBestMangas() async {
        guard !hasLoaded, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Llamando a getBestMangas()...")
            bestMangas = try await network.getBestMangas()
            print("✅ Recibidos \(bestMangas.count) mangas")
            hasLoaded = true
        } catch {
            errorMessage = "No se pudieron cargar los mejores mangas"
            print("❌ Error loading best mangas: \(error)")  // ← Este print debería aparecer
        }
        
        isLoading = false
    }
    
    func retry() async {
        hasLoaded = false
        await loadBestMangas()
    }
}

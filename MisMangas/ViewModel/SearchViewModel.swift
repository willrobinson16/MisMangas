//
//  SearchViewModel.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 2/2/26.
//

import Foundation

@Observable @MainActor
final class SearchViewModel {
    var search = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task {
                // Espera 0.5 segundos después de que el usuario deje de escribir
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                await searchMangasBeginsWith()
            }
        }
    }
    let network = Network()
    private var searchTask: Task<Void, Never>?
    
    var mangaResult: [MangaDTO] = []
    
    func searchMangasBeginsWith() async {
        guard search.count > 2 else {
            mangaResult = []
            return
        }
        do {
            mangaResult = try await network.searchMangasBeginsWith(search.lowercased())
        } catch {
            print(error)
        }
    }
    
    func clearResults() {
        mangaResult = []
    }}

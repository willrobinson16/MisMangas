//
//  MisMangasApp.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/12/25.
//

import SwiftUI
import SwiftData

@main
struct MisMangasApp: App {
    @State private var favoritesVM = FavoritesViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTab()
                .environment(favoritesVM)
        }
        .modelContainer(for: [FavoriteManga.self, Manga.self]) { result in
            guard case .success(let container) = result else {
                return
            }
            Task.detached(priority: .high) {
                let modelContainer = DataContainer(modelContainer: container)
                do {
                    try await modelContainer.loadInitialData()
                } catch {
                    print(error)
                }
            }
        }
    }
}

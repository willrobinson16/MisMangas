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
    @State private var authVM = AuthViewModel()
    @State private var favoritesVM = FavoritesViewModel()
    @State private var userCollectionVM = UserCollectionViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    MainTab()
                        .environment(favoritesVM)
                        .environment(userCollectionVM)
                } else {
                    LoginView(authVM: authVM)
                }
            }
            .environment(authVM)
        }
        .modelContainer(for: [FavoriteManga.self, Manga.self, UserMangaCollection.self]) { result in
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

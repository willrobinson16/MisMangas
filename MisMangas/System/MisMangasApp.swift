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
                    MainTab(authVM: authVM)
                        .environment(favoritesVM)
                        .environment(userCollectionVM)
                } else {
                    LoginView(authVM: authVM)
                }
            }
            .environment(authVM)
        }
        .modelContainer(for: [FavoriteManga.self, Manga.self, UserMangaCollection.self])
    }
}

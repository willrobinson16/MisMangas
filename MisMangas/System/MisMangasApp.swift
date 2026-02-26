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
            ContentWrapper(authVM: authVM, favoritesVM: favoritesVM, userCollectionVM: userCollectionVM)
        }
        .modelContainer(for: [FavoriteManga.self, Manga.self, UserMangaCollection.self])
    }
}

// Wrapper para acceder al modelContext
private struct ContentWrapper: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var authVM: AuthViewModel
    @Bindable var favoritesVM: FavoritesViewModel
    @Bindable var userCollectionVM: UserCollectionViewModel

    var body: some View {
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
        .task {
            // Inyectar modelContext en los ViewModels
            authVM.setModelContext(modelContext)
            favoritesVM.setModelContext(modelContext)
            userCollectionVM.setModelContext(modelContext)
        }
    }
}

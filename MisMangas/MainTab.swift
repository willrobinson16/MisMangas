//
//  MainTab.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI
import SwiftData

@MainActor let isiPhone = UIDevice.current.userInterfaceIdiom == .phone

struct MainTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(FavoritesViewModel.self) private var favoritesVM
    @Environment(UserCollectionViewModel.self) private var userCollectionVM
    
    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book") {
                if !isiPhone {
                    
                } else {
                    ContentView()
                }
            }
            Tab("Favoritos", systemImage: "heart.fill") {
                if !isiPhone {
                    
                } else {
                    FavoritesView()
                }
            }
            Tab("Mi colección", systemImage: "books.vertical.fill") {
                if !isiPhone {
                    
                } else {
                    UserCollectionView()
                }
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.tabBar)
        .task {
            favoritesVM.setModelContext(modelContext)
            userCollectionVM.setModelContext(modelContext)
        }
    }
}

#Preview(traits: .sampleData) {
    MainTab()
        .environment(FavoritesViewModel())
        .environment(UserCollectionViewModel())
        .modelContainer(for: [Manga.self, FavoriteManga.self, UserMangaCollection.self])
}

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

    @Bindable var authVM: AuthViewModel

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book") {
                if !isiPhone {
                    ContentViewiPad()
                } else {
                    ContentView()
                }
            }
            Tab("Mi colección", systemImage: "books.vertical.fill") {
                UserCollectionView()
            }
            Tab("Autores", systemImage: "person.2.fill") {
                if !isiPhone {
                    AuthorsListViewiPad()
                } else {
                    AuthorsListView()
                }
            }
            Tab("Usuario", systemImage: "person.circle.fill") {
                if !isiPhone {
                    UserProfileViewiPad(authVM: authVM)
                } else {
                    UserProfileView(authVM: authVM)
                }
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                if !isiPhone {
                    SearchViewiPad()
                } else {
                    SearchView()
                }
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
    @Previewable @State var authVM = AuthViewModel()
    MainTab(authVM: authVM)
        .environment(FavoritesViewModel())
        .environment(UserCollectionViewModel())
        .modelContainer(for: [Manga.self, FavoriteManga.self, UserMangaCollection.self])
}

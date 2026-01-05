//
//  MainTab.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI

@MainActor let isiPhone = UIDevice.current.userInterfaceIdiom == .phone

struct MainTab: View {
    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book") {
                if !isiPhone {
                    
                } else {
                    ContentView()
                }
            }
            Tab("By Author", systemImage: "person") {
                if !isiPhone {
                    
                } else {
                    //ListByAuthor()
                }
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                //SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.tabBar)
    }
}

#Preview(traits: .sampleData) {
    MainTab()
}

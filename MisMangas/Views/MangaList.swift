//
//  ContentView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/12/25.
//

import SwiftUI
import SwiftData

struct MangaList: View {
    @Query private var mangas: [Manga]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(mangas) { manga in
                        MangaRow(manga: manga)
                    }
                }
            }
            .safeAreaPadding()
            .navigationTitle("Manga")
        }
    }
}

#Preview(traits: .sampleData) {
    MangaList()
}

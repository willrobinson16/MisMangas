//
//  ContentView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Query private var mangas: [Manga]
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(mangas) { manga in
                        NavigationLink(value: manga) {
                            MangaRow(manga: manga, namespace: namespace)
                        }
                        .buttonStyle(.plain)
                    }
                    if mangas.count > 1 {
                        ProgressView()
                            .onAppear {
                                let modelContainer = DataContainer(modelContainer: context.container)
                                Task.detached {
                                    do {
                                        try await modelContainer.loadNextPage() 
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                    }
                }
            }
            .safeAreaPadding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Manga.self) { manga in
                MangaView(manga: manga, namespace: namespace)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mangas")
                        .font(.title3)
                        .bold()
                }
            }
            .toolbarRole(.editor)
        }
        .refreshable {
            let modelContainer = DataContainer(modelContainer: context.container)
            Task.detached {
                do {
                    try await modelContainer.loadInitialData()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}

//
//  MangaGridListView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 3/2/26.
//

import SwiftUI
import SwiftData

struct MangaGridListView: View {
    let mangas: [Manga]
    let favoritesIDs: Set<Int>
    let namespace: Namespace.ID
    let onToggleFavorite: (Manga) -> Void
    
    @State private var isGridSelected = true
    
    private let rows = [
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        Group {
            if isGridSelected {
                LazyHGrid(rows: rows, spacing: 12) {
                    mangaGridContent
                }
                .padding(.horizontal, 4)
            } else {
                List {
                    mangaListContent
                }
                .listStyle(.plain)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Section("Vista") {
                        Button {
                            withAnimation(.smooth) {
                                isGridSelected = true
                            }
                        } label: {
                            Label("Cuadrícula", systemImage: isGridSelected ? "checkmark" : "square.grid.2x2")
                        }
                        
                        Button {
                            withAnimation(.smooth) {
                                isGridSelected = false
                            }
                        } label: {
                            Label("Lista", systemImage: !isGridSelected ? "checkmark" : "list.bullet")
                        }
                    }
                } label: {
                    Label("Opciones", systemImage: "ellipsis")
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mangaGridContent: some View {
        ForEach(mangas) { manga in
            NavigationLink(value: manga) {
                MainPictureView(picture: manga.mainPicture, namespace: namespace)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var mangaListContent: some View {
        ForEach(mangas) { manga in
            NavigationLink(value: manga) {
                MangaRow(manga: manga, namespace: namespace)
            }
            .swipeActions {
                Button {
                    onToggleFavorite(manga)
                } label: {
                    let isFavorite = favoritesIDs.contains(manga.id)
                    Label(isFavorite ? "Quitar" : "Añadir",
                          systemImage: isFavorite ? "heart.slash" : "heart.fill")
                }
                .tint(.red)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    NavigationStack {
        MangaGridListView(
            mangas: Manga.sampleMangas,
            favoritesIDs: [],
            namespace: namespace,
            onToggleFavorite: { _ in }
        )
    }
}

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
    let showProgressView: Bool
    let onProgressViewAppear: (() -> Void)?
    
    @State private var isGridSelected = true
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            Group {
                if isGridSelected {
                    LazyVGrid(columns: columns, spacing: 12) {
                        mangaGridContent
                    }
                    .padding(.horizontal, 4)
                } else {
                    LazyVStack {
                        mangaListContent
                    }
                    .safeAreaPadding()
                }
                
                if showProgressView {
                    ProgressView()
                        .onAppear {
                            onProgressViewAppear?()
                        }
                }
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
            let isFavorite = favoritesIDs.contains(manga.id)
            
            NavigationLink(value: manga) {
                MangaGridView(manga: manga, namespace: namespace)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button {
                    onToggleFavorite(manga)
                } label: {
                    Label(isFavorite ? "Quitar de favoritos" : "Añadir a favoritos",
                          systemImage: isFavorite ? "heart.slash" : "heart.fill")
                }
            }
        }
    }
    
    private var mangaListContent: some View {
        ForEach(mangas) { manga in
            let isFavorite = favoritesIDs.contains(manga.id)
            
            NavigationLink(value: manga) {
                MangaRow(manga: manga, namespace: namespace)
            }
            .buttonStyle(.plain)
            .swipeActions {
                Button {
                    onToggleFavorite(manga)
                } label: {
                    Label(isFavorite ? "Quitar" : "Añadir",
                          systemImage: isFavorite ? "heart.slash" : "heart.fill")
                }
                .tint(isFavorite ? .secondary : .red)
            }
        }
    }
}

// MARK: - Initializers

extension MangaGridListView {
    /// Inicializador completo con paginación
    init(
        mangas: [Manga],
        favoritesIDs: Set<Int>,
        namespace: Namespace.ID,
        onToggleFavorite: @escaping (Manga) -> Void,
        showProgressView: Bool,
        onProgressViewAppear: @escaping () -> Void
    ) {
        self.mangas = mangas
        self.favoritesIDs = favoritesIDs
        self.namespace = namespace
        self.onToggleFavorite = onToggleFavorite
        self.showProgressView = showProgressView
        self.onProgressViewAppear = onProgressViewAppear
    }
    
    /// Inicializador sin paginación (para Favoritos)
    init(
        mangas: [Manga],
        favoritesIDs: Set<Int>,
        namespace: Namespace.ID,
        onToggleFavorite: @escaping (Manga) -> Void
    ) {
        self.mangas = mangas
        self.favoritesIDs = favoritesIDs
        self.namespace = namespace
        self.onToggleFavorite = onToggleFavorite
        self.showProgressView = false
        self.onProgressViewAppear = nil
    }
}

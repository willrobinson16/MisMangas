//
//  MangaSwipeActionsModifier.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 22/2/26.
//

import SwiftUI

/// ViewModifier que añade swipe actions estándar para favoritos y colección
struct MangaSwipeActionsModifier: ViewModifier {
    let manga: Manga
    let isFavorite: Bool
    let isInCollection: Bool
    let favoritesVM: FavoritesViewModel
    let collectionVM: UserCollectionViewModel

    func body(content: Content) -> some View {
        content
            .swipeActions {
                Button {
                    favoritesVM.toggleFavorite(manga)
                } label: {
                    Label(isFavorite ? "Quitar" : "Añadir",
                          systemImage: isFavorite ? "heart.slash" : "heart.fill")
                }
                .tint(isFavorite ? .secondary : .red)
            }
            .swipeActions(edge: .leading) {
                Button {
                    collectionVM.toggleInCollection(manga)
                } label: {
                    Label(isInCollection ? "Quitar" : "Añadir",
                          systemImage: isInCollection ? "bookmark.slash.fill" : "bookmark.fill")
                }
                .tint(isInCollection ? .secondary : .blue)
            }
    }
}

extension View {
    /// Añade swipe actions para gestionar favoritos y colección de un manga
    /// - Parameters:
    ///   - manga: El manga al que aplicar las acciones
    ///   - isFavorite: Si el manga está en favoritos
    ///   - isInCollection: Si el manga está en la colección
    ///   - favoritesVM: ViewModel de favoritos
    ///   - collectionVM: ViewModel de colección
    func mangaSwipeActions(
        manga: Manga,
        isFavorite: Bool,
        isInCollection: Bool,
        favoritesVM: FavoritesViewModel,
        collectionVM: UserCollectionViewModel
    ) -> some View {
        modifier(MangaSwipeActionsModifier(
            manga: manga,
            isFavorite: isFavorite,
            isInCollection: isInCollection,
            favoritesVM: favoritesVM,
            collectionVM: collectionVM
        ))
    }
}

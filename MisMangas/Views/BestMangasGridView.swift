//
//  BestMangasGridView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 13/2/26.
//

import SwiftUI
import SwiftData

struct BestMangasGridView: View {
    @Environment(\.modelContext) var context

    /// Query de los mejores mangas, ordenados por score descendente
    /// Lee directamente desde SwiftData para carga instantánea
    @Query(sort: \Manga.score, order: .reverse) private var bestMangas: [Manga]

    /// ViewModel para gestionar la carga de páginas adicionales
    @State private var bestMangasVM = BestMangasViewModel()

    let namespace: Namespace.ID

    var body: some View {
            LazyHStack {
                ForEach(bestMangas) { manga in
                    NavigationLink(value: manga) {
                        MainPictureView(picture: manga.mainPicture, namespace: namespace)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 5)
                }

                // Indicador de carga para paginación
                if bestMangasVM.isLoading {
                    ProgressView()
                        .padding(.horizontal, 5)
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.leading)
            .scrollClipDisabled()
            .contentMargins(.horizontal, 30, for: .scrollContent)
            .onAppear {
                bestMangasVM.setModelContext(context)
            }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    BestMangasGridView(namespace: namespace)
}

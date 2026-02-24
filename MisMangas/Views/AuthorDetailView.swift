//
//  AuthorDetailView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import SwiftUI
import SwiftData

/// Vista de detalle de un autor de manga.
///
/// Muestra información del autor y lista todos los mangas en los que ha trabajado,
/// con su rol específico en cada manga.
///
/// ## Características:
/// - Header con nombre y rol del autor
/// - Lista paginada de mangas del autor
/// - Para cada manga: título y rol del autor en ese manga
/// - Pull-to-refresh para recargar
struct AuthorDetailView: View {
    let author: Author

    /// ViewModel para gestionar la carga de mangas del autor
    @State private var viewModel = AuthorDetailViewModel()

    var body: some View {
        List {
            // Header del autor
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(author.fullName)
                        .font(.largeTitle)
                        .bold()

                    HStack(spacing: 8) {
                        Image(systemName: author.role.iconFilled)
                            .foregroundStyle(author.role.color)
                        Text(author.role.rawValue)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
            }

            // Lista de mangas
            Section {
                if viewModel.mangas.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "Sin mangas",
                        systemImage: "books.vertical",
                        description: Text("Este autor aún no tiene mangas registrados")
                    )
                } else {
                    ForEach(viewModel.mangas) { mangaDTO in
                        MangaByAuthorRow(manga: mangaDTO, authorID: author.id)
                    }
                }

                // Indicador de carga
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } header: {
                if !viewModel.mangas.isEmpty {
                    Text("Mangas (\(viewModel.mangas.count))")
                }
            }

            // Error state
            if let errorMessage = viewModel.errorMessage {
                Section {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Autor")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.retry()
        }
        .task {
            await viewModel.loadMangasByAuthor(authorID: author.id)
        }
    }
}

#Preview {
    NavigationStack {
        AuthorDetailView(
            author: Author(
                id: UUID(),
                firstName: "Eiichiro",
                lastName: "Oda",
                role: .storyAndArt
            )
        )
    }
}

//
//  AuthorDetailViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 25/2/26.
//

import SwiftUI
import SwiftData

/// Vista de detalle de autor optimizada para iPad con grid layout.
///
/// Muestra información del autor y sus mangas en formato grid
/// para aprovechar el espacio de la pantalla del iPad.
///
/// ## Características:
/// - Header con info del autor
/// - Grid de mangas del autor
/// - Pull-to-refresh
/// - Acepta ViewModel externo opcional para compartir caché entre autores
struct AuthorDetailViewiPad: View {
    let author: Author

    /// ViewModel compartido o local para gestionar la carga de mangas del autor
    var viewModel: AuthorDetailViewModel

    @Namespace private var namespace

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header del autor
                authorHeader

                // Grid de mangas
                if viewModel.mangas.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "Sin mangas",
                        systemImage: "books.vertical",
                        description: Text("Este autor aún no tiene mangas registrados")
                    )
                    .frame(height: 300)
                } else {
                    mangasGrid
                }

                // Error state
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Autor")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.retry()
        }
        .task(id: author.id) {
            await viewModel.switchToAuthor(author.id)
        }
    }

    // MARK: - Author Header

    private var authorHeader: some View {
        HStack(spacing: 20) {
            // Ícono del autor
            ZStack {
                Circle()
                    .fill(author.role.color.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: author.role.iconFilled)
                    .font(.system(size: 40))
                    .foregroundStyle(author.role.color)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(author.fullName)
                    .font(.largeTitle.bold())

                HStack(spacing: 8) {
                    Image(systemName: author.role.iconFilled)
                        .foregroundStyle(author.role.color)
                    Text(author.role.rawValue)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.mangas.isEmpty {
                    Text("\(viewModel.mangas.count) mangas")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Mangas Grid

    private var mangasGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
        ], spacing: 20) {
            ForEach(viewModel.mangas) { mangaDTO in
                MangaByAuthorCard(manga: mangaDTO, authorID: author.id, namespace: namespace)
            }

            // Indicador de carga al final
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .gridCellColumns(2)
            }
        }
    }
}

// MARK: - Manga Card for Author Grid

/// Card para mostrar un manga en el grid de un autor
private struct MangaByAuthorCard: View {
    let manga: MangaDTO
    let authorID: UUID
    let namespace: Namespace.ID

    /// Busca el rol del autor en este manga específico
    private var authorRoleInManga: AuthorRole? {
        manga.authors.first { $0.id == authorID }?.role
    }

    var body: some View {
        VStack(spacing: 8) {
            // Imagen del manga
            AsyncImage(url: manga.mainPictureURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "book.closed")
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 3)

            VStack(spacing: 4) {
                // Título
                Text(manga.title)
                    .font(.caption.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)

                // Rol del autor
                if let role = authorRoleInManga {
                    HStack(spacing: 4) {
                        Image(systemName: role.icon)
                            .font(.caption2)
                            .foregroundStyle(role.color)

                        Text(role.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Score
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", manga.score))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

#Preview {
    NavigationStack {
        AuthorDetailViewiPad(
            author: Author(
                id: UUID(),
                firstName: "Eiichiro",
                lastName: "Oda",
                role: .storyAndArt
            ),
            viewModel: AuthorDetailViewModel()
        )
    }
}

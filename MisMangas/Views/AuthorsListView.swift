//
//  AuthorsListView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/2/26.
//

import SwiftUI
import SwiftData

/// Vista principal del listado de autores de manga.
///
/// Muestra una lista paginada de todos los autores almacenados en SwiftData,
/// ordenados alfabéticamente por apellido y nombre. Permite navegar a la vista
/// de detalle de cada autor para ver sus mangas.
///
/// ## Características:
/// - Carga datos desde SwiftData (instantánea)
/// - Paginación gestionada por AuthorsViewModel
/// - Navegación a AuthorDetailView
/// - Pull-to-refresh para recargar
struct AuthorsListView: View {
    @Environment(\.modelContext) var context

    /// Query de autores, ordenados alfabéticamente
    @Query(sort: [SortDescriptor(\Author.lastName), SortDescriptor(\Author.firstName)])
    private var authors: [Author]

    /// ViewModel para gestionar la paginación
    @State private var authorsVM = AuthorsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(authors) { author in
                    NavigationLink(value: author) {
                        AuthorRow(author: author)
                    }
                }

                // Indicador de carga al final de la lista - carga siguiente página
                if authors.count > 0 {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await authorsVM.loadNextPage()
                        }
                    }
                }

                // Error state
                if let errorMessage = authorsVM.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Autores")
            .navigationDestination(for: Author.self) { author in
                AuthorDetailView(author: author)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .refreshable {
                // Resetear y recargar autores desde la página 1
                await authorsVM.resetAndReload()
            }
            .onAppear {
                authorsVM.setModelContext(context)
                // Cargar primera página si no hay autores
                if authors.isEmpty {
                    Task {
                        await authorsVM.loadNextPage()
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    AuthorsListView()
        .modelContainer(for: Author.self)
}

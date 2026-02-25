//
//  AuthorsListViewiPad.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI
import SwiftData

/// Vista de autores para iPad con NavigationSplitView.
///
/// Muestra una lista de autores en el sidebar y los mangas del autor
/// seleccionado en el panel de detalle.
///
/// ## Características:
/// - Sidebar: Lista alfabética de autores
/// - Detail: AuthorDetailView con mangas del autor seleccionado
/// - Paginación integrada
/// - Pull-to-refresh
struct AuthorsListViewiPad: View {
    @Environment(\.modelContext) var context

    /// Query de autores, ordenados alfabéticamente
    @Query(sort: [SortDescriptor(\Author.lastName), SortDescriptor(\Author.firstName)])
    private var authors: [Author]

    /// ViewModel para gestionar la paginación
    @State private var authorsVM = AuthorsViewModel()

    /// ViewModel compartido para detalles de autores (caché eficiente)
    @State private var authorDetailVM = AuthorDetailViewModel()

    /// Autor seleccionado en el sidebar
    @State private var selectedAuthor: Author?

    var body: some View {
        NavigationSplitView {
            // Sidebar: Lista de autores
            List(selection: $selectedAuthor) {
                ForEach(authors) { author in
                    Text(author.fullName)
                        .font(.headline)
                        .tag(author)
                }

                // Paginación
                if !authors.isEmpty {
                    paginationIndicator
                }

                // Error state
                errorView
            }
            .navigationTitle("Autores")
            .refreshable {
                await authorsVM.resetAndReload()
            }
        } detail: {
            // Detail: Mangas del autor seleccionado
            if let selectedAuthor {
                AuthorDetailView(author: selectedAuthor, viewModel: authorDetailVM)
            } else {
                ContentUnavailableView(
                    "Selecciona un autor",
                    systemImage: "person.crop.circle",
                    description: Text("Elige un autor del panel izquierdo para ver sus mangas.")
                )
            }
        }
        .onAppear {
            setupViewModel()
        }
    }

    // MARK: - Shared Components

    /// Indicador de paginación (carga siguiente página)
    private var paginationIndicator: some View {
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

    /// Vista de error
    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = authorsVM.errorMessage {
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        }
    }

    /// Configuración inicial del ViewModel
    private func setupViewModel() {
        authorsVM.setModelContext(context)
        if authors.isEmpty {
            Task {
                await authorsVM.loadNextPage()
            }
        }
    }
}

#Preview(traits: .sampleData) {
    AuthorsListViewiPad()
        .modelContainer(for: Author.self)
}

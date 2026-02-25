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
/// - **Adaptativa**: NavigationSplitView en iPad, NavigationStack en iPhone
struct AuthorsListView: View {
    @Environment(\.modelContext) var context

    /// Query de autores, ordenados alfabéticamente
    @Query(sort: [SortDescriptor(\Author.lastName), SortDescriptor(\Author.firstName)])
    private var authors: [Author]

    /// ViewModel para gestionar la paginación
    @State private var authorsVM = AuthorsViewModel()

    /// ViewModel compartido para detalles de autores (caché eficiente)
    @State private var authorDetailVM = AuthorDetailViewModel()

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: NavigationSplitView
            AuthorsListViewiPad()
        } else {
            // iPhone: NavigationStack
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        NavigationStack {
            List {
                ForEach(authors) { author in
                    NavigationLink(value: author) {
                        AuthorRow(author: author)
                    }
                }

                // Paginación
                if !authors.isEmpty {
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
                AuthorDetailView(author: author, viewModel: authorDetailVM)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .refreshable {
                await authorsVM.resetAndReload()
            }
            .task {
                authorsVM.setModelContext(context)

                // Cargar datos si la base de datos está vacía
                let descriptor = FetchDescriptor<Author>()
                if let count = try? context.fetchCount(descriptor), count == 0 {
                    print("📦 Base de datos de autores vacía, cargando datos iniciales...")
                    let modelContainer = DataContainer(modelContainer: context.container)
                    do {
                        try await modelContainer.loadInitialData()
                        print("✅ Datos de autores cargados correctamente")
                    } catch {
                        print("❌ Error cargando datos de autores: \(error)")
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

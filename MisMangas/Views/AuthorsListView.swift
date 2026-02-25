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
                let descriptorMangas = FetchDescriptor<Manga>()
                if let count = try? context.fetchCount(descriptorMangas), count == 0 {
                    print("📦 Base de datos vacía, cargando datos desde AuthorsListView...")
                    do {
                        // Cargar mangas directamente desde la API usando el context actual
                        let network = Network()
                        let mangasPage = try await network.getMangasPage(page: 1)
                        let bestMangasPage = try await network.getBestMangasPage(page: 1)

                        // Combinar ambos resultados
                        let allMangas = mangasPage.items + bestMangasPage.items

                        // Guardar en SwiftData usando el context de la vista
                        try insertOrUpdateMangas(in: context, from: allMangas)

                        print("✅ Datos cargados correctamente desde AuthorsListView (\(allMangas.count) mangas)")
                    } catch {
                        print("❌ Error cargando datos desde AuthorsListView: \(error)")
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

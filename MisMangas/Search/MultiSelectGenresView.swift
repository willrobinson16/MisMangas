//
//  MultiSelectGenresView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI

/// Vista para seleccionar múltiples géneros con checkmarks
struct MultiSelectGenresView: View {
    @Binding var selectedGenres: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    let network = Network()
    @State private var genres: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Cargando géneros...")
                } else if genres.isEmpty {
                    ContentUnavailableView(
                        "Sin géneros",
                        systemImage: "tag",
                        description: Text("No se pudieron cargar los géneros")
                    )
                } else {
                    List(genres, id: \.self) { genre in
                        Button {
                            toggleSelection(genre)
                        } label: {
                            HStack {
                                Text(genre)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedGenres.contains(genre) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Géneros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .task {
                await loadGenres()
            }
        }
    }

    private func toggleSelection(_ genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }

    private func loadGenres() async {
        do {
            genres = try await network.getGenres()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = ["Action", "Adventure"]
    MultiSelectGenresView(selectedGenres: $selected)
}

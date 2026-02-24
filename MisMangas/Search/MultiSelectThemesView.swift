//
//  MultiSelectThemesView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI

/// Vista para seleccionar múltiples temas con checkmarks
struct MultiSelectThemesView: View {
    @Binding var selectedThemes: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    let network = Network()
    @State private var themes: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Cargando temas...")
                } else if themes.isEmpty {
                    ContentUnavailableView(
                        "Sin temas",
                        systemImage: "tag",
                        description: Text("No se pudieron cargar los temas")
                    )
                } else {
                    List(themes, id: \.self) { theme in
                        Button {
                            toggleSelection(theme)
                        } label: {
                            HStack {
                                Text(theme)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedThemes.contains(theme) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Temas")
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
                await loadThemes()
            }
        }
    }

    private func toggleSelection(_ theme: String) {
        if selectedThemes.contains(theme) {
            selectedThemes.remove(theme)
        } else {
            selectedThemes.insert(theme)
        }
    }

    private func loadThemes() async {
        do {
            themes = try await network.getThemes()
            isLoading = false
        } catch {
            print("❌ Error cargando temas: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = ["Adventure", "Fantasy"]
    MultiSelectThemesView(selectedThemes: $selected)
}

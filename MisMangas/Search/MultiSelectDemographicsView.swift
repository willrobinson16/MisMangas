//
//  MultiSelectDemographicsView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI

/// Vista para seleccionar múltiples demografías con checkmarks
struct MultiSelectDemographicsView: View {
    @Binding var selectedDemographics: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    let network = Network()
    @State private var demographics: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Cargando demografías...")
                } else if demographics.isEmpty {
                    ContentUnavailableView(
                        "Sin demografías",
                        systemImage: "person.3",
                        description: Text("No se pudieron cargar las demografías")
                    )
                } else {
                    List(demographics, id: \.self) { demographic in
                        Button {
                            toggleSelection(demographic)
                        } label: {
                            HStack {
                                Text(demographic)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedDemographics.contains(demographic) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Demografías")
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
                await loadDemographics()
            }
        }
    }

    private func toggleSelection(_ demographic: String) {
        if selectedDemographics.contains(demographic) {
            selectedDemographics.remove(demographic)
        } else {
            selectedDemographics.insert(demographic)
        }
    }

    private func loadDemographics() async {
        do {
            demographics = try await network.getDemographics()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = ["Shounen", "Seinen"]
    MultiSelectDemographicsView(selectedDemographics: $selected)
}

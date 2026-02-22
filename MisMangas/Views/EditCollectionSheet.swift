//
//  EditCollectionSheet.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import SwiftUI
import SwiftData

/// Sheet para editar una entrada de la colección del usuario
struct EditCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var entry: UserMangaCollection
    let manga: Manga
    let collectionVM: UserCollectionViewModel

    @State private var newVolumeNumber: String = ""
    @State private var showValidationError: Bool = false
    @State private var currentReadingVolume: Int = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                // Información del manga
                mangaInfoSection

                // Progreso de lectura
                readingProgressSection

                // Volúmenes poseídos
                volumesOwnedSection

                // Estadísticas
                statisticsSection
            }
            .onAppear {
                collectionVM.setModelContext(modelContext)
                currentReadingVolume = entry.readingVolume ?? 0
            }
            .navigationTitle("Editar Colección")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
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
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Listo") {
                        isTextFieldFocused = false
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Manga Info Section

    private var mangaInfoSection: some View {
        Section("Manga") {
            HStack {
                Text(manga.title)
                    .font(.headline)
                Spacer()
                if let volumes = manga.volumes {
                    Text("\(volumes) vol.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Reading Progress Section

    private var readingProgressSection: some View {
        Section("Progreso de Lectura") {
            Picker("Volumen actual", selection: $currentReadingVolume) {
                Text("No iniciado").tag(0)
                ForEach(availableVolumes, id: \.self) { volume in
                    Text("Vol. \(volume)").tag(volume)
                }
            }
            .onChange(of: currentReadingVolume) { _, newValue in
                collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: newValue == 0 ? nil : newValue)
            }

            if let readingVolume = entry.readingVolume,
               readingVolume > 0,
               let totalVolumes = totalVolumesForProgress, totalVolumes > 0 {
                let progress = min(Double(readingVolume) / Double(totalVolumes), 1.0)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: progress)
                }
            }

            Button {
                collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: nil)
                currentReadingVolume = 0
            } label: {
                Label("Reiniciar lectura", systemImage: "arrow.counterclockwise")
            }
            .disabled(currentReadingVolume == 0)
        }
    }

    // MARK: - Volumes Owned Section

    private var volumesOwnedSection: some View {
        Section("Volúmenes en Posesión") {
            Toggle("Colección completa", isOn: Binding(
                get: { entry.completeCollection },
                set: { collectionVM.setCompleteCollection(mangaID: entry.mangaID, isComplete: $0) }
            ))

            if !entry.completeCollection {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Número de volumen", text: $newVolumeNumber)
                            .keyboardType(.numberPad)
                            .focused($isTextFieldFocused)
                            .onChange(of: newVolumeNumber) { _, _ in
                                showValidationError = false
                            }

                        Button("Añadir") {
                            if let volumeNumber = Int(newVolumeNumber) {
                                if isValidVolume(volumeNumber) {
                                    collectionVM.addVolume(mangaID: entry.mangaID, volumeNumber: volumeNumber)
                                    newVolumeNumber = ""
                                    isTextFieldFocused = false
                                    showValidationError = false
                                } else {
                                    showValidationError = true
                                }
                            }
                        }
                        .disabled(newVolumeNumber.isEmpty)
                    }

                    if showValidationError {
                        Text("El volumen debe estar entre 1 y \(manga.volumes ?? 999)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    let volumes = entry.volumesOwned
                    if !volumes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(volumes.sorted(), id: \.self) { volume in
                                    VolumeChip(
                                        volumeNumber: volume,
                                        onRemove: {
                                            collectionVM.removeVolume(mangaID: entry.mangaID, volumeNumber: volume)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    } else {
                        Text("No has añadido volúmenes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        Section("Estadísticas") {
            LabeledContent("Volúmenes poseídos", value: entry.completeCollection ? "\(manga.volumes ?? 0)" : "\(entry.volumesOwnedCount)")
            LabeledContent("Fecha de añadido", value: entry.dateAdded.formatted(date: .abbreviated, time: .omitted))
            LabeledContent("Última actualización", value: entry.lastUpdated.formatted(date: .abbreviated, time: .omitted))
        }
    }

    // MARK: - Helper Functions

    /// Valida que el volumen esté en el rango válido (1 a totalVolumes)
    private func isValidVolume(_ volume: Int) -> Bool {
        guard volume >= 1 else { return false }

        if let totalVolumes = manga.volumes {
            return volume <= totalVolumes
        }

        // Si no se conoce el total, permitir hasta 999
        return volume <= 999
    }

    // MARK: - Computed Properties

    /// Volúmenes disponibles para seleccionar en el Picker
    private var availableVolumes: [Int] {
        if entry.completeCollection {
            // Colección completa: todos los volúmenes del manga
            if let totalVolumes = manga.volumes {
                return Array(1...totalVolumes)
            }
            // Si no se conoce el total, permitir hasta 100
            return Array(1...100)
        } else {
            // Solo volúmenes en posesión
            let ownedVolumes = entry.volumesOwned
            if !ownedVolumes.isEmpty {
                return ownedVolumes.sorted()
            }
            // Si no hay volúmenes especificados pero hay total del manga, usar ese límite
            if let totalVolumes = manga.volumes {
                return Array(1...totalVolumes)
            }
            // Por defecto, permitir hasta 50 volúmenes
            return Array(1...50)
        }
    }

    /// Total de volúmenes para calcular el progreso
    private var totalVolumesForProgress: Int? {
        if entry.completeCollection {
            return manga.volumes
        } else {
            let ownedVolumes = entry.volumesOwned
            if !ownedVolumes.isEmpty {
                return ownedVolumes.max()
            }
            return manga.volumes
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @State var collectionVM = UserCollectionViewModel()

    EditCollectionSheet(
        entry: .test,
        manga: .test,
        collectionVM: collectionVM
    )
}

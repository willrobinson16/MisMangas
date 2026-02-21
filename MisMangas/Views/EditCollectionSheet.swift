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

    let entry: UserMangaCollection
    let manga: Manga
    let collectionVM: UserCollectionViewModel

    @State private var newVolumeNumber: String = ""

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
            }
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
            Picker("Volumen actual", selection: Binding(
                get: { entry.readingVolume ?? 0 },
                set: { newValue in
                    collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: newValue == 0 ? nil : newValue)
                }
            )) {
                Text("No iniciado").tag(0)
                ForEach(availableVolumes, id: \.self) { volume in
                    Text("Vol. \(volume)").tag(volume)
                }
            }

            if let readingVolume = entry.readingVolume,
               readingVolume > 0,
               let totalVolumes = totalVolumesForProgress {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int((Double(readingVolume) / Double(totalVolumes)) * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(readingVolume), total: Double(totalVolumes))
                }
            }

            Button {
                collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: nil)
            } label: {
                Label("Reiniciar lectura", systemImage: "arrow.counterclockwise")
            }
            .disabled(entry.readingVolume == nil)
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

                        Button("Añadir") {
                            if let volumeNumber = Int(newVolumeNumber) {
                                collectionVM.addVolume(mangaID: entry.mangaID, volumeNumber: volumeNumber)
                                newVolumeNumber = ""
                            }
                        }
                        .disabled(newVolumeNumber.isEmpty)
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

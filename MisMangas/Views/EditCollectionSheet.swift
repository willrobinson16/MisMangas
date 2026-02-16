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
                    Button("Cerrar") {
                        dismiss()
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
            HStack {
                Text("Volumen actual:")
                Spacer()

                Button {
                    collectionVM.decrementReadingVolume(mangaID: entry.mangaID)
                } label: {
                    Image(systemName: "minus.circle")
                }
                .disabled((entry.readingVolume ?? 0) == 0)

                Text("\(entry.readingVolume ?? 0)")
                    .font(.headline)
                    .frame(minWidth: 30)

                Button {
                    collectionVM.incrementReadingVolume(mangaID: entry.mangaID)
                } label: {
                    Image(systemName: "plus.circle")
                }
                .disabled(!canIncreaseReadingVolume)
            }

            if let readingVolume = entry.readingVolume,
               readingVolume > 0,
               let totalVolumes = manga.volumes {
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
            LabeledContent("Volúmenes poseídos", value: entry.completeCollection ? "\(manga.volumes ?? 0)": "\(entry.volumesOwnedCount)")
            LabeledContent("Fecha de añadido", value: entry.dateAdded.formatted(date: .abbreviated, time: .omitted))
            LabeledContent("Última actualización", value: entry.lastUpdated.formatted(date: .abbreviated, time: .omitted))
        }
    }

    // MARK: - Computed Properties

    private var canIncreaseReadingVolume: Bool {
        let currentVolume = entry.readingVolume ?? 0

        if entry.completeCollection {
            if let totalVolumes = manga.volumes {
                return currentVolume < totalVolumes
            }
            return true
        }

        let ownedVolumes = entry.volumesOwned
        if ownedVolumes.isEmpty {
            return false
        }

        let maxOwnedVolume = ownedVolumes.max() ?? 0
        return currentVolume < maxOwnedVolume
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

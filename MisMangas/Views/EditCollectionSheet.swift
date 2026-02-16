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

    @Bindable var collection: UserMangaCollection
    
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

                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") {
                        saveChanges()
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
                    if let current = collection.readingVolume, current > 0 {
                        collection.readingVolume = current - 1
                    } else if collection.readingVolume == 0 {
                        collection.readingVolume = nil
                    }
                } label: {
                    Image(systemName: "minus.circle")
                }
                .disabled(collection.readingVolume == nil || collection.readingVolume == 0)

                Text("\(collection.readingVolume ?? 0)")
                    .font(.headline)
                    .frame(minWidth: 30)

                Button {
                    if let current = collection.readingVolume {
                        collection.readingVolume = current + 1
                    } else {
                        collection.readingVolume = 1
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
                .disabled(
                    manga.volumes != nil &&
                    (collection.readingVolume ?? 0) >= manga.volumes!
                )
            }

            if let readingVolume = collection.readingVolume,
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
                collection.readingVolume = nil
            } label: {
                Label("Reiniciar lectura", systemImage: "arrow.counterclockwise")
            }
            .disabled(collection.readingVolume == nil)
        }
    }

    // MARK: - Volumes Owned Section

    private var volumesOwnedSection: some View {
        Section("Volúmenes en Posesión") {
            Toggle("Colección completa", isOn: $collection.completeCollection)

            if !collection.completeCollection {
                VStack(alignment: .leading, spacing: 8) {
                    // Añadir volumen
                    HStack {
                        TextField("Número de volumen", text: $newVolumeNumber)
                            .keyboardType(.numberPad)

                        Button("Añadir") {
                            addVolume()
                        }
                        .disabled(newVolumeNumber.isEmpty)
                    }

                    // Lista de volúmenes
                    let volumes = collection.volumesOwned
                    if !volumes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(volumes.sorted(), id: \.self) { volume in
                                    VolumeChip(
                                        volumeNumber: volume,
                                        onRemove: {
                                            collection.removeVolume(volume)
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
            LabeledContent("Volúmenes poseídos", value: collection.completeCollection ? "\(manga.volumes ?? 0)": "\(collection.volumesOwnedCount)")
            LabeledContent("Fecha de añadido", value: collection.dateAdded.formatted(date: .abbreviated, time: .omitted))
            LabeledContent("Última actualización", value: collection.lastUpdated.formatted(date: .abbreviated, time: .omitted))
        }
    }

    // MARK: - Actions

    private func addVolume() {
        guard let volumeNumber = Int(newVolumeNumber) else { return }
        collection.addVolume(volumeNumber)
        newVolumeNumber = ""
    }

    private func saveChanges() {
        // Actualizar timestamp
        collection.lastUpdated = Date()
    }
}

#Preview(traits: .sampleData) {
    @Previewable @State var collectionVM = UserCollectionViewModel()

    EditCollectionSheet(
        collection: .test,
        manga: .test,
        collectionVM: collectionVM
    )
}

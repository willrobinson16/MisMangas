//
//  AdvancedSearchFiltersSheet.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI

/// Sheet con todos los filtros avanzados de búsqueda
struct AdvancedSearchFiltersSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showGenresSelector = false
    @State private var showThemesSelector = false
    @State private var showDemographicsSelector = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Autor
                Section("Autor") {
                    TextField("Nombre", text: $viewModel.authorFirstName)
                        .autocorrectionDisabled()
                    
                    TextField("Apellido", text: $viewModel.authorLastName)
                        .autocorrectionDisabled()
                }
                
                // MARK: - Géneros
                Section {
                    Button {
                        showGenresSelector = true
                    } label: {
                        HStack {
                            Label("Géneros", systemImage: "theatermasks")
                                .foregroundStyle(.primary)
                            Spacer()
                            if !viewModel.selectedGenres.isEmpty {
                                Text("\(viewModel.selectedGenres.count)")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !viewModel.selectedGenres.isEmpty {
                        ForEach(Array(viewModel.selectedGenres), id: \.self) { genre in
                            HStack {
                                Text(genre)
                                    .font(.subheadline)
                                Spacer()
                                Button {
                                    viewModel.selectedGenres.remove(genre)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // MARK: - Temas
                Section {
                    Button {
                        showThemesSelector = true
                    } label: {
                        HStack {
                            Label("Temas", systemImage: "tag")
                                .foregroundStyle(.primary)
                            Spacer()
                            if !viewModel.selectedThemes.isEmpty {
                                Text("\(viewModel.selectedThemes.count)")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !viewModel.selectedThemes.isEmpty {
                        ForEach(Array(viewModel.selectedThemes), id: \.self) { theme in
                            HStack {
                                Text(theme)
                                    .font(.subheadline)
                                Spacer()
                                Button {
                                    viewModel.selectedThemes.remove(theme)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // MARK: - Demografía
                Section {
                    Button {
                        showDemographicsSelector = true
                    } label: {
                        HStack {
                            Label("Demografía", systemImage: "person.3")
                                .foregroundStyle(.primary)
                            Spacer()
                            if !viewModel.selectedDemographics.isEmpty {
                                Text("\(viewModel.selectedDemographics.count)")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !viewModel.selectedDemographics.isEmpty {
                        ForEach(Array(viewModel.selectedDemographics), id: \.self) { demo in
                            HStack {
                                Text(demo)
                                    .font(.subheadline)
                                Spacer()
                                Button {
                                    viewModel.selectedDemographics.remove(demo)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // MARK: - Tipo de búsqueda
                Section {
                    Toggle(isOn: $viewModel.useContains) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Búsqueda flexible")
                                .font(.body)
                            Text(viewModel.useContains ? "Busca cualquier coincidencia" : "Busca desde el inicio")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Opciones de búsqueda")
                } footer: {
                    Text("Activo: encuentra títulos que contengan el texto en cualquier posición. Desactivado: solo encuentra títulos que comiencen con el texto.")
                }
            }
            .navigationTitle("Filtros Avanzados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        Task {
                            await viewModel.performSearch()
                        }
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGenresSelector) {
                MultiSelectGenresView(selectedGenres: $viewModel.selectedGenres)
            }
            .sheet(isPresented: $showThemesSelector) {
                MultiSelectThemesView(selectedThemes: $viewModel.selectedThemes)
            }
            .sheet(isPresented: $showDemographicsSelector) {
                MultiSelectDemographicsView(selectedDemographics: $viewModel.selectedDemographics)
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = SearchViewModel()
    AdvancedSearchFiltersSheet(viewModel: viewModel)
}

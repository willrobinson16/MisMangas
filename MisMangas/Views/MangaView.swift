//
//  MangaView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI
import SwiftData

struct MangaView: View {
    let manga: Manga
    let namespace: Namespace.ID

    @Environment(FavoritesViewModel.self) private var favoritesVM
    @Environment(UserCollectionViewModel.self) private var collectionVM
    @Environment(\.openURL) private var openURL

    @State private var mainPictureVM = MainPictureVM()
    @State private var isSynopsisExpanded = false

    @Query private var favoriteMangas: [FavoriteManga]
    @Query private var userCollection: [UserMangaCollection]

    private var isFavorite: Bool {
        favoriteMangas.contains { $0.id == manga.id }
    }

    private var isInCollection: Bool {
        userCollection.contains { $0.mangaID == manga.id }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Hero Image Header
                heroImageHeader

                // MARK: - Content
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    titleSection

                    // Action Buttons
                    actionButtons

                    // Rating Card
                    ratingCard

                    // Quick Info Grid
                    quickInfoGrid

                    // Synopsis
                    synopsisSection

                    // Authors
                    if !manga.authors.isEmpty {
                        authorsSection
                    }

                    // Genres
                    if !manga.genres.isEmpty {
                        genresSection
                    }

                    // Themes
                    if !manga.themes.isEmpty {
                        themesSection
                    }

                    // Demographics
                    if !manga.demographics.isEmpty {
                        demographicsSection
                    }

                    // Dates & Status
                    datesSection

                    // External Link
                    if manga.url != nil {
                        externalLinkButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            mainPictureVM.getImage(mainPicture: manga.mainPicture)
        }
    }

    // MARK: - Hero Image Header

    private var heroImageHeader: some View {
        MainPictureView(picture: manga.mainPicture, namespace: namespace, big: true)
            .frame(height: 400)
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(manga.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            if let titleEnglish = manga.titleEnglish, !titleEnglish.isEmpty {
                Text(titleEnglish)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let titleJapanese = manga.titleJapanese, !titleJapanese.isEmpty {
                Text(titleJapanese)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Status badge
            HStack(spacing: 6) {
                Text("Status:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(formattedStatus)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                favoritesVM.toggleFavorite(manga)
            } label: {
                Label(
                    isFavorite ? "En Favoritos" : "Añadir a Favoritos",
                    systemImage: isFavorite ? "heart.fill" : "heart"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isFavorite ? .white : .red)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 12)
                .background(isFavorite ? Color.red : Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                collectionVM.toggleInCollection(manga)
            } label: {
                Label(
                    isInCollection ? "En Colección" : "Añadir a Colección",
                    systemImage: isInCollection ? "books.vertical.fill" : "books.vertical"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isInCollection ? .white : .blue)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 12)
                .background(isInCollection ? Color.blue : Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Rating Card

    private var ratingCard: some View {
        HStack {
            Spacer()
            RatingView(rating: manga.score)
            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Info Grid

    private var quickInfoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            if let chapters = manga.chapters {
                InfoCard(icon: "book.pages", title: "Capítulos", value: "\(chapters)")
            }

            if let volumes = manga.volumes {
                InfoCard(icon: "books.vertical", title: "Volúmenes", value: "\(volumes)")
            }
        }
    }

    // MARK: - Synopsis Section

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sinopsis")
                .font(.title3.bold())

            if let synopsis = manga.synopsis, !synopsis.isEmpty {
                Text(synopsis)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(isSynopsisExpanded ? nil : 5)

                Button {
                    withAnimation {
                        isSynopsisExpanded.toggle()
                    }
                } label: {
                    Text(isSynopsisExpanded ? "Ver menos" : "Ver más")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            } else if let background = manga.background {
                Text(background)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(isSynopsisExpanded ? nil : 5)

                Button {
                    withAnimation {
                        isSynopsisExpanded.toggle()
                    }
                } label: {
                    Text(isSynopsisExpanded ? "Ver menos" : "Ver más")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            } else {
                Text("No hay sinopsis disponible")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Authors Section

    private var authorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Autores")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 8) {
                ForEach(manga.authors) { author in
                    HStack(spacing: 12) {
                        Image(systemName: author.role.iconFilled)
                            .foregroundStyle(author.role.color)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(author.fullName)
                                .font(.body.weight(.medium))
                            Text(author.role.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Genres Section

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Géneros")
                .font(.title3.bold())

            FlowLayout(spacing: 8) {
                ForEach(manga.genres) { genre in
                    Text(genre.genre)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.purple)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Themes Section

    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temas")
                .font(.title3.bold())

            FlowLayout(spacing: 8) {
                ForEach(manga.themes) { theme in
                    Text(theme.theme)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Demographics Section

    private var demographicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Demografía")
                .font(.title3.bold())

            FlowLayout(spacing: 8) {
                ForEach(manga.demographics) { demographic in
                    Text(demographic.demographic)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Dates Section

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información de Publicación")
                .font(.title3.bold())

            VStack(spacing: 12) {
                if let startDate = manga.startDate {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundStyle(.green)
                            .frame(width: 30)
                        Text("Inicio:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(startDate.formattedDate)
                            .font(.subheadline.weight(.medium))
                    }
                }

                if let endDate = manga.endDate {
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundStyle(.red)
                            .frame(width: 30)
                        Text("Fin:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(endDate.formattedDate)
                            .font(.subheadline.weight(.medium))
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - External Link Button

    private var externalLinkButton: some View {
        Button {
            if let url = manga.url {
                openURL(url)
            }
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                Text("Ver en MyAnimeList")
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(16)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Helpers

    /// Formatea el status del manga: "currently_publishing" → "Currently Publishing"
    private var formattedStatus: String {
        manga.status
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private var statusColor: Color {
        switch manga.status.lowercased() {
        case "finished": return .green
        case "publishing", "currently_publishing": return .blue
        case "on_hiatus": return .orange
        case "discontinued": return .red
        default: return .gray
        }
    }
}

// MARK: - Info Card Component

private struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Flow Layout for Tags

/// Layout personalizado que organiza vistas en múltiples líneas (flow layout)
///
/// Similar a cómo se comportan las palabras en un párrafo: cuando una vista no cabe
/// en la línea actual, automáticamente baja a la siguiente línea.
///
/// ## Uso:
/// ```swift
/// FlowLayout(spacing: 8) {
///     ForEach(items) { item in
///         Text(item.name)
///             .padding()
///             .background(Color.blue)
///             .clipShape(Capsule())
///     }
/// }
/// ```
///
/// ## Características:
/// - Las vistas se colocan de izquierda a derecha
/// - Cuando no hay espacio, saltan a la siguiente línea
/// - Respeta el spacing entre elementos horizontal y verticalmente
/// - Calcula automáticamente la altura total necesaria
///
/// - Parameter spacing: Espacio entre elementos (horizontal y vertical)
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    /// Calcula el tamaño total que ocupará el layout
    ///
    /// - Parameters:
    ///   - proposal: Tamaño propuesto por el contenedor padre
    ///   - subviews: Vistas hijas a organizar
    ///   - cache: Caché (no usado en esta implementación)
    /// - Returns: Tamaño total calculado del layout
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.bounds
    }

    /// Posiciona cada subview en su ubicación calculada
    ///
    /// - Parameters:
    ///   - bounds: Rectángulo donde colocar las vistas
    ///   - proposal: Tamaño propuesto por el contenedor padre
    ///   - subviews: Vistas hijas a posicionar
    ///   - cache: Caché (no usado en esta implementación)
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    /// Estructura auxiliar que calcula las posiciones de las vistas en el flow layout
    ///
    /// Itera por todas las subviews y calcula:
    /// 1. Si caben en la línea actual (basado en maxWidth)
    /// 2. Si no caben, salta a la siguiente línea (incrementa y)
    /// 3. Guarda la posición de cada vista en el array `frames`
    struct FlowResult {
        /// Tamaño total calculado del layout (ancho máximo x altura total)
        var bounds = CGSize.zero

        /// Array de rectángulos con la posición de cada subview
        var frames: [CGRect] = []

        /// Calcula el layout flow completo
        ///
        /// - Parameters:
        ///   - maxWidth: Ancho máximo disponible (ancho del contenedor)
        ///   - subviews: Vistas a organizar
        ///   - spacing: Espacio entre elementos
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0          // Posición horizontal actual
            var y: CGFloat = 0          // Posición vertical actual (línea actual)
            var lineHeight: CGFloat = 0 // Altura de la línea actual

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                // Si la vista no cabe en la línea actual, bajar a la siguiente
                if x + size.width > maxWidth && x > 0 {
                    x = 0                       // Volver al inicio de la línea
                    y += lineHeight + spacing   // Bajar a la siguiente línea
                    lineHeight = 0              // Resetear altura de línea
                }

                // Guardar la posición de esta vista
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))

                // Actualizar altura de la línea (tomar la más alta)
                lineHeight = max(lineHeight, size.height)

                // Avanzar posición horizontal para la siguiente vista
                x += size.width + spacing
            }

            // Calcular tamaño total del layout
            bounds = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    MangaView(manga: .test, namespace: namespace)
        .environment(FavoritesViewModel())
        .environment(UserCollectionViewModel())
        .modelContainer(for: FavoriteManga.self)
}

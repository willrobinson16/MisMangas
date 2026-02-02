struct MangaGridView: View {
    let mangas: [Manga]
    let namespace: Namespace.ID

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(mangas) { manga in
                // Ajusta el nombre de la propiedad de portada si es necesario
                if let portada = manga.portadaURL {
                    AsyncImage(url: portada) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
        .padding()
    }
}
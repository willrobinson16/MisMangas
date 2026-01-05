//
//  MangaRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI

struct MangaRow: View {
    let manga: Manga
    let namespace: Namespace.ID
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(manga.title)
                    .font(.title3)
                    .bold()
                if let titleJapanese = manga.titleJapanese {
                    Text(titleJapanese)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(manga.authorsString)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let startDate = manga.startDate {
                    Text(startDate.prefix(4))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            MainPictureView(picture: manga.mainPicture, namespace: namespace)
        }
        .padding()
        .background(.green.opacity(0.3), in: .rect(cornerRadius: 35))
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    MangaRow(manga: .test, namespace: namespace)
}

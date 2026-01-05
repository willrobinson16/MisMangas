//
//  MangaView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI

struct MangaView: View {
    let manga: Manga
    let namespace: Namespace.ID
    
    @State private var mainPictureVM = MainPictureVM()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let image = mainPictureVM.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .stretchy()
                }
//                MainPictureView(picture: manga.mainPicture, namespace: namespace, big: true)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
                VStack(alignment: .leading, spacing: 10) {
                    Text(manga.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(manga.authorsString)
                        .font(.title)
                        .foregroundStyle(.secondary)
                    
                    if let chapters = manga.chapters {
                        Text("Capítulos: \(chapters)")
                    }
                    
                    if let volumes = manga.volumes {
                        Text("Volúmenes: \(volumes)")
                    }
                    
                    if let background = manga.background {
                        Text(background)
                    }
                    
                    RatingView(rating: manga.score)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            mainPictureVM.getImage(mainPicture: manga.mainPicture)
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    NavigationStack {
        MangaView(manga: .test, namespace: namespace)
    }
}

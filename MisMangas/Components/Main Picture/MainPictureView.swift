//
//  PictureView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI

struct MainPictureView: View {
    let picture: URL?
    var big: Bool
    let namespace: Namespace.ID
    
    @State private var mainPictureVM = MainPictureVM()
    
    init(picture: URL?, namespace: Namespace.ID, big: Bool = false) {
        self.picture = picture
        self.namespace = namespace
        self.big = big
    }
    
    var body: some View {
        Group {
            if !big {
                if let image = mainPictureVM.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 150)
                        .clipShape(.rect(cornerRadius: 11))
                        .matchedTransitionSource(id: picture?.lastPathComponent, in: namespace)
                } else {
                    placeholder
                        .matchedTransitionSource(id: picture?.lastPathComponent, in: namespace)
                }
            } else {
                if let image = mainPictureVM.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .navigationTransition(.zoom(sourceID: picture?.lastPathComponent ?? UUID().uuidString, in: namespace))
                } else {
                    placeholder
                        .navigationTransition(.zoom(sourceID: picture?.lastPathComponent ?? UUID().uuidString, in: namespace))
                }
            }
        }
        .onAppear {
            mainPictureVM.getImage(mainPicture: picture)
        }
    }
    
    private var placeholder: some View {
        Image(systemName: "book")
            .font(.largeTitle)
            .padding(.horizontal, 10)
            .padding(.vertical, 30)
            .background(.gray.opacity(0.3), in: .rect(cornerRadius: 11))
    }
}

#Preview {
    @Previewable @Namespace var namespace
    MainPictureView(picture: URL(string: "https://cdn.myanimelist.net/images/manga/2/253146.jpg"), namespace: namespace)
}

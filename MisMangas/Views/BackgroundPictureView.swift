//
//  BackgroundPictureView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 5/1/26.
//

import SwiftUI

struct BackgroundPictureView: View {
    let picture: URL?
    
    @State private var mainPictureVM = MainPictureVM()
    
    var body: some View {
        Group {
            if let image = mainPictureVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .onAppear {
            mainPictureVM.getImage(mainPicture: picture)
        }
    }
}

#Preview {
    BackgroundPictureView(picture: URL(string: "https://cdn.myanimelist.net/images/manga/2/253146.jpg"))
}

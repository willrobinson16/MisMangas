//
//  PictureView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI
import NetworkAPI

struct MainPictureView: View {
    let mainPicture: URL?

    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 150)
                    .clipShape(.rect(cornerRadius: 11))
            } else {
                Image(systemName: "book")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding()
                    .background(.gray.opacity(0.1), in: .rect(cornerRadius: 11))
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    MainPictureView(mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/2/253146.jpg"))
}

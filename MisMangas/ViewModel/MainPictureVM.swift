//
//  PictureVM.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 23/12/25.
//

import SwiftUI

@Observable
final class MainPictureVM {
    var mainPicture: UIImage?
    
    func getImage(mainPicture: URL?) {
        guard let mainPicture else { return }
        do {
            let file = ImageDownloader.shared.getFileURL(url: mainPicture)
            if FileManager.default.fileExists(atPath: file.path()) {
                let data = try Data(contentsOf: file)
                image = UIImage(data: data)
            } else {
                Task {
                    do {
                        image = try await
                        ImageDownloader.shared.image(for: mainPicture)
                    } catch {
                        print(error)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}


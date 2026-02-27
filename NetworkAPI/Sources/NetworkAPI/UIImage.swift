//
//  UIImage.swift
//  EmpleadosAPI
//
//  Created by Guillermo Robinson on 24/11/25.
//

import UIKit

extension UIImage {
    func resize(width: CGFloat) async -> UIImage? {
        let scale = min(1, width / size.width)
        let size = CGSize(width: width, height: size.height * scale)
        return await byPreparingThumbnail(ofSize: size)
    }
}

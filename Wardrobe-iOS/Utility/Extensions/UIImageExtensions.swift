//
//  UIImageExtrnsion.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/1/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func scaledImage(width: CGFloat, height: CGFloat) -> UIImage {
        let ratio1 = size.width / width
        let ratio2 = size.height / height
        var ratio = ratio1
        if ratio2 > ratio1 {
            ratio = ratio2
        }
        let _width = size.width / ratio
        let _height = size.height / ratio
        let rect = CGRect(x: 0, y: 0, width: _width, height: _height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

//
//  ColorExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/22/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        var stringToScan = hexString
        if stringToScan.hasPrefix("#") {
            stringToScan.remove(at: stringToScan.startIndex)
        }
        let scanner = Scanner(string: stringToScan)
        var hexInt: UInt32 = 0
        scanner.scanHexInt32(&hexInt)
        self.init(hex: Int(hexInt))
    }
    
    convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xff) / 255.0
        let green = CGFloat((hex >> 8) & 0xff) / 255.0
        let blue = CGFloat(hex & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

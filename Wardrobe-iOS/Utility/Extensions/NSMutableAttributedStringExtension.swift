//
//  NSMutableAttributedStringExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/20/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {

    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: "http://www.google.com", range: foundRange)
            return true
        }
        return false
    }
}

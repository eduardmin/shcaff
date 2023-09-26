//
//  NSRangeExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/24/20.
//

import Foundation

extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16

        let lowerBound = lowerBound.samePosition(in: utf16)
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound!)
        let length = utf16.distance(from: lowerBound!, to: upperBound.samePosition(in: utf16)!)

        self.init(location: location, length: length)
    }

    public init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    public init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}

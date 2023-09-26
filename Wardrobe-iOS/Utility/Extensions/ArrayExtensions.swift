//
//  ArrayExtensions.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/1/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation

extension Array {
    func changeElementToFirst(element index: Int) -> Array {
        var newArray = self
        let element = newArray[index]
        newArray.remove(at: index)
        newArray.insert(element, at: 0)
        return newArray
    }
}

func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

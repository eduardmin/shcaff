//
//  DictionaryExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.


import Foundation

func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>)
    -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}


extension Dictionary {
    func paramsToString() -> String {
        var paramsString = "?"
        for key in self.keys {
            if let value = self[key] {
                paramsString.append("\(key)=\(value)&")
            }
        }
        return String(paramsString.dropLast())
    }
}

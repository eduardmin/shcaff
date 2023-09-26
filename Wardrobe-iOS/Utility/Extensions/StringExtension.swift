//
//  StringExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.

import Foundation

extension String {
    func localize() -> String {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        guard let path = Bundle.main.path(forResource: currentLanguageKey, ofType: "lproj") else {
            return ""
        }
        let bundle = Bundle(path: path)///applelanguages
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localize(), arguments: arguments)
    }
    
    var whitespacesCondensed: String {
        var components = self.components(separatedBy: .whitespacesAndNewlines)
        components = components.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}


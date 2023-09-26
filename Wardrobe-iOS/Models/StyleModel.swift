//
//  StyleModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/10/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class StyleModel {
    let id: Int
    let names: [String: Any]
    let url: String
    var name: String? {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        if let en = names[currentLanguageKey] as? String {
            return en
        } else if let base = names["base"] as? String {
            return base
        }
        return nil
    }

    init(_ dict: [String: Any]) {
        id = dict["id"] as? Int ?? 0
        names = dict["name"] as? [String: Any] ?? [:]
        url = dict["url"] as? String ?? ""
    }
}

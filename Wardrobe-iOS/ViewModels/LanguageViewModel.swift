//
//  LanguageViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/29/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class LanguageViewModel: NSObject {
    var selectedIndex: Int?
    var languages: [LanguageModel] {
        return LanguageManager.manager.languages
    }
    
    public func getSelectedLanguage() -> LanguageModel {
        if let selectedIndex = selectedIndex {
            return languages[selectedIndex]
        }
        return LanguageManager.manager.currentLanguge()
    }
    
    func select(indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    public func confirm() {
        let selectedLanguage = getSelectedLanguage()
        LanguageManager.manager.putCurrentLanguageKey(selectedLanguage.key)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
}

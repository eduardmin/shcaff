//
//  LanguageManager.swift
//  Menu
//
//  Created by Tigran on 12/20/18.
//  Copyright © 2018 Menu Group (UK) LTD. All rights reserved.
//

import Foundation

enum LanguageType: String {
    case english = "en"
    case russian = "ru"
}

struct LanguageModel {
    var key: String
    var name: String
    var languageCode: String
}

class LanguageManager: NSObject {
    static let manager: LanguageManager = LanguageManager()
    
    private override init() { }

    let defaultLanguageKey: String = "en"
    
    var languages: [LanguageModel] {
        let english = LanguageModel(key: "en", name: "English", languageCode: "GB")
        let russian = LanguageModel(key: "ru", name: "Русский", languageCode: "RU")
        return [english, russian]
    }
 
    func suportedLanguagesCount() -> Int {
        return languages.count
    }
    
    /** Fucntion will return deafault language, if there is no language for inputed key*/
    func languageByKey(_ key: String) -> LanguageModel {
        for language in languages {
            if language.key == key {
                return language
            }
        }
        
        return defaultLanguage()
    }
    
    func defaultLanguage() -> LanguageModel {
        return languageByKey(defaultLanguageKey)
    }
    
    /** Fucntion will return deafault language, if languge is not selected yet*/
    func currentLanguge() -> LanguageModel {
        
        let selectedLanguageKey = UserDefaults.standard.string(forKey: Constants.currentLanguageKey) ?? defaultLanguageKey
        
        return languageByKey(selectedLanguageKey)
    }
    
    func putCurrentLanguageKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: Constants.currentLanguageKey)
    }
    
    func setInitialLanguage() {
        if UserDefaults.standard.string(forKey: Constants.currentLanguageKey) == nil {
            var initialLanguage = defaultLanguage().key
            let deviceLanguage = Locale.current.languageCode!
            if (self.languages.map{$0.key}).contains(deviceLanguage){
                initialLanguage = deviceLanguage
            }
            self.putCurrentLanguageKey(initialLanguage)
        }
    }
}

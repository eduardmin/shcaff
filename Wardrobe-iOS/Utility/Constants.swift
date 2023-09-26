//
//  Constants.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/6/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import Foundation
import UIKit


enum ServerConstants: String {
    case clothingTypes
    case itemTypes
    case prints
    case styles
    case sizes
    case seasons
    case genders
    case occasions
    case colors
    
    static let entityNames = [clothingTypes: EntityName.clothingTypes, itemTypes: EntityName.itemTypes, prints: EntityName.prints, styles: EntityName.clothingStyles, sizes: EntityName.sizes, seasons: EntityName.seasons, genders: EntityName.genders, occasions: EntityName.occasions, colors: EntityName.colors]
    
    static func supportGenderId(_ type: ServerConstants) -> Bool {
        if type == .clothingTypes || type == .itemTypes || type == .styles {
            return true
        }
        return false
    }
    
    static func requiredParameter(_ type: ServerConstants) -> Bool {
        if type == .clothingTypes || type == .itemTypes || type == .colors {
            return true
        }
        return false
    }
    
    static func supportMultitouch(_ type: ServerConstants) -> Bool {
        if type == .colors {
            return true
        }
        return false
    }
}

struct Constants {
    static let currentLanguageKey = "currentLanguageKey"
    //UI
    static let tableViewCellHeight: CGFloat = 50
    static let tabBarHeight : CGFloat = 57
    static let lookDefaultSize: CGSize = CGSize(width: 163, height: 163)
}

struct UrlConstants {
    static let termUrl = ""
}

struct StoryboardName {
    static let main = "Main"
    static let login = "Login"
    static let wardrobe = "Wardrobe"
    static let account = "Account"
}


//MARK:- Entity names
struct EntityName {
    static let profile = "Profile"
    static let calendarEvent = "CalendarEvent"
    static let clothingTypes = "ClothingTypes"
    static let itemTypes = "ItemTypes"
    static let prints = "Prints"
    static let clothingStyles = "ClothingStyles"
    static let sizes = "Sizes"
    static let seasons = "Seasons"
    static let genders = "Genders"
    static let occasions = "Occasions"
    static let colors = "Colors"
    static let item = "Item"
    static let album = "Album"
    static let set = "WardrobeSet"
}

//MARK:- UserDefaults key
struct UserDefaultsKey {
    static let email = "email"
    static let firstInit = "firstInit"
    static let selectedCategory = "selectedCategory"
    static let wardrobeSyncTime = "wardrobeSyncTime"
    static let goal = "goal"
    static let style = "style"
    static let basic = "basic"
    static let profile = "profile"
    static let push = "pushToken"
    static let weather = "weader"
    static let onBoarding = "onBoarding"
}

//MARK:- NotificationName
struct NotificationName {
    static let noInternet = "noInternet"
    static let updateItems = "updateItems"
    static let updateEvents = "updateEvents"
    static let updateSets = "updateSets"
    static let updateProfile = "updateProfile"
    static let changeLanguage = "changeLanguage"
    static let badge = "badge"
    static let scrollToCollection = "scrollToCollection"
    static let updateCollection = "updateCollection"
    static let updateWeather = "updateWeather"
}

//MARK:- FileName
struct FileName {
    static let items = "items"
    static let sets = "sets"
    static let looks = "looks"
    static let avatar = "avatar"
}

//MARK:- View Update Type
enum ViewUpdateType {
    case reload
    case update(Int)
    case insert(Int)
    case delete(Int)
}



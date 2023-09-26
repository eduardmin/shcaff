//
//  PathsConstants.swift
//  Menu
//
//  Created by Mariam on 11/12/19.
//  Copyright © 2020 Wardrobe. All rights reserved.
//

import Foundation

let isDev: Bool = false
let releaseVersion = true
class Paths {
    //MARK:- Mail
    static let supportMail = "hello@shcaff.com"
    static let termCondidionUrl = "https://shcaff.com/terms-and-privacy-policy"
    //MARK:- Base URLs
    static var baseUrl: String {
        if isDev {
            return "http://test-services.shcaff.com/api/v1"
        } else {
            return "http://services.shcaff.com/api/v1"
        }
    }
    
    //MARK:- End Points
    // auth
    static let signup = baseUrl + "/auth/sign-up"
    static let signin = baseUrl + "/auth/sign-in"
    static let googleSignIn = baseUrl + "/auth/google"
    static let faceBookSignIn = baseUrl + "/auth/facebook"
    static let appleSignIn = baseUrl + "/auth/apple"
    static let resendMail = baseUrl + "/auth/resend"
    static let validate = baseUrl + "/auth/validate"
    static let recoverPassword = baseUrl + "/auth/recover-password"
    static let trialAccountSignUp = baseUrl + "/account/sign-up"
    static let trialAccount = baseUrl + "/auth/trial"
    // calendar
    static let calendarEvent = baseUrl + "/calendar/events"
    static let calendarNoSetEvent = baseUrl + "/calendar/event-with-look"
    static let weather = baseUrl + "/calendar/weather"

    //wardrobe
    static let albums = baseUrl + "/wardrobe/albums"
    static let wardrobe = baseUrl + "/wardrobe"
    static let items = baseUrl + "/wardrobe/items"
    static let sets = baseUrl + "/wardrobe/sets"
    static let wardrobeDefaultItems = baseUrl + "/wardrobe/default-items"

    // defaults
    static let goals = baseUrl + "/default/goals"
    static let styles = baseUrl + "/default/styles"
    static let constant = baseUrl + "/default/item-features"
    static let defaultItems = baseUrl + "/default/items"
    
    // account
    static let account = baseUrl + "/account"
    static let setProfile = baseUrl + "/account/profiles"
    static let accountGoals = baseUrl + "/account/goals"
    static let accountStyles = baseUrl + "/account/styles"
    static let logout = baseUrl + "/account/log-out"
    static let password = baseUrl + "/account/passwords"
    static let attibutes = baseUrl + "/account/attributes"
    static let stats = baseUrl + "/account/stats"
    static let avatarUrl = baseUrl + "/account/avatar-url"
    static let deviceInfo = baseUrl + "/account/updates"
    
    //find
    static let suggestionWhatToWear = baseUrl + "/suggestion/what-to-wear"
    static let suggestionExplore = baseUrl + "/suggestion/explore"
    static let itemSuggestion = baseUrl + "/suggestion/items"
    static let suggestionLook = baseUrl + "/suggestion/looks"
    static let search = baseUrl + "/search"
    static let searchRecents = baseUrl + "/search/recent"
    
    //Statistic
    static let lookStatistic = baseUrl + "/statistic/view-look"
    
    //Notifications
    static let notifications = baseUrl + "/notifications"
    
    //Survey
    static let survey = baseUrl + "/survey"
    static let surveySubmit = baseUrl + "/survey/submit"
}

//
//  EventLogger.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/14/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import Foundation
import Firebase

class EventLogger {
    class func logEvent(_ eventName: String, withParameters parameters: [String: String]? = nil) {
        var adjustedParameters: [String : String]!
        if let p = parameters {
             adjustedParameters = p
        } else {
             adjustedParameters = [String : String]()
        }
        
        var firebaseParameters = [String: String]()
        for parameter in adjustedParameters {
             let key = clearEventName(parameter.key)
             firebaseParameters[key] = parameter.value
        }
        var firebaseEventName = eventName
        firebaseEventName = clearEventName(firebaseEventName)
        Analytics.logEvent(firebaseEventName, parameters: firebaseParameters)
    }
    
    class func clearEventName(_ eventName: String) -> String {
         return eventName
              .trimmingCharacters(in: .whitespacesAndNewlines)
              .replacingOccurrences(of: "'", with: "")
              .replacingOccurrences(of: "/", with: " ")
              .replacingOccurrences(of: "-", with: " ")
              .whitespacesCondensed
              .replacingOccurrences(of: " ", with: "_")
    }
}

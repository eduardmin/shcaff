//
//  NotificationWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/17/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class NotificationWebService: BaseNetworkManager {
    
    func getNotifiations(offset: Int, limit: Int, _ completion: @escaping RequestCompletion) {
        var parameters = [String : Any]()
        parameters["offset"] = offset
        parameters["limit"] = limit

        sendGetRequest(path: Paths.notifications, parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }
    
    func updateSeenNotifications(_ completion: @escaping ( Bool) -> ()) {
        sendPutRequest(path: Paths.notifications) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    }
                default:
                    break
                }
            } else if let result = response as? [String : Any], let seenUpdated = result["isSeenUpdated"] as? Int {
                completion(seenUpdated == 1)
                return
            }
            
            completion( false)
        }
    }
}

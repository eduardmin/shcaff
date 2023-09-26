//
//  RecoverPasswordWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 3/25/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum RecoverError : String {
    case parameterMissed = "PARAMETER_MISSED"
    case userNotFound = "USER_NOT_FOUND"
    case userIsValidated = "USER_IS_VALIDATED"
    case deviceNotFound = "DEVICE_NOT_FOUND"
}

class RecoverPasswordWebService: BaseNetworkManager {
    func recover(_ mail: String, completion : @escaping ([String : Any]?, RecoverError?) -> ()) {
        
        var parameters = [String : Any]()
        parameters["email"] = mail
        parameters["regionCode"] = getRegionCode()
        parameters["language"] = getLanguageCode()
        parameters["deviceToken"] = getDeviceToken()
        parameters["deviceName"] = getDeviceName()
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        parameters["platformId"] = platformId()
        parameters["dev"] = isDev
        sendPostRequest(path: Paths.recoverPassword, parameters:parameters) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    } else if let signInError = RecoverError(rawValue: errorType) {
                        completion(nil, signInError)
                        return
                    }
                default:
                    break
                }
            } else if let result = response as? [String : Any] {
                completion(result, nil)
                return
            }
            
            completion(nil, nil)
        }
    }
}

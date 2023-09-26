//
//  TrialAccountWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/3/20.
//

import UIKit

enum TrialAccountError : String {
    case wrongDevice = "WRONG_DEVICE"
    case countryNotFound = "COUNTRY_NOT_FOUND"
    case languageNotFound = "LANGUAGE_NOT_FOUND"
}

class TrialAccountWebService: BaseNetworkManager {

    func createTrialAccount(completion : @escaping ([String : Any]?, TrialAccountError?) -> ()) {
        var parameters = [String : Any]()
        parameters["regionCode"] = getRegionCode()
        parameters["language"] = getLanguageCode()
        parameters["deviceToken"] = getDeviceToken()
        parameters["deviceName"] = getDeviceName()
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        parameters["platformId"] = platformId()
        parameters["dev"] = isDev
        sendPostRequest(path: Paths.trialAccount, parameters: parameters) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    } else if let trialAccountError = TrialAccountError(rawValue: errorType) {
                        completion(nil, trialAccountError)
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

//
//  SignUpWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit


enum SignUpError : String {
    case failError
    case parameterMissed = "PARAMETER_MISSED"
    case invalidEmail = "INVALID_EMAIL"
    case parameterMisMatch = "PARAMETER_MISMATCH"
    case userExist = "USER_EXIST"
    case requestNotClear = "REQUEST_NOT_CLEAR"
    case countryNotFound = "COUNTRY_NOT_FOUND"
    case languageNotFound = "LANGUAGE_NOT_FOUND"
    case userValideted = "USER_IS_VALIDATED"
}

class SignUpWebService: BaseNetworkManager {

    func signup(_ signupSendModel : SignupSendModel, completion : @escaping ([String : Any]?, SignUpError?) -> ()) {
        var parameters = [String : Any]()
        parameters["email"] = signupSendModel.email
        let userName = signupSendModel.email.components(separatedBy:"@").first
        parameters["username"] = userName ?? ""
        parameters["password"] = signupSendModel.password
        parameters["firstName"] = signupSendModel.firstName
        parameters["lastName"] = signupSendModel.lastName
        parameters["regionCode"] = getRegionCode()
        parameters["language"] = getLanguageCode()
        parameters["deviceToken"] = getDeviceToken()
        parameters["deviceName"] = getDeviceName()
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        parameters["platformId"] = platformId()
        parameters["dev"] = isDev
        isAuthenticate = false
        sendPostRequest(path: Paths.signup, parameters:parameters) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    } else if let signUpError = SignUpError(rawValue: errorType) {
                        completion(nil, signUpError)
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

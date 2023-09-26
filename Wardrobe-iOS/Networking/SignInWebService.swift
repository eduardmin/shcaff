//
//  SignInWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//

import UIKit

enum SignInError : String {
    case failError
    case parameterMissed = "PARAMETER_MISSED"
    case languageNotFound = "LANGUAGE_NOT_FOUND"
    case userNotFound = "USER_NOT_FOUND"
    case userBlocked = "USER_BLOCKED"
    case userIsNotValidated = "USER_IS_NOT_VALIDATED"
    case invalidPassword = "INVALID_PASSWORD"
    case invalidToken = "INVALID_TOKEN"
}

enum SsoType {
    case facebook
    case google
    case apple
}

class SignInWebService: BaseNetworkManager {
    func signIn(_ user: User, completion : @escaping ([String : Any]?, SignInError?) -> ()) {
        
        var parameters = [String : Any]()
        parameters["email"] = user.email
        let userName = user.email.components(separatedBy:"@").first
        parameters["username"] = userName
        parameters["password"] = user.password
        parameters["regionCode"] = getRegionCode()
        parameters["language"] = getLanguageCode()
        parameters["deviceToken"] = getDeviceToken()
        parameters["deviceName"] = getDeviceName()
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        parameters["platformId"] = platformId()
        parameters["dev"] = isDev
        sendPostRequest(path: Paths.signin, parameters:parameters) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    } else if let signInError = SignInError(rawValue: errorType) {
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
    
    func ssoSignIn(name: String?, lastName: String?, _ token: String, _ type: SsoType, completion : @escaping ([String : Any]?, SignInError?) -> ()) {
        var parameters = [String : Any]()
        parameters["idToken"] = token
        parameters["firstName"] = name
        parameters["lastName"] = lastName
        parameters["regionCode"] = getRegionCode()
        parameters["language"] = getLanguageCode()
        parameters["deviceToken"] = getDeviceToken()
        parameters["deviceName"] = getDeviceName()
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        parameters["platformId"] = platformId()
        parameters["dev"] = isDev
        var path = ""
        switch type {
        case .apple:
            path = Paths.appleSignIn
        case .facebook:
            path = Paths.faceBookSignIn
        case .google:
            path = Paths.googleSignIn
        }
        
        sendPostRequest(path: path, parameters:parameters) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    } else if let signInError = SignInError(rawValue: errorType) {
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

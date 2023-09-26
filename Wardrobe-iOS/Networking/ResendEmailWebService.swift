//
//  ResendEmailWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

enum ResendEmailError : String {
    case userNotFound = "USER_NOT_FOUND"
    case userBlocked = "USER_BLOCKED"
    case userIsValidated = "USER_IS_VALIDATED"
    case deviceNotFound = "DEVICE_NOT_FOUND"
}

class ResendEmailWebService: BaseNetworkManager {

    func resendEmail(email : String, completion : @escaping ([String : Any]?, ResendEmailError?) -> ()) {
             
             var parameters = [String : Any]()
             parameters["email"] = email
       
             sendGetRequest(path: Paths.resendMail, parameters:parameters) { (response, error) in
                 if error != nil {
                     switch error {
                     case .failError(code: _, message: _):
                         break
                     case .successError(errorType: let errorType):
                         if let baseError = BaseErrorType(rawValue: errorType) {
                             // base error implitation
                             print(baseError)
                         } else if let resendEmailError = ResendEmailError(rawValue: errorType) {
                             completion(nil, resendEmailError)
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

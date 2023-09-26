//
//  ValidateWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//

import UIKit


enum ValidateError : String {
    case parameterMissed = "PARAMETER_MISSED"
    case userNotFound = "USER_NOT_FOUND"
    case userIsValidated = "USER_IS_VALIDATED"
    case wrongConfirmationCode = "WRONG_CONFIRMATION_CODE"
    case deviceNotFound = "DEVICE_NOT_FOUND"
}

class ValidateWebService: BaseNetworkManager {
    
    func validate(email : String, confirmationToken : String, completion : @escaping ([String : Any]?, ValidateError?) -> ()) {
          
          var parameters = [String : Any]()
          parameters["email"] = email
          parameters["confirmationToken"] = confirmationToken
          parameters["deviceToken"] = getDeviceToken()

          sendPutRequest(path: Paths.validate, parameters:parameters) { (response, error) in
              if error != nil {
                  switch error {
                  case .failError(code: _, message: _):
                      break
                  case .successError(errorType: let errorType):
                      if let baseError = BaseErrorType(rawValue: errorType) {
                          // base error implitation
                          print(baseError)
                      } else if let validateError = ValidateError(rawValue: errorType) {
                          completion(nil, validateError)
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

//
//  TempWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/21/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class TempWebService: BaseNetworkManager {
    func saveTemp(celsius: Bool, _ completion: @escaping (Bool) -> ()) {
        var parameters = [String : Any]()
        parameters["isCelsius"] = celsius
        sendPostRequest(path: Paths.attibutes, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any], let attributesAdded = result["isAttributesAdded"] as? Int {
                completion(attributesAdded == 1)
                return
            }
            
            completion( false)
        }
    }
    
    func getTemp(_ completion: @escaping RequestCompletion) {
        sendGetRequest(path: Paths.attibutes) { (response, error) in
            completion(response, error)
        }
    }
}

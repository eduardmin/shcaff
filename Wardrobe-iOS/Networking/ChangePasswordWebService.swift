//
//  ChangePasswordWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/21/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ChangePasswordWebService: BaseNetworkManager {

    func changePassword(currentPassword: String?, newPassword: String, recovery: Bool, _ completion: @escaping (Bool) -> ()) {
        var parameters = [String : Any]()
        parameters["oldPassword"] = currentPassword ?? ""
        parameters["newPassword"] = newPassword
        parameters["recovery"] = recovery
        sendPutRequest(path: Paths.password, parameters: parameters) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isPasswordChanged = response["isPasswordChanged"] as? Bool, isPasswordChanged {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
}

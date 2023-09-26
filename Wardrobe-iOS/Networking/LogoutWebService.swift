//
//  LogoutWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class LogoutWebService: BaseNetworkManager {

    func logout(_ completion: @escaping (Bool) -> ()) {
        sendPutRequest(path: Paths.logout) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isLoggedOut = response["isLoggedOut"] as? Bool, isLoggedOut {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
    
    func deleteAccount(_ completion: @escaping (Bool) -> ()) {
        sendDeleteRequest(path: Paths.account) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isDeleted = response["isAccountDeleted"] as? Bool, isDeleted {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
}

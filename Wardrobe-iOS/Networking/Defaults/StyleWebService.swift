//
//  StyleWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/10/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class StyleWebService: BaseNetworkManager {
    
    func getStyles(_ completion : @escaping ([[String: Any]]?, Bool) -> ()) {
        sendGetRequest(path: Paths.styles, timeOut: 20) { (response, error) in
            
            if error != nil {
                completion(nil, true)
                return
            }
            
            if let response = response as? [[String: Any]] {
                completion(response, false)
                return
            }
            
            completion(nil, false)
        }
    }
    
    func getPersonalStyles(_ completion : @escaping ([[String: Any]]?, Bool) -> ()) {
        sendGetRequest(path: Paths.accountStyles, timeOut: 20) { (response, error) in
            
            if error != nil {
                completion(nil, true)
                return
            }
            
            if let response = response as? [[String: Any]] {
                completion(response, false)
                return
            }
            
            completion(nil, false)
        }
    }
    
    func saveStyle(ids: [Int], _ completion : @escaping (Bool) -> ()) {
        
        sendPostRequest(path: Paths.accountStyles, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let result = response as? [String : Any], let isStylesAdded = result["isStylesAdded"] as? Int {
                completion(isStylesAdded == 1)
                return
            }
            completion(false)
        }
    }
    
    func updateStyle(ids: [Int], _ completion : @escaping (Bool) -> ()) {
        
        sendPutRequest(path: Paths.accountStyles, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let result = response as? [String : Any], let isStylesUpdated = result["isStylesUpdated"] as? Int {
                completion(isStylesUpdated == 1)
                return
            }
            completion(false)
        }
    }
}

//
//  DefaultItemWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/11/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class DefaultItemWebService: BaseNetworkManager {

    func getDefaultItems(_ completion : @escaping ([[String: Any]]?, Bool) -> ()) {
        sendGetRequest(path: Paths.defaultItems, timeOut: 20) { (response, error) in
            
            if error != nil {
                completion(nil, true)
            }
            
            if let response = response as? [[String: Any]] {
                completion(response, false)
                return
            }
            
            completion(nil, false)
        }
    }
    
    func saveDefaultItems(ids: [Int64], _ completion : @escaping (Bool) -> ()) {
        
        sendPostRequest(path: Paths.wardrobeDefaultItems, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
            }
            
            if let result = response as? [String : Any], let isGoalsAdded = result["isItemsAdded"] as? Int {
                completion(isGoalsAdded == 1)
                return
            }
            completion(false)
        }
    }
}

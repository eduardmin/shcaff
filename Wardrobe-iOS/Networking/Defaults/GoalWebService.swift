//
//  GoalWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/10/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class GoalWebService: BaseNetworkManager {
    func getGoals(_ completion : @escaping ([[String: Any]]?, Bool) -> ()) {
        sendGetRequest(path: Paths.goals, timeOut: 20) { (response, error) in
            
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
    
    func getPersonalGoals(_ completion : @escaping ([[String: Any]]?, Bool) -> ()) {
        sendGetRequest(path: Paths.accountGoals, timeOut: 20) { (response, error) in
            
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
    
    func saveGoal(ids: [Int], _ completion : @escaping (Bool) -> ()) {
        
        sendPostRequest(path: Paths.accountGoals, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let result = response as? [String : Any], let isGoalsAdded = result["isGoalsAdded"] as? Int {
                completion(isGoalsAdded == 1)
                return
            }
            completion(false)
        }
    }
    
    func updateGoal(ids: [Int], _ completion : @escaping (Bool) -> ()) {
        sendPutRequest(path: Paths.accountGoals, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let result = response as? [String : Any], let isGoalsUpdated = result["isGoalsUpdated"] as? Int {
                completion(isGoalsUpdated == 1)
                return
            }
            completion(false)
        }
    }
}

//
//  WardrobeWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/24/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class WardrobeWebService: BaseNetworkManager {
    func getWardrobe(_ completion : @escaping RequestCompletion) {
        var parameters = [String : Any]()
        let syncTime = UserDefaults.standard.integer(forKey: UserDefaultsKey.wardrobeSyncTime) 
        parameters["lastSyncTs"] = syncTime
        sendGetRequest(path: Paths.wardrobe, parameters: parameters, timeOut: 20) { (response, error) in
            completion(response, error)
        }
    }
}

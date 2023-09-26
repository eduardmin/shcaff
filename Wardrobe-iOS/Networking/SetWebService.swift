//
//  SetWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class SetWebService: BaseNetworkManager {

    func saveSet(_ setModels: [SetModel], _ completion : @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for set in setModels {
            var parameters = [String : Any]()
            parameters["lookId"] = set.lookId
            parameters["albumId"] = set.albumId
            parameters["itemIds"] = set.itemIds
            values.append(parameters)
        }
        sendPostRequest(path: Paths.sets, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func editSet(_ setModels: [SetModel], _ completion : @escaping (Bool) -> ()) {
        var values = [[String: Any]]()
        for set in setModels {
            var parameters = [String : Any]()
            parameters["setId"] = set.id
            parameters["lookId"] = set.lookId
            parameters["albumId"] = set.albumId
            parameters["itemIds"] = set.itemIds
            values.append(parameters)
        }
        sendPutRequest(path: Paths.sets, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isSetsUpdated = response["isSetsUpdated"] as? Bool, isSetsUpdated {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
    
    func deleteSet(_ setModels: [SetModel], _ completion : @escaping (Bool) -> ()) {
        var values = [Int64]()
        for set in setModels {
            values.append(set.id!)
        }

        sendDeleteRequest(path: Paths.sets, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isSetsDeleted = response["isSetsDeleted"] as? Bool, isSetsDeleted {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
}

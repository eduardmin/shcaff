//
//  ItemWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/27/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit


class ItemWebService: BaseNetworkManager {

    func saveItems(_ itemModels: [ItemModel], _ completion : @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for item in itemModels {
            var parameters = [String : Any]()
            parameters["tempId"] = item.tempId
            parameters["clothingType"] = item.clothingType
            parameters["itemType"] = item.itemType
            parameters["gender"] = UIApplication.appDelegate.profileModel?.genderId()
            parameters["size"] = item.size
            parameters["print"] = item.print
            parameters["colors"] = item.colors
            parameters["brand"] = item.brand
            parameters["personal"] = true
            values.append(parameters)
        }
        sendPostRequest(path: Paths.items, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func updateItems(_ itemModels: [ItemModel], _ completion : @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for item in itemModels {
            var parameters = [String : Any]()
            parameters["id"] = item.id
            parameters["clothingType"] = item.clothingType
            parameters["itemType"] = item.itemType
            parameters["gender"] = UIApplication.appDelegate.profileModel?.genderId()
            parameters["size"] = item.size
            parameters["print"] = item.print
            parameters["colors"] = item.colors
            parameters["tempId"] = item.tempId
            parameters["brand"] = item.brand
            parameters["waterproof"] = true
            parameters["imageUpdated"] = item.imageUpdated
            values.append(parameters)
        }
        sendPutRequest(path: Paths.items, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func deleteItems(_ itemModels: [ItemModel], _ completion : @escaping (Bool) -> ()) {
        var values = [Int64]()
        for itemModel in itemModels {
            if let id = itemModel.id {
                values.append(id)
            }
        }

        sendDeleteRequest(path: Paths.items, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isItemsDeleted = response["isItemsDeleted"] as? Bool, isItemsDeleted {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
    
    func getItems(_ completion : @escaping RequestCompletion) {
        sendGetRequest(path: Paths.items) { (response, error) in
            completion(response, error)
        }
    }
}

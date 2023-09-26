//
//  SuggestionWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class SuggestionWebService: BaseNetworkManager {

    func getSuggestion(lookModelType: LookViewModelType, offset: Int, limit: Int, _ completion: @escaping RequestCompletion) {
        let path = lookModelType == .whatToWear ? Paths.suggestionWhatToWear : Paths.suggestionExplore
        var parameters = [String : Any]()
        parameters["offset"] = offset
        parameters["limit"] = limit
        sendGetRequest(path: path, parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }
    
    func getLookSuggestion(id: Int64, offset: Int, limit: Int, _ completion: @escaping RequestCompletion) {
        let path = Paths.suggestionLook + "/" + "\(id)"
        var parameters = [String : Any]()
        parameters["offset"] = offset
        parameters["limit"] = limit
        sendGetRequest(path:path , parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }

    
    func getSetSuggestion(itemIds: [Int64], offset: Int, limit: Int, _ completion: @escaping RequestCompletion) {
        var parameters = [String : Any]()
        parameters["itemIds"] = itemIds
        parameters["offset"] = offset
        parameters["limit"] = limit
        sendPostRequest(path: Paths.itemSuggestion, parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }
}

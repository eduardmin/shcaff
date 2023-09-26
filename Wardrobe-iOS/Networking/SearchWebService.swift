//
//  SearchWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/31/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SearchError : String {
    case requestNotClear = "REQUEST_NOT_CLEAR"
}

class SearchWebService: BaseNetworkManager {
    
    func search(lookParameters: [ItemParametersType: [Int64]], query: String, offset: Int, limit: Int, _ completion: @escaping RequestCompletion) {
        var parameters = [String : Any]()
        parameters["query"] = query
        parameters["offset"] = offset
        parameters["limit"] = limit

        for (key, value) in lookParameters {
            switch key {
            case .type:
                parameters["itemTypeIds"] = value
            case .color:
                parameters["colorIds"] = value
            case .print:
                parameters["printIds"] = value
            case .style:
                parameters["styleIds"] = value
            case .occassion:
                parameters["occasionIds"] = value
            case .season:
                parameters["seasonIds"] = value
            default:
                break
            }
        }

        sendPostRequest(path: Paths.search, parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }

    func getRecentTexts(_ completion: @escaping RequestCompletion) {
        sendGetRequest(path: Paths.searchRecents) { (response, error) in
            completion(response, error)
        }
    }
    
    func deleteRecentText(ids: [String], completion: @escaping RequestCompletion) {
        sendDeleteRequest(path: Paths.searchRecents, parameters: ids.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
}

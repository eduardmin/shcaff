//
//  AvatarUrlWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/27/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum AvatarMethod: String {
    case PUT
    case GET
}

class AvatarUrlWebService: BaseNetworkManager {

    func getAvatarUrl(method: AvatarMethod, _ completion : @escaping RequestCompletion) {
        var parameters = [String : Any]()
        parameters["method"] = method.rawValue
        sendGetRequest(path: Paths.avatarUrl, parameters: parameters) { (response, error) in
            completion(response, error)
        }
    }
}

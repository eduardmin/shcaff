//
//  ConstantNetworkManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/20/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ConstantWebService: BaseNetworkManager {

    func getConstants(_ completion : @escaping RequestCompletion) {
        sendGetRequest(path: Paths.constant, timeOut: 20) { (response, error) in
            completion(response, error)
        }
    }
}

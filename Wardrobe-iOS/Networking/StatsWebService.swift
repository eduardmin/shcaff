//
//  StatsWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/26/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class StatsWebService: BaseNetworkManager {

    func getStats(_ completion : @escaping RequestCompletion) {
        sendGetRequest(path: Paths.stats, timeOut: 20) { (response, error) in
            completion(response, error)
        }
    }
}

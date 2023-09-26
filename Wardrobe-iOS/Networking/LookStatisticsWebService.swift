//
//  LookStatistics.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/29/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class LookStatisticsWebService: BaseNetworkManager {

    func saveLookStatistics(statistics: [Int64: Int], _ completion: @escaping (Bool) -> ()) {
        var values = [[String: Any]]()
        statistics.forEach { (key, value) in
            var parameters = [String : Any]()
            parameters["lookId"] = key
            parameters["count"] = value
            values.append(parameters)
        }
        sendPostRequest(path: Paths.lookStatistic, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    }
                default:
                    break
                }
            } else if let result = response as? [String : Any], let attributesAdded = result["isLookViewed"] as? Int {
                completion(attributesAdded == 1)
                return
            }
            
            completion( false)
        }
    }
}

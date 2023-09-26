//
//  WeatherWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/11/20.
//

import UIKit

class WeatherWebService: BaseNetworkManager {
    func getWeather(_ model: LocationModel, _ completion : @escaping ([String : Any]?) -> ()) {
        var parameters = [String : Any]()
        parameters["lat"] = model.latitude
        parameters["lon"] = model.longitude
        parameters["city"] = model.cityName

        sendGetRequest(path: Paths.weather, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any] {
                completion(result)
                return
            }
            completion(nil)
        }
    }
}

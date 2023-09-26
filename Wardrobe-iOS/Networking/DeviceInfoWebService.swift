//
//  DeviceInfoWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/28/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class DeviceInfoWebService: BaseNetworkManager {
    func updateDeviceInfo(model: LocationModel?, _ completion: @escaping ( Bool) -> ()) {
        var parameters = [String : Any]()
        parameters["language"] = LanguageManager.manager.currentLanguge().key
        parameters["appVersion"] = getAppVersion()
        parameters["osVersion"] = getosVersion()
        parameters["pushToken"] = getPushToken()
        if let model = model, model.latitude != nil {
            var locationDict = [String: Any]()
            locationDict["latitude"] = model.latitude
            locationDict["longitude"] = model.longitude
            locationDict["city"] = model.cityName
            locationDict["timezone"] = TimeZone.current.abbreviation()
            parameters["location"] = locationDict
        }
        sendPutRequest(path: Paths.deviceInfo, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any], let updatesHandled = result["isUpdatesHandled"] as? Int {
                completion(updatesHandled == 1)
                return
            }
            
            completion( false)
        }
    }
}

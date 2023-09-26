//
//  ProfileWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/3/20.


import UIKit

class ProfileWebService: BaseNetworkManager {
    
    func setProfile(profile : ProfileModel, completion : @escaping ( Bool) -> ()) {
        var parameters = [String : Any]()
        parameters["firstName"] = profile.name
        parameters["lastName"] = profile.lastName ?? ""
        parameters["gender"] = profile.gender.rawValue
        parameters["birthday"] = profile.birthDayDate

        sendPostRequest(path: Paths.setProfile, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any], let profileUpdated = result["isProfileUpdated"] as? Int {
                completion(profileUpdated == 1)
                return
            }
            
            completion( false)
        }
    }
    
    func updateProfile(profile : ProfileModel, completion: @escaping ( Bool) -> ()) {
        
        var parameters = [String : Any]()
        parameters["firstName"] = profile.name
        parameters["lastName"] = profile.lastName
        parameters["gender"] = profile.gender.rawValue
        parameters["birthday"] = profile.birthDayDate

        sendPutRequest(path: Paths.setProfile, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any], let profileUpdated = result["isProfileUpdated"] as? Int {
                completion(profileUpdated == 1)
                return
            }
            
            completion( false)
        }
    }
}


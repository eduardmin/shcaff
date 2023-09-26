//
//  SurveysWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/4/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

class SurveysWebService: BaseNetworkManager {

    func getSurvey(completion :@escaping ([[String : Any]]?) -> ()) {
        sendGetRequest(path: Paths.survey) { (response, error) in
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
            } else if let result = response as? [[String : Any]] {
                completion(result)
                return
            }
            completion(nil)
        }
    }
    
    func saveSurvey(surveyId: Int, answers: [[String: Any]], completion: @escaping ( Bool) -> ()) {
        var parameters = [String : Any]()
        parameters["surveyId"] = surveyId
        parameters["userAnswers"] = answers

        sendPostRequest(path: Paths.surveySubmit, parameters: parameters) { (response, error) in
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
            } else if let result = response as? [String : Any], let profileUpdated = result["isSurveySubmitted"] as? Int {
                completion(profileUpdated == 1)
                return
            }
            
            completion( false)
        }
    }
}

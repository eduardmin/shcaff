//
//  TrialAccountViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/3/20.
//

import UIKit

class TrialAccountViewModel: NSObject {

    func createTrialAccount(completion : @escaping (Bool) -> ()) {
        let trialAccountWebService = TrialAccountWebService()
        trialAccountWebService.createTrialAccount { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
}

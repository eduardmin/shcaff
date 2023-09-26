//
//  RecoverPasswordViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 3/25/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class RecoverPasswordViewModel: NSObject {
    var completion: ((RequestResponseType) -> ())?
    
    func recover(email: String) {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        
        let recoverPasswordWebService = RecoverPasswordWebService()
        recoverPasswordWebService.recover(email) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            
            if error != nil {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.fail(showPopup: true))
                }
            }
            
            if  let _ = result?["status"] as? String {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.success(response: nil))
                }
                return
            }
            strongSelf.completion!(.fail(showPopup: true))
        }
    }
}

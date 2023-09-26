//
//  ChangePasswordViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/21/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ChangePasswordViewModel {
    var completion: ((RequestResponseType) -> ())?
    
    func changePassword(currentPassword: String?, newPassword: String, recovery: Bool = false) {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let changePasswordWebService = ChangePasswordWebService()
        changePasswordWebService.changePassword(currentPassword: currentPassword, newPassword: newPassword, recovery: recovery) { [weak self] (success) in
            guard let strongSelf = self else { return }
            if success {
                CredentialsStorage.setCredentialWithKey(newPassword, withKey: .password)
                strongSelf.completion?(.success(response: nil))
            } else {
                strongSelf.completion?(.fail(showPopup: true))
            }
        }

    }
}

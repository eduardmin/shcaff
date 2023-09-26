//
//  SignupViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/24/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

struct SignupSendModel {
    let firstName: String
    let lastName: String?
    let email: String
    let password: String
}

enum SignupResponse {
    case signUp(Bool, SignUpError?)
    case resend(Bool, ResendEmailError?)
    case validate(ValidateError?)
}

class SignupViewModel: NSObject {
    let coreDataManager = CoreDataManager.shared
    var signupSendModel: SignupSendModel?
    var completion :  ((SignupResponse?, Bool) -> ())?
    
    func singUp(_ firstName: String, _ lastName: String?, _ email: String, _ password: String) {
        signupSendModel = SignupSendModel(firstName: firstName, lastName: lastName, email: email, password: password)
        completion?(nil, true)
        
        let signupWebService = SignUpWebService()
        signupWebService.signup(signupSendModel!) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            
            if error != nil {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.signUp(false, error), false)
                }
            }
            
            if  let _ = result?["isEmailSent"] as? Int {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.signUp(true, nil), false)
                }
                return
            }
            strongSelf.completion!(.signUp(false, nil), false)
        }
    }
    
    func validateEmail(_ code: String, _ email : String? = nil) {
        var _email = email
        if _email == nil {
            _email = signupSendModel?.email
        }
        completion?(nil, true)
        let signInWebService = ValidateWebService()
        signInWebService.validate(email: _email!, confirmationToken: code) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.validate(error), false)
                }
            }
            
            if  let accessToken = result?["accessToken"] as? String {
                strongSelf.setCredentials(accessToken)
                strongSelf.saveUserProfileData()
                strongSelf.completion!(.validate(nil), false)
                return
            }
            strongSelf.completion!(.signUp(false, nil), false)
        }
    }
    
    func resendEmail(_ email : String? = nil) {
        var _email = email
        if _email == nil {
            _email = signupSendModel?.email
        }
        completion?(nil, true)
        let resendEmailWebService = ResendEmailWebService()
        resendEmailWebService.resendEmail(email: _email!) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            
            if error != nil {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.resend(false, error), false)
                }
            }
            
            if  let isEmailSent = result?["isEmailSent"] as? Int {
                if strongSelf.completion != nil {
                    strongSelf.completion!(.resend(isEmailSent == 1, nil), false)
                }
                return
            }
            strongSelf.completion!(.signUp(false, nil), false)
        }
    }
}

//MARK:- Private func
extension SignupViewModel {
    private func saveUserProfileData() {
        coreDataManager.deleteAllObjects(entityName: EntityName.profile)
        let profile = coreDataManager.insertNewObject(entityName: EntityName.profile) as? Profile
        profile?.name = signupSendModel?.firstName
        profile?.lastName = signupSendModel?.lastName
        coreDataManager.saveContext()
    }
    
    private func setCredentials(_ accessToken: String){
        CredentialsStorage.setCredentialWithKey(accessToken, withKey: .authToken)
        UserDefaults.standard.set(signupSendModel?.email, forKey: UserDefaultsKey.email)
    }
}

//
//  SettingsViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class SettingsViewModel {
    var completion: ((RequestResponseType) -> ())?
    func logout() {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let logoutWebService = LogoutWebService()
        logoutWebService.logout { [weak self] ( success ) in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.logoutHandle()
            } else {
                strongSelf.completion?(.fail(showPopup: true))
            }
        }
    }
    
    func deleteAccount() {
        let logoutWebService = LogoutWebService()
        logoutWebService.deleteAccount { [weak self] ( success ) in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.logoutHandle()
            } else {
                strongSelf.completion?(.fail(showPopup: true))
            }
        }
    }
}

//MARK:- Private Func
extension SettingsViewModel {
    func logoutHandle() {
        CredentialsStorage.clearAll()
        FileManagerSW.manager.removeDirectory(name: FileName.avatar)
        FileManagerSW.manager.removeDirectory(name: FileName.items)
        FileManagerSW.manager.removeDirectory(name: FileName.looks)
        FileManagerSW.manager.removeDirectory(name: FileName.sets)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.wardrobeSyncTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.goal)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.style)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.basic)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.profile)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.selectedCategory)
        CoreDataManager.shared.clearAllCoreData()
        completion?(.success(response: nil))
    }
}

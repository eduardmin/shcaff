//
//  TempViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/21/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class TempViewModel {
    var celsius: Bool = true
    var completion: ((RequestResponseType) -> ())?
    var tempUnits = [("°C", true), ("°F", false)]


    init() {
        getTemp()
    }
    
    func confirm() {
        saveTemp(celsius: celsius)
    }
    
    private func saveTemp(celsius: Bool) {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let tempWebService = TempWebService()
        tempWebService.saveTemp(celsius: celsius) { [weak self] (success) in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.celsius = celsius
                strongSelf.updateTemp()
                strongSelf.updateProfile()
            } else {
                strongSelf.completion?(.fail(showPopup: true))
            }
        }
    }
    
    private func getTemp() {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let tempWebService = TempWebService()
        tempWebService.getTemp { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.fail(showPopup: true))
                return
            }
            if let response = response as? [String: Any] {
                strongSelf.handleResponse(response: response)
                strongSelf.completion?(.success(response: nil))
            }
        }
    }
    
    func selectTemp(indexPath: IndexPath) {
        if indexPath.row == 0 {
            celsius = true
        } else {
            celsius = false
        }
        for i in 0..<tempUnits.count {
            if i == 0 {
                tempUnits[i].1 = celsius
            } else {
                tempUnits[i].1 = !celsius
            }
        }
    }
}

//MARK:- Handle func
extension TempViewModel {
    func handleResponse(response: [String: Any]) {
        if let celsius = response["celsius"] as? Bool {
            self.celsius = celsius
            updateTemp()
        }
    }
    
    func updateTemp() {
        for i in 0..<tempUnits.count {
            if i == 0 {
                tempUnits[i].1 = celsius
            } else {
                tempUnits[i].1 = !celsius
            }
        }
        completion?(.success(response: nil))
    }
    
    func updateProfile() {
        let profile = CoreDataManager.shared.getProfile()
        profile?.celsius = celsius
        UIApplication.appDelegate.profileModel?.celsius = celsius
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateWeather), object: nil, userInfo: nil)
    }
}

//
//  AccountEditViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class AccountEditViewModel {
    private var profileModel: ProfileModel!
    private var imageData: Data?
    private var parameterChange: Bool = false
    private var imageChange: Bool = false
    var tempViewModel: ProfileModel!
    var completion: ((RequestResponseType) -> ())?
    var goalViewModel: GoalViewModel?
    var styleViewModel: StyleViewModel?

    init() {
        profileModel = UIApplication.appDelegate.profileModel
        tempViewModel = ProfileModel(profileModel)
        imageData = profileModel.imageData
    }
    
    func saveProfile() {
        uploadAvatar()
        if !parameterChange {
            saveGoalAndStyle()
           return
        }
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let profileWebService = ProfileWebService()
        profileWebService.updateProfile(profile: tempViewModel) { [weak self] (success) in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.parameterChange = false
                strongSelf.handleUpdateProfile()
                strongSelf.saveGoalAndStyle()
            } else {
                strongSelf.completion?(.fail(showPopup: true))
            }
        }
    }
    
    func uploadAvatar() {
        if let imageData = imageData, imageChange {
            completion?(.start(showLoading: true))
            let avatarUrlWebService = AvatarUrlWebService()
            avatarUrlWebService.getAvatarUrl(method: .PUT) { [weak self] (response, error) in
                guard let strongSelf = self else { return }
                if error != nil {
                    strongSelf.completion?(.fail(showPopup: true))
                    return
                }
                
                if let response = response as? [String: Any], let url = response["url"] as? String {
                    strongSelf.imageChange = false
                    FileUploadDownloadManager.manager.uploadAvatar(url: url, imageData: imageData) { (success) in
                        DispatchQueue.main.async {
                            strongSelf.completion?(.success(response: nil))
                        }
                    }
                }
            }
        }
    }
    
    func saveGoalAndStyle() {
        if goalViewModel != nil || styleViewModel != nil {
            let group = DispatchGroup()
            var success = false
            group.enter()
            saveGoal { (isSuccess) in
                success = isSuccess
                group.leave()
            }
            
            group.enter()
            saveStyle { (isSuccess) in
                success = isSuccess
                group.leave()
            }
            
            group.notify(queue: .main, execute: {
                if success {
                    DispatchQueue.main.async {
                        self.completion?(.success(response: nil))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.completion?(.fail(showPopup: true))
                    }
                }
            })
        }
    }
    
    func saveGoal(completion: @escaping ((Bool) -> ())) {
        if goalViewModel == nil {
            completion(true)
            return
        }
        goalViewModel?.completion = { response in
            switch response {
            case .save(let success):
                completion(success)
                break
            default:
                break
            }
        }
        goalViewModel?.saveGoals()
    }
    
    func saveStyle(completion: @escaping ((Bool) -> ())) {
        if styleViewModel == nil {
            completion(true)
            return
        }
        styleViewModel?.completion = { response in
            switch response {
            case .save(let success):
                completion(success)
                break
            default:
                break
            }
        }
        styleViewModel?.saveStyles()
    }
    
    func setImageData(imageData: Data) {
        imageChange = true
        self.imageData = imageData
    }
    
    func getImageData() -> Data? {
        return imageData
    }
    
    func setInput(type: ProfileType, input: Any?) {
        parameterChange = true
        switch type {
        case .name:
            tempViewModel.name = (input as? String) ?? ""
        case .lastName:
            tempViewModel.lastName = input as? String
        case .birthday:
            if let date = input as? Date {
                tempViewModel.birthDayDate = Int64(date.timeIntervalSince1970)
            }
        default:
            break
        }
    }
    
    func getInput(type: ProfileType) -> String? {
        var input: String?
        switch type {
        case .name:
            input = tempViewModel.name
        case .lastName:
            input = tempViewModel.lastName
        case .email:
            input = UserDefaults.standard.object(forKey: UserDefaultsKey.email) as? String
        default:
            break
        }
        return input
    }
    
    func getDateInput() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(tempViewModel.birthDayDate))
    }
    
    func selectGender(type: ProfileType) -> Bool {
        switch type {
        case .male:
            return profileModel.gender == .male
        case .female:
            return profileModel.gender == .female
        case .other:
            return profileModel.gender == .otherMale || profileModel.gender == .otherFemale || profileModel.gender == .both
        case .otherMale:
            return profileModel.gender == .otherMale
        case .otherFemale:
            return profileModel.gender == .otherFemale
        case .both:
            return profileModel.gender == .both
        default:
            return false
        }
    }
}

//MARK:- Handle
extension AccountEditViewModel {
    private func handleUpdateProfile() {
        profileModel = tempViewModel
        UIApplication.appDelegate.profileModel = tempViewModel
        CoreDataJsonParserManager.shared.updateProfile(profileModel: profileModel)
        completion?(.success(response: nil))
    }
}

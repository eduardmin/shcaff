//
//  ProfileViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/3/20.
//

import UIKit

class ProfileSetViewModel {
    private var profileModel: ProfileModel
    private var profile: Profile?
    private let coreDataManager = CoreDataManager.shared
    var completion :  ((RequestResponseType) -> ())?

    init() {
        profile = coreDataManager.getProfile()
        profileModel = ProfileModel(profile?.name ?? "", profile?.lastName, profile?.gender != 0 ? profile?.gender ?? 1 : 1, profile?.birthDayDate ?? 0, profile?.avatarUrl ?? "")
    }
    
    func setUserProfile(_ date: Double, gender: UserGender) {
        let profileWebService = ProfileWebService()
        profileModel.birthDayDate = Int64(date)
        profileModel.gender = gender
        profileWebService.updateProfile(profile: profileModel) { (success) in
            if success {
                self.updateProfile()
                self.completion?(.success(response: nil))
            } else {
                self.completion?(.fail(showPopup: true))
            }
        }
    }
    
    private func updateProfile() {
        profile?.birthDayDate = profileModel.birthDayDate
        profile?.gender = Int16(profileModel.gender.rawValue)
        coreDataManager.saveContext()
    }
}

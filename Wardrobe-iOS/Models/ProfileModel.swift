//
//  Profile.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/3/20.
//

import UIKit

enum UserGender: Int16 {
    case male = 1
    case female = 2
    case both = 3
    case otherMale = 4
    case otherFemale = 5
}

class ProfileModel {
    var name: String
    var lastName: String?
    var birthDayDate: Int64
    var gender: UserGender
    var avatarUrl: String
    var celsius: Bool = true
    private var avatarExistCheck: Bool = false
    
    var imageData: Data? {
        guard let data = FileManagerSW.manager.getFile(name: FileName.avatar, id: FileName.avatar) else {
            getAvatar()
            return nil
        }
        return data
    }
    
    init(_ name: String, _ lastName: String?, _ gender: Int16, _ birthDayDate: Int64, _ url: String) {
        self.name = name
        self.lastName = lastName
        self.gender = UserGender(rawValue: gender)!
        self.birthDayDate = birthDayDate
        self.avatarUrl = url
    }
    
    init(_ profile: Profile) {
        name = profile.name ?? ""
        lastName = profile.lastName
        gender = UserGender(rawValue: profile.gender)!
        birthDayDate = profile.birthDayDate
        avatarUrl = profile.avatarUrl ?? ""
        celsius = profile.celsius
    }
    
    init(_ profile: ProfileModel) {
        name = profile.name
        lastName = profile.lastName
        gender = profile.gender
        birthDayDate = profile.birthDayDate
        avatarUrl = profile.avatarUrl
        celsius = profile.celsius
    }
    
    func genderId() -> Int16? {
        switch gender {
        case .male, .otherMale:
            return UserGender.male.rawValue
        case .female, .otherFemale:
            return UserGender.female.rawValue
        case .both:
            return nil
        }
    }
    
    func getFullName() -> String {
        return name + " " + (lastName ?? "")
    }
    
    func getGenderTitle() -> String {
        var genderTitle: String = ""
        switch gender {
        case .male:
            genderTitle = "Male".localize()
        case .female:
            genderTitle = "Female".localize()
        case .both, .otherMale, .otherFemale:
            genderTitle = "Other".localize()
        }
        return genderTitle
    }
    
    func getAge() -> Int {
        let dateOfBirth = Date(timeIntervalSince1970: TimeInterval(birthDayDate))
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
                                                        dateOfBirth, to: Date())
        let age = dateComponent.year
        return age ?? 0
    }
    
    func getAvatar() {
        if avatarExistCheck {
            return
        }
        let avatarUrlWebService = AvatarUrlWebService()
        avatarUrlWebService.getAvatarUrl(method: .GET) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            
            if let response = response as? [String: Any], let url = response["url"] as? String {
                FileUploadDownloadManager.manager.downloadAvatar(url: url) { (success) in
                    DispatchQueue.main.async {
                        strongSelf.avatarExistCheck = true
                        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateProfile), object: nil, userInfo: nil)
                    }
                }
            }
        }
    }
}

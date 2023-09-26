//
//  ProfilePersonalViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/5/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class ProfilePersonalViewController: LoginBaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var nameTextField: LoginTextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: LoginTextField!
    @IBOutlet weak var continueButton: UIButton!
    private let settingsViewModel = SettingsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.attributedText = getNavigationTitle("Personal".localize(), "Info".localize())
        lastNameTextField.delegate = self
        nameTextField.delegate = self
        nameTextField.setPlaceHolder(text: "Enter your first name".localize())
        lastNameTextField.setPlaceHolder(text: "Enter your last name".localize())
        continueButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        continueButton.setTitle("Continue".localize(), for: .normal)
        continueButton.enableButton(enable: false)
    }
    

    @IBAction func backAction(_ sender: Any) {
        AlertPresenter.presentInfoAlert(on: self, type: .logout, confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.settingsViewModel.logout()
        })
    }

    @IBAction func changeNameTextFieild(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            continueButton.enableButton(enable: true)
        }
    }
    @IBAction func continueAction(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            var profile = CoreDataManager.shared.getProfile()
            if profile == nil {
                CoreDataJsonParserManager.shared.createProfile([:])
                profile = CoreDataManager.shared.getProfile()
            }
            profile?.name = name
            profile?.lastName = lastNameTextField.text
            CoreDataManager.shared.saveContext()
            let profileVC = ProfileSetViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}


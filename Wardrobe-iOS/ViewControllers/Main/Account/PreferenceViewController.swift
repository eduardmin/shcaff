//
//  PreferenceViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/17/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class PreferenceViewController: BaseNavigationViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    let settingsViewModel = SettingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        settingsViewModel.completion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .start(showLoading: let showLoading):
                strongSelf.start(showLoading: showLoading)
            case .fail(showPopup: let showPopup):
                strongSelf.fail(showPopup: showPopup)
            case .success(response: let response):
                strongSelf.success(response: response)
            }
        }
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        AlertPresenter.presentInfoAlert(on: self, type: .deleteAccount, confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.settingsViewModel.deleteAccount()
        })
    }
    
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .defaultWithBack, title: "Account Preferences".localize(), additionalTopMargin: 16)
        deleteButton.setTitle("Delete Account".localize(), for: .normal)
        textView.text = String(format:  "preference.text".localize(), "\u{2022}", "\u{2022}")       
    }
}

//MARK:- RequestResponseProtocol
extension PreferenceViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        UIApplication.setTabBarRoot()
    }
}

//
//  ChangePasswordViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseNavigationViewController {
    @IBOutlet weak var currentPasswordLabel: UILabel!
    @IBOutlet weak var currentPasswordTextField: LoginTextField!
    @IBOutlet weak var currentShowButton: UIButton!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: LoginTextField!
    @IBOutlet weak var newShowButton: UIButton!
    private var currentShowPassword : Bool = false {
        didSet {
            currentPasswordTextField.isSecureTextEntry = !currentShowPassword
            if currentShowPassword {
                currentShowButton.setTitle("Hide".localize(), for: .normal)
            } else {
                currentShowButton.setTitle("Show".localize(), for: .normal)
            }
        }
    }
    
    private var newShowPassword : Bool = false {
        didSet {
            newPasswordTextField.isSecureTextEntry = !newShowPassword
            if newShowPassword {
                newShowButton.setTitle("Hide".localize(), for: .normal)
            } else {
                newShowButton.setTitle("Show".localize(), for: .normal)
            }
        }
    }
    private let viewModel = ChangePasswordViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.completion = { [weak self] type in
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
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .edit:
            if let current = currentPasswordTextField.text, let new = newPasswordTextField.text {
                viewModel.changePassword(currentPassword: current, newPassword: new)
            }
        default:
            break
        }
    }

    func configureUI() {
        setNavigationView(type: .editType, title: "Password".localize(), additionalTopMargin: 16, "Save".localize())
        hideKeyboardWhenTappedAround()
        rightMode = .passive
        currentPasswordLabel.text = "Current Password".localize()
        newPasswordLabel.text = "New password".localize()
        currentShowButton.setTitle("Show".localize(), for: .normal)
        newShowButton.setTitle("Show".localize(), for: .normal)
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        currentPasswordTextField.setPlaceHolder(text: "Enter your current password".localize())
        newPasswordTextField.setPlaceHolder(text: "Enter your new password".localize())
    }
    
    @IBAction func currentShowAction(_ sender: Any) {
        currentShowPassword = !currentShowPassword
    }
    
    @IBAction func newShowAction(_ sender: Any) {
        newShowPassword = !newShowPassword
    }
}

//MARK:- TextField delegate
extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let current = currentPasswordTextField.text, !current.isEmpty, let new = newPasswordTextField.text, !new.isEmpty {
            rightMode = .active
        }
    }
}

//MARK:- RequestResponseProtocol
extension ChangePasswordViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        navigationController?.popViewController(animated: true)
    }
}


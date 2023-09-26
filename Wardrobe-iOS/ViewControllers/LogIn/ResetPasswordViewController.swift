//
//  ResetPasswordViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/29/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ResetPasswordViewController: LoginBaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resetButtonButtomConstraint: NSLayoutConstraint!
    private var showPassword : Bool = false {
        didSet {
            passwordTextField.isSecureTextEntry = !showPassword
            if showPassword {
                showButton.setTitle("Hide".localize(), for: .normal)
            } else {
                showButton.setTitle("Show".localize(), for: .normal)
            }
        }
    }
    private let viewModel = ChangePasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        configureUI()
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
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureUI() {
        setTitle()
        passwordTextField.delegate = self
        passwordTextField.setPlaceHolder(text: "Enter your password".localize())
        resetButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        resetButton.setTitle("Reset password".localize(), for: .normal)
        descriptionLabel.text = "Create new password and check it by clicking \"show\"".localize()
        newPasswordLabel.text = "New password".localize()
        showButton.setTitle("Show".localize(), for: .normal)
    }
    
    
    private func setTitle() {
        let titleText = "Reset password".localize()
        guard let textRange = titleText.lowercased().range(of: "Reset".localize().lowercased()) else { return  }
        let range = NSRange.init(range: textRange, in: titleText)
        
        let attributedtext = NSMutableAttributedString(string: titleText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.light)])
        attributedtext.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)], range: range)
        titleLabel.attributedText = attributedtext
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Button Action
extension ResetPasswordViewController {
    @IBAction func backClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showClick(_ sender: Any) {
        showPassword = !showPassword
    }
    
    @IBAction func resetClick(_ sender: Any) {
        if let password = passwordTextField.text {
            viewModel.changePassword(currentPassword: nil, newPassword: password, recovery: true)
        }
    }
}

//MARK:- Notification Function
extension ResetPasswordViewController {
    @objc func keyboardWillShow(notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            UIView.animate(withDuration: 1.5) {
                self.resetButtonButtomConstraint.constant = keyboardHeight + 30
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification:Notification) {
        UIView.animate(withDuration: 1.5) {
            self.resetButtonButtomConstraint.constant = 30
        }
    }
}

//MARK:- RequestResponseProtocol
extension ResetPasswordViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        CredentialsStorage.clearAll()
        CoreDataManager.shared.clearAllCoreData()
        navigationController?.popToRootViewController(animated: true)
    }
}



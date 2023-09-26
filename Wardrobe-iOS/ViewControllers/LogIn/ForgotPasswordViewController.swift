//
//  ForgotPasswordViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/29/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: LoginBaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    private var verificationAlertViewController = VerificationAlertViewController()
    private let viewModel = RecoverPasswordViewModel()
    private var signupViewModel: SignupViewModel = SignupViewModel()
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
        
        signupViewModel.completion = {[weak self] (response, startLoading) in
            guard let strongSelf = self else { return }
            if startLoading {
                strongSelf.startRequest()
                return
            }
            switch response {
            case .validate(let error):
                strongSelf.validateHandle(error)
            case .resend(let success, let error):
                strongSelf.resendHandle(success, error)
            default:
                break
            }
        }
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureUI() {
        setTitle()
        emailTextField.delegate = self
        emailTextField.setPlaceHolder(text: "Enter your email".localize())
        continueButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        continueButton.setTitle("Continue".localize(), for: .normal)
        descriptionLabel.text = "Enter your email address associated with your account".localize()
        emailLabel.text = "Email".localize()
    }
    
    
    private func setTitle() {
        let titleText = "Forgot password".localize()
        guard let textRange = titleText.lowercased().range(of: "Forgot".localize().lowercased()) else { return  }
        let range = NSRange.init(range: textRange, in: titleText)
        
        let attributedtext = NSMutableAttributedString(string: titleText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.light)])
        attributedtext.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)], range: range)
        titleLabel.attributedText = attributedtext
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

//MARK:- RequestResponseProtocol
extension ForgotPasswordViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        verificationAlertViewController = AlertPresenter.presentVerificationAlert(on: self, message: "We sent you a code to verify your email".localize(), email: emailTextField.text ?? "")
        verificationAlertViewController.confirmButtonHandler = { [weak self] data in
            guard let strongSelf = self else { return }

            let code = strongSelf.verificationAlertViewController.getCode()
            strongSelf.validateEmail(code)
        }
        
        verificationAlertViewController.resendButtonHandler = { [weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.resendEmail()
        }
        LoadingIndicator.hide(from: view)
    }
    
    private func validateEmail(_ code: String) {
        signupViewModel.validateEmail(code, emailTextField.text ?? "")
    }
    
    private func resendEmail() {
        signupViewModel.resendEmail(emailTextField.text ?? "")
    }
    
    func validateHandle(_ error : ValidateError?) {
        LoadingIndicator.hide(from: view)
        if error != nil {
            // handle error
            AlertPresenter.presentRequestErrorAlert(on: self)
            return
        }
        verificationAlertViewController.dismissViewController()
        let resetPasswordViewController = ResetPasswordViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
        navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
    
    func resendHandle(_ sendEmail : Bool, _ error : ResendEmailError?) {
        LoadingIndicator.hide(from: view)
        if error != nil {
            // handle error
            AlertPresenter.presentRequestErrorAlert(on: self)
            return
        }
    }
    
    func startRequest() {
        LoadingIndicator.show(on: view)
    }
}


//MARK:- Notification Function
extension ForgotPasswordViewController {
    @objc func keyboardWillShow(notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            UIView.animate(withDuration: 1.5) {
                self.continueButtonBottomConstraint.constant = keyboardHeight + 30
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification:Notification) {
        UIView.animate(withDuration: 1.5) {
            self.continueButtonBottomConstraint.constant = 30
        }
    }
}

//MARK:- Button action
extension ForgotPasswordViewController {
    @IBAction func backClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueClick(_ sender: Any) {
        if let email = emailTextField.text {
            viewModel.recover(email: email)
        }
    }
}




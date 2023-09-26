//
//  LoginViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class LoginViewController: LoginBaseViewController {
    
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    private var verificationAlertViewController = VerificationAlertViewController()
    private var showPassword : Bool = false {
        didSet {
            passwordTextField.isSecureTextEntry = !showPassword
            if showPassword {
                showPasswordButton.setTitle("Hide".localize(), for: .normal)
            } else {
                showPasswordButton.setTitle("Show".localize(), for: .normal)
            }
        }
    }
    var disMissComplistion : (() -> ())?
    var viewModel : LoginViewModel = LoginViewModel()
    var signupViewModel: SignupViewModel = SignupViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.completion = {[weak self] (response, startLoading) in
            guard let strongSelf = self else { return }
            if startLoading {
                strongSelf.startRequest()
                return
            }
            
            if let response = response {
                switch response {
                case .signIn(let error):
                    strongSelf.signInHandle(error: error)
                    
                }
            }
        }
        
        viewModel.ssoCompletion = { [weak self] type in
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
    
    private func configureUI() {
        setTitle()
        emailTextField.delegate = self
        emailTextField.setPlaceHolder(text: "Enter your email".localize())
        passwordTextField.setPlaceHolder(text: "Enter your password".localize())
        passwordTextField.delegate = self
        passwordTextField.rigthMargin = showPasswordButton.bounds.width + 20
        facebookButton.layer.cornerRadius = facebookButton.bounds.height / 2
        googleButton.layer.cornerRadius = googleButton.bounds.height / 2
        appleButton.layer.cornerRadius = appleButton.bounds.height / 2
        loginButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        loginButton.setTitle("Log In".localize(), for: .normal)
        let attributedtext = NSMutableAttributedString(string: "Don't have an account?".localize(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.titleColor])
        let createAccountAttributedtext = NSAttributedString(string: " " + "Sign Up".localize(), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.mainColor])
        attributedtext.append(createAccountAttributedtext)
        signUpButton.setAttributedTitle(attributedtext, for: .normal)
        emailTitleLabel.text = "Email".localize()
        passwordTitleLabel.text = "Password".localize()
        showPasswordButton.setTitle("Show".localize(), for: .normal)
        forgotButton.setTitle("Forgot password?".localize(), for: .normal)
    }
    
    private func setTitle() {
        let titleText = "Log in with email".localize()
        guard let textRange = titleText.lowercased().range(of: "Log In".localize().lowercased()) else { return  }
        let range = NSRange.init(range: textRange, in: titleText)

        let attributedtext = NSMutableAttributedString(string: titleText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.light)])
        attributedtext.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)], range: range)
        titleLabel.attributedText = attributedtext
    }
    
    private func dismissErrors() {
        emailTextField.error = false
        passwordTextField.error = false
        errorLabel.isHidden = true
    }
}

//MARK:- Button action
extension LoginViewController {
    @IBAction func loginClick(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            dismissErrors()
            sendLoginRequest(email, password)
        }
    }
    
    @IBAction func forgotClick(_ sender: Any) {
        let forgotPasswordViewController = ForgotPasswordViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    @IBAction func facebookClick(_ sender: Any) {
        viewModel.signInFaceBook()
    }
    
    @IBAction func googleClick(_ sender: Any) {
        viewModel.signInGmail(on: self)
    }
    
    @IBAction func appleClick(_ sender: Any) {
        viewModel.signInApple()
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        let signUpViewController = SignUpViewController.initFromStoryboard(storyBoardName: StoryboardName.login) as SignUpViewController
        signUpViewController.modalPresentationStyle = .overFullScreen
        signUpViewController.disMissComplistion = {
            self.dismiss(animated: true, completion: nil)
        }
        let navigation = UINavigationController(rootViewController: signUpViewController)
        navigation.modalPresentationStyle = .overFullScreen
        navigation.navigationBar.isHidden = true
        present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func showPasswordClick(_ sender: Any) {
        showPassword = !showPassword
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        disMissComplistion?()
    }
}

//MARK:- Send Request
extension LoginViewController {
    func sendLoginRequest(_ email: String, _ password: String) {
        viewModel.signIn(email, password)
    }
}

//MARK:- Handle response
extension LoginViewController {
    func signInHandle(error : SignInError?) {
        LoadingIndicator.hide(from: view)
        if let error = error {
            handle(error: error)
            return
        }
        setUserProfilePreferences()
        UIApplication.setTabBarRoot(rootViewCotroller: navigationController)
    }
    
    func setUserProfilePreferences() {
        if !viewModel.userGoals.isEmpty {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.goal)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.goal)
        }
         
        if !viewModel.userStyles.isEmpty {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.style)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.style)
        }
        
        if viewModel.userHasItems {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.basic)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.basic)
        }
    }
    
    func handle(error : SignInError) {
        switch error {
        case .userNotFound:
            emailTextField.error = true
            passwordTextField.error = true
            errorLabel.isHidden = false
            errorLabel.attributedText = errorMessageAttribute(title: "That account doesn’t exist.", desc: "Enter a different account or a get a new one.")
        case .userBlocked:
            emailTextField.error = true
            passwordTextField.error = true
            errorLabel.isHidden = false
            errorLabel.attributedText = errorMessageAttribute(title: "Oops… You’re blocked.", desc: "For the details try to contact us.")
        case .invalidPassword:
            passwordTextField.error = true
            errorLabel.isHidden = false
            errorLabel.attributedText = errorMessageAttribute(title: "Wrong password.", desc: "Please double-check and try again.")
        case .userIsNotValidated:
            showMailValidateAlert()
            break
        default:
            AlertPresenter.presentRequestErrorAlert(on: self)
            break
        }
    }
    
    func startRequest() {
        LoadingIndicator.show(on: view)
    }
}

//MARK:- RequestResponseProtocol
extension LoginViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        if let newUser = response as? Bool {
            if !newUser {
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.basic)
            } else {
                EventLogger.logEvent("Signup success")
            }
        }
        setUserProfilePreferences()
        UIApplication.setTabBarRoot(rootViewCotroller: navigationController)
    }
}

//MARK:- Validate flow handle
extension LoginViewController {
    
    private func validateEmail(_ code: String) {
        if let email = emailTextField.text {
            signupViewModel.validateEmail(code, email)
        }
    }
    
    private func resendEmail() {
        if let email = emailTextField.text {
            signupViewModel.resendEmail(email)
        }
    }
    
    func resendHandle(_ sendEmail : Bool, _ error : ResendEmailError?) {
        LoadingIndicator.hide(from: view)
        if error != nil {
            // handle error
            AlertPresenter.presentRequestErrorAlert(on: self)
            return
        }
    }

    func validateHandle(_ error : ValidateError?) {
        LoadingIndicator.hide(from: view)
        if error != nil {
            switch error {
            case .wrongConfirmationCode:
                verificationAlertViewController.errorMessage(message: "Wrong confirmation code")
            default:
                break
            }
            return
        }
        verificationAlertViewController.dismissViewController()
        openProfile()
    }

    private func showMailValidateAlert() {
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
    }
    
    private func openProfile() {
        if let profile = CoreDataManager.shared.getProfile(), profile.name != nil {
            let profileSetViewController = ProfileSetViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            navigationController?.pushViewController(profileSetViewController, animated: true)
        } else {
            let profilePersonalViewController = ProfilePersonalViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            navigationController?.pushViewController(profilePersonalViewController, animated: true)
        }
    }
}

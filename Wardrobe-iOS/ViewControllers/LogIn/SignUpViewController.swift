//
//  SignUpViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//

import UIKit

class SignUpViewController: LoginBaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var firstNameTestField: LoginTextField!
    @IBOutlet weak var lastNameTestField: LoginTextField!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
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
    var viewModel: SignupViewModel = SignupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.completion = {[weak self] (response, startLoading) in
            guard let strongSelf = self else { return }
            if startLoading {
                strongSelf.startRequest()
                return
            }
            switch response {
            case .signUp(let sendEmail, let error):
                strongSelf.signUpHandle(sendEmail, error)
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
        passwordTextField.delegate = self
        emailTextField.delegate = self
        lastNameTestField.delegate = self
        firstNameTestField.delegate = self
        
        firstNameTestField.setPlaceHolder(text: "Enter your first name".localize())
        lastNameTestField.setPlaceHolder(text: "Enter your last name".localize())
        passwordTextField.setPlaceHolder(text: "Enter your password".localize())
        emailTextField.setPlaceHolder(text: "Enter your email".localize())
        passwordTextField.rigthMargin = showPasswordButton.bounds.width + 20
        signUpButton.setMode(.background, color: SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        signUpButton.setTitle("Sign Up".localize(), for: .normal)
        let attributedtext = NSMutableAttributedString(string: "Already have an account?".localize(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.titleColor])
        let createAccountAttributedtext = NSAttributedString(string: " " + "Log In".localize(), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.mainColor])
        attributedtext.append(createAccountAttributedtext)
        loginButton.setAttributedTitle(attributedtext, for: .normal)
        emailLabel.text = "Email".localize()
        passwordLabel.text = "Password".localize()
        firstNameLabel.text = "First name".localize()
        showPasswordButton.setTitle("Show".localize(), for: .normal)
        let lastAttibute = NSMutableAttributedString(string: "Last name".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)])
        lastAttibute.append(NSAttributedString(string:" " + "(optional)".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)]))
        lastNameLabel.attributedText = lastAttibute

        let termAttributedtext = NSMutableAttributedString(string: "By signing up, you agree with".localize() + " ", attributes: [NSAttributedString.Key.foregroundColor : SCColors.mainGrayColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)])
        let linkAttributedtext = NSMutableAttributedString(string: "Terms & Conditions".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold), NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        termAttributedtext.append(linkAttributedtext)
        termLabel.attributedText = termAttributedtext
        termLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termAndConditionAction)))
    }
    
    private func setTitle() {
        let titleText = "Sign up with email".localize()
        guard let textRange = titleText.lowercased().range(of: "Sign Up".localize().lowercased()) else { return  }
        let range = NSRange.init(range: textRange, in: titleText)
        
        let attributedtext = NSMutableAttributedString(string: titleText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.light)])
        attributedtext.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)], range: range)
        titleLabel.attributedText = attributedtext
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
        let profileSetViewController = ProfileSetViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
        navigationController?.pushViewController(profileSetViewController, animated: true)
        EventLogger.logEvent("Signup success")
    }
    
    private func dismissErrors() {
        emailTextField.error = false
        passwordTextField.error = false
        errorLabel.isHidden = true
    }
}

//MARK:- button action
extension SignUpViewController {
    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        disMissComplistion?()
    }
    
    @IBAction func showPasswordClick(_ sender: Any) {
        showPassword = !showPassword
    }
    
    @IBAction func signupClick(_ sender: Any) {
        dismissErrors()
        sendSignUp()
    }
    
    @IBAction func loginClick(_ sender: Any) {
        let loginViewController = LoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login) as LoginViewController
        loginViewController.disMissComplistion = {
            self.dismiss(animated: true, completion: nil)
        }
        let navigation = UINavigationController(rootViewController: loginViewController)
        navigation.modalPresentationStyle = .overFullScreen
        navigation.navigationBar.isHidden = true
        present(navigation, animated: true, completion: nil)
    }
    
    @objc func termAndConditionAction() {
        if let url = URL(string: Paths.termCondidionUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//MARK:- Send Request
extension SignUpViewController {
    private func sendSignUp() {
        if let firstName = firstNameTestField.text, let email = emailTextField.text, let password = passwordTextField.text {
            viewModel.singUp(firstName, lastNameTestField.text, email, password)
        }
    }
    
    private func validateEmail(_ code: String) {
        viewModel.validateEmail(code)
    }
    
    private func resendEmail() {
        viewModel.resendEmail()
    }
}

//MARK:- Handle response
extension SignUpViewController {
    func signUpHandle(_ sendEmail : Bool, _ error : SignUpError?) {
        LoadingIndicator.hide(from: view)
        if let error = error {
            handleSignupError(error: error)
            return
        }
        
        if sendEmail {
            showMailValidateAlert()
        }
    }
    
    func handleSignupError(error : SignUpError) {
        switch error {
        case .userExist, .userValideted:
            emailTextField.error = true
            errorLabel.isHidden = false
            errorLabel.attributedText = errorMessageAttribute(title: "User exists.", desc: "An account with that email already exists.")
        case .invalidEmail:
            emailTextField.error = true
            errorLabel.isHidden = false
            errorLabel.attributedText = errorMessageAttribute(title: "Invalid email.", desc: "You’ve entered an invalid email. Please try again.")
        default:
            AlertPresenter.presentRequestErrorAlert(on: self)
            break
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
    
    func startRequest() {
        LoadingIndicator.show(on: view)
    }
}

//
//  LoginAlertViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/11/20.
//

import UIKit

enum LoginAlertType {
    case signIn
    case signUp
}

class LoginAlertViewController: UIViewController {
    @IBOutlet weak var loginEmailButton: UIButton!
    @IBOutlet weak var loginFacebookButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginGoogleButton: UIButton!
    @IBOutlet weak var loginAppleButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginAlertView: UIView!
    var viewModel : LoginViewModel = LoginViewModel()
    var type: LoginAlertType = .signIn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
    }
    
    func configureUI() {
        loginAlertView.layer.cornerRadius = 30
        loginEmailButton.setMode(.passive, color: SCColors.secondaryColor)
        if type == .signIn {
            loginLabel.text = "Log In".localize()
            loginEmailButton.setTitle("Log in with email".localize(), for: .normal)
            loginFacebookButton.setTitle("Log in with Facebook".localize(), for: .normal)
            loginGoogleButton.setTitle("Log in with Google".localize(), for: .normal)
            loginAppleButton.setTitle("Log in with Apple".localize(), for: .normal)
            let attributedtext = NSMutableAttributedString(string: "Don't have an account?".localize(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.titleColor])
            let createAccountAttributedtext = NSAttributedString(string: " " + "Sign Up".localize(), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.secondaryColor])
            attributedtext.append(createAccountAttributedtext)
            createAccountButton.setAttributedTitle(attributedtext, for: .normal)
        } else {
            loginLabel.text = "Sign Up".localize()
            loginEmailButton.setTitle("Continue with email".localize(), for: .normal)
            loginFacebookButton.setTitle("Continue with Facebook".localize(), for: .normal)
            loginGoogleButton.setTitle("Continue with Google".localize(), for: .normal)
            loginAppleButton.setTitle("Continue with Apple".localize(), for: .normal)
            let attributedtext = NSMutableAttributedString(string: "Already have an account?".localize(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.titleColor])
            let createAccountAttributedtext = NSAttributedString(string: " " + "Log In".localize(), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : SCColors.secondaryColor])
            attributedtext.append(createAccountAttributedtext)
            createAccountButton.setAttributedTitle(attributedtext, for: .normal)
        }
        
        loginFacebookButton.layer.cornerRadius = 25
        loginGoogleButton.layer.cornerRadius = 25
        loginAppleButton.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIView.animate(withDuration: 0.3, delay: 0.35,
                       options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        })
        
    }
}

//MARK:- RequestResponseProtocol
extension LoginAlertViewController: RequestResponseProtocol {
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
            }
        }
        setUserProfilePreferences()
        UIApplication.setTabBarRoot()
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
}

//MARK:- Button Action
extension LoginAlertViewController {
    @IBAction func loginEmailClick(_ sender: Any) {
        if type == .signIn {
            let loginViewController = LoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            let navigation = UINavigationController(rootViewController: loginViewController)
            navigation.modalPresentationStyle = .overFullScreen
            navigation.navigationBar.isHidden = true
            present(navigation, animated: true, completion: nil)
        } else {
            let signUpViewController = SignUpViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            let navigation = UINavigationController(rootViewController: signUpViewController)
            navigation.modalPresentationStyle = .overFullScreen
            navigation.navigationBar.isHidden = true
            present(navigation, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginFacebookClick(_ sender: Any) {
        viewModel.signInFaceBook()
    }
    
    @IBAction func loginGoogleClick(_ sender: Any) {
        viewModel.signInGmail(on: self)
    }
    
    @IBAction func loginAppleClick(_ sender: Any) {
        viewModel.signInApple()
    }
    
    @IBAction func createAccountClick(_ sender: Any) {
        type = type == .signUp ? .signIn : .signUp
        configureUI()
    }
    
    @IBAction func tapHandle(_ sender: Any) {
        view.backgroundColor = UIColor.clear
        dismiss(animated: true, completion: nil)
    }
}

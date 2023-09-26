//
//  SignUpViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

enum LoginResponse {
    case signIn(SignInError?)
}

class LoginViewModel: NSObject {
    var user: User?
    var completion : ((LoginResponse?, Bool) -> ())?
    var ssoCompletion: ((RequestResponseType) -> ())?
    private var profileModel: ProfileModel?
    public var userHasItems: Bool = false
    public var userGoals: [Int] = [Int]()
    public var userStyles: [Int] = [Int]()

    func signIn(_ email : String, _ password : String) {
        user = User(email: email, password: password)
        completion?(nil, true)
        let signInWebService = SignInWebService()
        signInWebService.signIn(user!) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                if strongSelf.completion != nil {
                    strongSelf.completion?(.signIn(error), false)
                    return
                }
            }
            
            if let result = result {
                if let accessToken = result["accessToken"] as? String {
                    strongSelf.setCredentials(accessToken)
                }
                
                if let profileDict = result["profile"] as? [String: Any] {
                    CoreDataJsonParserManager.shared.createProfile(profileDict)
                } else {
                    CoreDataManager.shared.deleteAllObjects(entityName: EntityName.profile)
                }
                
                strongSelf.userGoals = (result["userGoals"] as? [Int]) ?? []
                strongSelf.userStyles = (result["userStyles"] as? [Int]) ?? []
                let hasItems = (result["userHasItems"] as? Int) ?? 0
                strongSelf.userHasItems = hasItems == 1
                strongSelf.completion?(.signIn(nil), false)
                return
            }
            
            strongSelf.completion?(.signIn(SignInError.failError), false)
        }
    }
    
    func signInFaceBook() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email", "public_profile"], from: nil) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if error != nil || (result != nil && result!.isCancelled) {
                return
            }
            if let token = AccessToken.current?.tokenString {
                strongSelf.fetchUserProfile(token: token)
            }
        }
    }
    
    func signInGmail(on viewController: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signInApple() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sendSsoRequest(name: String?, lastName: String?, imageData: Data?, _ idToken: String, _ type: SsoType, _ email: String? = nil) {
        ssoCompletion?(.start(showLoading: true))
        if !haveConnection() {
            ssoCompletion?(.fail(showPopup: true))
        }
        let signInWebService = SignInWebService()
        signInWebService.ssoSignIn(name: name, lastName: lastName, idToken, type) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if error != nil || result == nil {
                strongSelf.ssoCompletion?(.fail(showPopup: true))
                return
                
            }
            
            if let accessToken = result?["accessToken"] as? String {
                strongSelf.setCredentials(accessToken, email)
            }
            
            if let profileDict = result?["profile"] as? [String: Any] {
                CoreDataJsonParserManager.shared.createProfile(profileDict)
            } else {
                CoreDataManager.shared.deleteAllObjects(entityName: EntityName.profile)
            }
            var newUser: Bool = false
            if let new = result?["newUser"] as? Int {
                newUser = new == 1
            }
            strongSelf.userGoals = (result?["userGoals"] as? [Int]) ?? []
            strongSelf.userStyles = (result?["userStyles"] as? [Int]) ?? []
            let hasItems = (result?["userHasItems"] as? Int) ?? 0
            strongSelf.userHasItems = hasItems == 1
            if let profileDict = result?["profile"] as? [String: Any], let url = profileDict["avatarUrl"] as? String, let imageData = imageData {
                FileUploadDownloadManager.manager.uploadAvatar(url: url, imageData: imageData) { (isSuccess) in
                    DispatchQueue.main.async {
                        if isSuccess {
                            strongSelf.ssoCompletion?(.success(response: newUser))
                            
                        } else {
                            strongSelf.ssoCompletion?(.fail(showPopup: true))
                        }
                    }
                }
            } else {
                strongSelf.ssoCompletion?(.success(response: newUser))
            }
        }
    }
}

//MARK:- Private func
extension LoginViewModel {
    private func setCredentials(_ accessToken: String, _ email: String? = nil){
        CredentialsStorage.setCredentialWithKey(accessToken, withKey: .authToken)
        UserDefaults.standard.set(email ?? user?.email, forKey: UserDefaultsKey.email)
    }
    
    private func downloadAvatar(url: URL?, completion: @escaping (Data?) -> ()) {
        if let imageUrl = url {
            DispatchQueue.global().async {
                let imageData = NSData(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    completion(imageData as Data?)
                }
            }
        } else {
            completion(nil)
        }
    }
}

//MARK:- GIDSignInDelegate
extension LoginViewModel: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("there was error with google sign in: \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        if let token = authentication.idToken {
            if user.profile.hasImage {
                let url = user.profile.imageURL(withDimension: 100)
                downloadAvatar(url: url) { [weak self] (data) in
                    self?.sendSsoRequest(name: user.profile.givenName, lastName: user.profile.familyName, imageData: data, token, .google, user.profile.email)
                }
            } else {
                sendSsoRequest(name: user.profile.givenName, lastName: user.profile.familyName, imageData: nil, token, .google, user.profile.email)
            }
        }
    }
}

//MARK:- ASAuthorizationControllerDelegate
extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            if let idTokenData = appleIDCredential.identityToken, let idToken = String(data: idTokenData, encoding: .utf8) {
                var name: String?
                var lastName: String?
                let email: String? = appleIDCredential.email
                if let profile = appleIDCredential.fullName {
                    name = profile.givenName
                    lastName = profile.familyName
                }
                sendSsoRequest(name: name, lastName: lastName, imageData: nil, idToken, .apple, email)
            }
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}

//MARK - Facebook
extension LoginViewModel {
    func fetchUserProfile(token: String) {
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name, picture.width(100).height(100)"])
        graphRequest.start(completionHandler: { [weak self] (connection, result, error) -> Void in
            guard let strongSelf = self else { return }
            if ((error) != nil) {
                print("Error took place: \(String(describing: error))")
            } else {
                if let result = result as? [String: Any] {
                    let name = result["first_name"] as? String
                    let lastName = result["last_name"] as? String
                    let email = result["email"] as? String
                    if let profilePictureObj = result["picture"] as? NSDictionary {
                        let data = profilePictureObj["data"] as! NSDictionary
                        let pictureUrlString  = data["url"] as! String
                        let pictureUrl = URL(string: pictureUrlString)
                        strongSelf.downloadAvatar(url: pictureUrl) { (imageData) in
                            strongSelf.sendSsoRequest(name: name, lastName: lastName, imageData: imageData, token, .facebook, email)
                        }
                    } else {
                        strongSelf.sendSsoRequest(name: name, lastName: lastName, imageData: nil, token, .facebook, email)
                    }
                }
            }
        })
    }
}

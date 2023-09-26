//
//  UIApplicationExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/31/20.
//

import Foundation
import UIKit

extension UIApplication {

    static var appDelegate: AppDelegate {
        return shared.delegate as! AppDelegate
    }
    
    static func setRootController(_ viewController: UIViewController) {
        shared.windows.first?.rootViewController = viewController
    }
    
    static func setTabBarRoot(rootViewCotroller: UINavigationController? = nil) {
        if !isSignIn() {
            let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
            UIApplication.setRootController(welcomeVC)
            return
        }
        if let profile = CoreDataManager.shared.getProfile(), profile.birthDayDate != 0 {
            appDelegate.profileModel = ProfileModel(profile)
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.basic) {
                appDelegate.synchronizationManager.loginFinish()
                appDelegate.pandingManager.loginFinish()
                NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateProfile), object: nil, userInfo: nil)
                appDelegate._tabBarController = TabBarController.initFromStoryboard()
                setRootController(appDelegate.tabBarController)
            } else if UserDefaults.standard.bool(forKey: UserDefaultsKey.style) {
                let basicVC = BasicViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                if let rootViewCotroller = rootViewCotroller {
                    rootViewCotroller.pushViewController(basicVC, animated: true)
                } else {
                    let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                    let navigation = UINavigationController(rootViewController: welcomeVC)
                    navigation.navigationBar.isHidden = true
                    UIApplication.setRootController(navigation)
                    navigation.pushViewController(basicVC, animated: false)
                }
            } else if UserDefaults.standard.bool(forKey: UserDefaultsKey.goal) {
                let styleVC = StyleViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                if let rootViewCotroller = rootViewCotroller {
                    rootViewCotroller.pushViewController(styleVC, animated: true)
                } else {
                    let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                    let navigation = UINavigationController(rootViewController: welcomeVC)
                    navigation.navigationBar.isHidden = true
                    UIApplication.setRootController(navigation)
                    navigation.pushViewController(styleVC, animated: false)
                }
            } else {
                let goalVC = GoalViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                if let rootViewCotroller = rootViewCotroller {
                    rootViewCotroller.pushViewController(goalVC, animated: true)
                } else {
                    let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                    let navigation = UINavigationController(rootViewController: welcomeVC)
                    navigation.navigationBar.isHidden = true
                    UIApplication.setRootController(navigation)
                    navigation.pushViewController(goalVC, animated: false)
                }
            }
        } else {
            if let profile = CoreDataManager.shared.getProfile(), profile.name != nil {
                let profileVC = ProfileSetViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                if let rootViewCotroller = rootViewCotroller {
                    rootViewCotroller.pushViewController(profileVC, animated: true)
                } else {
                    let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                    let navigation = UINavigationController(rootViewController: welcomeVC)
                    navigation.navigationBar.isHidden = true
                    UIApplication.setRootController(navigation)
                    navigation.pushViewController(profileVC, animated: false)
                }
            } else {
                let profilePersonalVC = ProfilePersonalViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                if let rootViewCotroller = rootViewCotroller {
                    rootViewCotroller.pushViewController(profilePersonalVC, animated: true)
                } else {
                    let welcomeVC = WelcomeLoginViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                    let navigation = UINavigationController(rootViewController: welcomeVC)
                    navigation.navigationBar.isHidden = true
                    UIApplication.setRootController(navigation)
                    navigation.pushViewController(profilePersonalVC, animated: false)
                }
            }
        }
    }
}

//
//  AppDelegate.swift
//  Wardrobe-iOS
//
//  Created by Mariam Khachatryan on 3/28/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var _tabBarController: TabBarController?
    var tabBarController: TabBarController {
        return _tabBarController ?? TabBarController()
    }
    let locationManager = LocationManager.manager
    var reachabilityHandler = ReachabilityHandler()
    let synchronizationManager = SynchronizationManager()
    let pandingManager = PendingSendSyncManager()
    var profileModel: ProfileModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 0.3)
        checkFirstInit()
        LanguageManager.manager.setInitialLanguage()
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions)
        configureSSO()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { (granted, error) in
                print("access granted!")
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("Registered: \(UIApplication.shared.isRegisteredForRemoteNotifications)")
                }
            })
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState != .active {
            print("")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(token, forKey: UserDefaultsKey.push)
    }
    
    // MARK: - Application's Documents directory
    var applicationDocumentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }
    
    private func checkFirstInit() {
        if UserDefaults.standard.object(forKey: UserDefaultsKey.firstInit) == nil {
            CredentialsStorage.clearAll()
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.firstInit)
        }
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    // MARK: - SSO configuration
    func configureSSO() {
        GIDSignIn.sharedInstance().clientID = "355182547386-t0uo01bjeksqu228m1g46j076btpr0jn.apps.googleusercontent.com"

    }
    
    // Called when the app is in Background state
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let title = alert["title-loc-key"] as? String, title.contains("survey") {
            tabBarController.openFeadBack()
        }
    }
}


//
//  BaseNavigationViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/1/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UIViewController {

    //MARK:- Private properties
    private var navigationView: NavigationView? = nil
    public var navigationViewMaxY: CGFloat {
        return navigationView != nil ? 50 : 0
    }
    
    //MARK:- Public properties
    public var navigationTitle: String = "" {
        didSet {
            navigationView?.setTitle(navigationTitle)
        }
    }
    
    public var weatherText: NSAttributedString = NSAttributedString()  {
        didSet {
            navigationView?.setWeatherText(weatherText)
        }
    }
    
    public var rightMode: SaveButtonMode = SaveButtonMode.normal  {
        didSet {
            navigationView?.setRightButtonMode(rightMode)
        }
    }
    
    public var avatarImage: UIImage? = nil {
        didSet {
            navigationView?.setAvatarImage(avatarImage)
        }
    }
    
    public var badge: Bool = false {
        didSet {
            navigationView?.setBadge(badge: badge)
        }
    }

    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.removeFromSuperview()
        view.backgroundColor = SCColors.whiteColor
    }
    
    func didSelectNavigationAction(action: NavigationAction)  {
        print("didSelectNavigationAction \(action)")
    }
}

//MARK:- Private functions
extension BaseNavigationViewController {
    
    func setNavigationView(type: NavigationType, title: String? = nil, attibuteTitle: NSAttributedString? = nil, additionalTopMargin: CGFloat = 0, _ rigthButtonTitle: String? = nil) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 50 + additionalTopMargin, left: 0, bottom: 0, right: 0)
        navigationView?.removeFromSuperview()
        navigationView = NavigationView(type: type, title: title, attibuteTitle: attibuteTitle, rigthButtonTitle)
        navigationView?.delegate = self
        if let navigationView = navigationView {
            self.view.addSubview(navigationView)
            navigationView.translatesAutoresizingMaskIntoConstraints = false
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            navigationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            navigationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        }
    }
}
 
//MARK:- NavigationViewDelegate
extension BaseNavigationViewController: NavigationViewDelegate {
    func navigationViewDidSelectAction(action: NavigationAction) {
        didSelectNavigationAction(action: action)
    }
}

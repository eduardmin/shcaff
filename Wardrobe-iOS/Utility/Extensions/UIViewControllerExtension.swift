//
//  UIViewControllerExtension.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 6/7/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {    
    static func initFromNib<T: UIViewController>() -> T {
        return self.init(nibName: String(describing: self), bundle: nil) as! T
    }
    
    static func initFromStoryboard<T: UIViewController>(storyBoardName: String = "Main") -> T {
        let storyboard = UIStoryboard.init(name: storyBoardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
    }
}

extension UINavigationController {
    open override var hidesBottomBarWhenPushed: Bool {
        didSet {
            if hidesBottomBarWhenPushed {
                UIApplication.appDelegate.tabBarController.hideTab()
            } else {
                UIApplication.appDelegate.tabBarController.showTab()
            }
        }
    }
}


extension UIViewController {
    
    func addEmptyView(title : String, description : String, insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), backgroundColor : UIColor? = nil) {
        let emptyView = EmptyView.instanceFromNib()
        emptyView.configure(title: title, description: description)
        emptyView.isHidden = true
        if backgroundColor != nil {
            emptyView.backgroundColor = backgroundColor
        }
        view.addSubview(emptyView)
        let metrics = ["top" : insets.top, "bottom" : insets.bottom, "right" : insets.right, "left" : insets.left]
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[emptyView]-(right)-|", options: [], metrics: metrics, views: ["emptyView" : emptyView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[emptyView]-(bottom)-|", options: [], metrics: metrics, views: ["emptyView" : emptyView]))
    }
    
    func changeTitle(title: String, description : String) {
        let emptyArray = view.subviews.filter({$0 is EmptyView})
        if let emptyView = emptyArray.first as? EmptyView{
            emptyView.configure(title: title, description: description)
        }
    }
    
    func showHideEmptyView(isHide : Bool) {
        let emptyArray = view.subviews.filter({$0 is EmptyView})
        if let emptyView = emptyArray.first{
            emptyView.isHidden = isHide
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

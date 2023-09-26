//
//  SCTabPageViewController.swift
//  TabBar
//
//  Created by Eduard on 5/22/20.
//  Copyright © 2020 Eduard. All rights reserved.
//

import UIKit

struct TabPage {
    var tabTitle: String!
    var viewController: UIViewController!
}

enum TabPageType {
    case home
    case cloth
}

class SCTabPageViewController: BaseNavigationViewController {
    //MARK:- Properties
    private var tabBar: SCTabBar!
    private var pageViewController: SCPageViewController!
    private var tabPages: [TabPage]! = []
    private var type: TabPageType = .home
    
    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- Public functions
    func setTabPages(_ tabPages: [TabPage], type: TabPageType = .home)  {
        self.tabPages = tabPages
        self.type = type
        configureViews()
    }
}

//MARK:- Private functions
extension SCTabPageViewController {
    private func configureViews() {
        if tabPages.isEmpty { return }
        
        addPageViewController()
        addTabBar()
        configureConstraints()
    }
    
    private func addTabBar() {
        let titles = tabPages.map({ (tabPage: TabPage) -> String in
            tabPage.tabTitle
        })

        tabBar = SCTabBar(titles: titles)
        tabBar.delegate = self
        view.addSubview(tabBar)
    }
    
    private func addPageViewController() {
        let viewControllers = tabPages.map({ (tabPage: TabPage) -> UIViewController in
            tabPage.viewController
        })

        pageViewController = SCPageViewController(presentingViewControllers: viewControllers)
        pageViewController.transitionDelegate = self
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    private func configureConstraints() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        let topMargin = type == .home ? -10 : 0
        let metrics = ["tabBarHeight" : 50, "topMargin": topMargin]
        let views = ["tabBar" : tabBar, "pageViewController" : pageViewController.view] as! [String: UIView]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[tabBar]-(0)-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[pageViewController]-(0)-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tabBar(==tabBarHeight)]-(topMargin)-[pageViewController]-|", options: [], metrics: metrics, views: views))
    }
    
    private func setSelectedTabPage(index: Int) {
        tabBar.select(index: index)
        pageViewController.selectPage(at: index)
    }
}

//MARK:- SCPageViewControllerTransitionDelegate
extension SCTabPageViewController: SCPageViewControllerTransitionDelegate {
    func pageViewController(_ pageViewController: SCPageViewController, didScrollTo index: Int) {
        setSelectedTabPage(index: index)
    }
}

//MARK:- SCTabBarDelegate
extension SCTabPageViewController: SCTabBarDelegate {
    func scTabBar(tabBar: SCTabBar, didSelectItemAt index: Int) {
        setSelectedTabPage(index: index)
    }
}

//
//  TabBarController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/20/20.
//

import UIKit

class TabBarController: UITabBarController {
    private var homeViewController: HomeViewController!
    private var calendarViewController: CalendarViewController!
    private var selectedTabIndex: TabBarItemIndex = .home
    private var viewCustomeTab : CustomTabView!
    lazy var noInternetLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = SCColors.deleteColor
        label.textColor = SCColors.whiteColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Oops… It seems you’re not connected to the internet".localize()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(Constants.tabBarHeight + bottomPadding + 20)).isActive = true
        label.heightAnchor.constraint(equalToConstant: 54).isActive = true
        label.layer.cornerRadius = 27
        label.layer.masksToBounds = true
        return label
    }()
    
    private var bottomPadding: CGFloat {
        let window = UIApplication.shared.windows.first
        let bottomPadding : CGFloat = window?.safeAreaInsets.bottom ?? 0
        return bottomPadding
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewController = HomeViewController.initFromStoryboard()
        calendarViewController = CalendarViewController.initFromStoryboard()
        noInternetLabel.isHidden = true
        handleTabBarClick(index: .home)
        createTabBar()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        noInternetLabel.isHidden = isReachable == 1
    }
    
    private func createTabBar()
    {
        viewCustomeTab = CustomTabView.instanceFromNib()
        viewCustomeTab.translatesAutoresizingMaskIntoConstraints = false
        viewCustomeTab.delegate = self
        view.addSubview(viewCustomeTab)
        let guide = view.safeAreaLayoutGuide
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight, right: 0)
        NSLayoutConstraint.activate([view.bottomAnchor.constraint(equalToSystemSpacingBelow: viewCustomeTab.bottomAnchor, multiplier: 0), viewCustomeTab.leadingAnchor.constraint(equalToSystemSpacingAfter: guide.leadingAnchor, multiplier: 0), guide.trailingAnchor.constraint(equalToSystemSpacingAfter: viewCustomeTab.trailingAnchor, multiplier: 0), viewCustomeTab.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight + bottomPadding),
        ])
    }
    
}

//MARK:- Public Func
extension TabBarController {
    func hideTab() {
        viewCustomeTab.isHidden = true
    }
    
    func showTab() {
        viewCustomeTab.isHidden = false
    }
}

//MARK:- Custom Tab delegate
extension TabBarController : CustomTabViewDelegate {

    func handleTabBarClick(index: TabBarItemIndex) {
        var viewController : UIViewController
        switch index {
        case .home:
            viewController = homeViewController
            if selectedTabIndex == index {
                homeViewController.selectHomeTab()
            }
        case .search:
            viewController = SearchViewController.initFromStoryboard()
        case .wardrobe:
            viewController = ClosetViewController.initFromStoryboard()
        case .calendar:
            calendarViewController.viewModel.setWeatherModel(homeViewController.getWeatherModel())
            viewController = calendarViewController
        }
        self.selectedTabIndex = index
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.navigationBar.isHidden = true
        self.viewControllers = [navigation]
    }
}

//MARK:- Custom Tab delegate
extension TabBarController {
    func goCalendarTab(by notification: NotificationModel) {
        viewCustomeTab.selectedIndex = .calendar
        handleTabBarClick(index: .calendar)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.calendarViewController.selectEventWithNotification(model: notification)
        }
    }
    
    func openFeadBack() {
        homeViewController.feadBackPuchReceive = true
    }
}

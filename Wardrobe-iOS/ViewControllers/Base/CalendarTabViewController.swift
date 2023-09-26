//
//  CalendarTabViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/2/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class CalendarTabViewController: BaseNavigationViewController {
    private var tabBar: CalendarTabBar?
    var tabBarConstraints: [NSLayoutConstraint]?
    var selectedDate: Date = Date() 
    var type: CalendarViewType = .calendar
    let viewModel = CalendarEventViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
    }
    
    func setCalendarTabBar(_ title: String) {
        configureViews()
        tabBar?.setTodayDayTitle(title)
    }
    
    func selectTabDate(date: Date) {
        selectedDate = date
        tabBar?.setSelectedDate(selectedDate)
    }
    
    func updateTab() {
        tabBar?.updateWeakCollection()
    }
}

//MARK:- Private func
extension CalendarTabViewController {
    private func configureViews() {
        tabBar?.setType(type)
        configureConstraints()
    }
    
    private func addTabBar() {
        tabBar = CalendarTabBar()
        tabBar?.delegate = self
        tabBar?.viewModel = viewModel
        view.addSubview(tabBar!)
    }
    
    
    private func configureConstraints() {
        tabBar!.translatesAutoresizingMaskIntoConstraints = false
        var metrics: [String: Any]
        if type == .calendar {
            metrics = ["tabBarHeight" : 50]
        } else {
            metrics = ["tabBarHeight" : 111]
        }
        let views = ["tabBar" : tabBar!] as [String: UIView]
        if tabBarConstraints != nil {
            view.removeConstraints(tabBarConstraints!)
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[tabBar]-(0)-|", options: [], metrics: metrics, views: views))
        tabBarConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tabBar(==tabBarHeight)]", options: [], metrics: metrics, views: views)
        view.addConstraints(tabBarConstraints!)

    }
}

extension CalendarTabViewController: CalendarTabBarDelete {
    func selectDate(_ date: Date) {}
    
    func setMonthTitle(_ month: String) {
        navigationTitle = month
    }
    
    func didSetToday() {
        didSelectNavigationAction(action: .today)
    }
    
}
 

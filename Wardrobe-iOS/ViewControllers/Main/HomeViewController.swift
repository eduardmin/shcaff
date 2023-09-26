//
//  HomeViewController.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 5/1/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class HomeViewController: SCTabPageViewController {
        
    let weatherViewModel = WeatherViewModel()
    private let surveysViewModel = SurveysViewModel()
    public var feadBackPuchReceive: Bool = false
    @IBOutlet weak var feadbackView: UIView!
    @IBOutlet weak var feadbackLabel: UILabel!
    private var notificationError = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationView(type: .defaultWithAvatar, title: "Hello".localize() + ", " + getName())
        setTabPages([TabPage(tabTitle: "For you", viewController: WhatToWearViewController()),
                     TabPage(tabTitle: "Explore", viewController: ExploreViewController())])
        avatarImage = getAvatarImage()
        feadbackView.isHidden = true
        addObserver()
        addNotification()
        configureEmptyWeather()
        getNotification()
    }
    
    
    private func addObserver() {
        weatherViewModel.weatherCompletion = { [weak self] weatherModel in
            guard let strongSelf = self else { return }
            strongSelf.handleWeather(weatherModel)
        }
        
        surveysViewModel.updateSurvey.bind { [weak self] update in
            guard let strongSelf = self else { return }
            if update {
                strongSelf.configueFeadBackView()
            } else {
                strongSelf.feadBackPuchReceive = false
            }
        }
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .avatar:
            openAccountViewController()
        case .notification:
            openNotificationViewController()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if notificationError {
            getNotification()
        }
    }
    
    private func getNotification() {
        let notificationViewModel = NotificationViewModel()
        notificationViewModel.haveNotification { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.notificationError = true
                return
            }
            strongSelf.badge = success
        }
    }
    
    private func configureEmptyWeather() {
        let attributedString = createAttributedWithNoWeather()
        weatherText = attributedString
    }
    
    private func handleWeather(_ weatherModel: WeatherModel) {
        let attributedString = createAttributedWithWeather(weatherModel)
        weatherText = attributedString
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: NotificationName.updateProfile), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: NSNotification.Name(rawValue: NotificationName.badge), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeather), name: NSNotification.Name(rawValue: NotificationName.updateWeather), object: nil)

    }
    
    @objc func updateProfile() {
        avatarImage = getAvatarImage()
    }
    
    @objc func updateBadge() {
        badge = false
    }
    
    @objc func languageChanged(notification:Notification)  {
        if let weatherModel = weatherViewModel.weatherModel {
            handleWeather(weatherModel)
        } else {
            configureEmptyWeather()
        }
        
        if surveysViewModel.surveyModel != nil {
            feadbackLabel.text = surveysViewModel.surveyModel?.displayName
        }
    }
    
    @objc func updateWeather() {
        if let weatherModel = weatherViewModel.weatherModel {
            handleWeather(weatherModel)
        } else {
            configureEmptyWeather()
        }
    }
    
    private func openAccountViewController() {
        let accountVC = AccountViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
        let navigationController = UINavigationController(rootViewController: accountVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true, completion: nil)
        EventLogger.logEvent("Account action")
    }
    
    private func openNotificationViewController() {
        let notificationVC = NotificationViewController.initFromStoryboard()
        let navigationController = UINavigationController(rootViewController: notificationVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true, completion: nil)
    }
    
    private func getName() -> String {
        return UIApplication.appDelegate.profileModel?.name ?? ""
    }
    
    private func getAvatarImage() -> UIImage? {
        if let data = UIApplication.appDelegate.profileModel?.imageData {
            return UIImage(data: data)
        }
        return nil
    }
    
    public func getWeatherModel() -> WeatherModel? {
        return weatherViewModel.weatherModel
    }
    
    private func configueFeadBackView() {
        if surveysViewModel.surveyModel != nil {
            feadbackView.isHidden = false
            view.bringSubviewToFront(feadbackView)
            feadbackLabel.text = surveysViewModel.surveyModel?.displayName
            feadbackView.addShadow(true, 3, 6)
            feadbackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(feadBackAction)))
            if feadBackPuchReceive {
                feadBackAction()
            }
        }
    }
    
    @objc private func feadBackAction() {
       let alert = AlertPresenter.presentFeadbackAlert(on: self, surveyViewModel: surveysViewModel)
        alert.confirmSuccessHandler = { [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.feadbackView.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Public func
extension HomeViewController {
    func selectHomeTab() {
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.scrollToCollection), object: nil, userInfo: nil)
    }
}

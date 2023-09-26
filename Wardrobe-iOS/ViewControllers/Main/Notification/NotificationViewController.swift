//
//  NotificationViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/16/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class NotificationViewController: BaseNavigationViewController {
    private let cellHeight: CGFloat = 135
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = NotificationViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.completion = { [weak self] type in
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
        start(showLoading: true)
        viewModel.getNotifictions()
        viewModel.updateSeenNotifications()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            dismiss(animated: true, completion: nil)
        case .edit:
            let settingsEditVC = SettingsViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
            navigationController?.pushViewController(settingsEditVC, animated: true)
        default:
            break
        }
    }
    
    private func configureUI() {
        setNavigationView(type: .notification, title: "Notifications".localize(), additionalTopMargin: 16)
        addEmptyView(title: "No notifications yet".localize(), description: "", insets: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0))
        showHideEmptyView(isHide: true)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: NotificationTableViewCell.self)
        tableView.register(cell: LoadingTableViewCell.self)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewModel.notificationModels.isEmpty {
            return viewModel.loadMore ? viewModel.notificationModels.count + 1 : viewModel.notificationModels.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.notificationModels.count == indexPath.row && viewModel.notificationModels.count != 0 && viewModel.loadMore {
            let cell: LoadingTableViewCell = tableView.dequeueReusableCell(LoadingTableViewCell.self) as LoadingTableViewCell
            cell.startAnimating()
            loadingMore()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(NotificationTableViewCell.self) as NotificationTableViewCell
        let notification = viewModel.notificationModels[indexPath.row]
        cell.configure(model: notification)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = viewModel.notificationModels[indexPath.row]
        switch notification.type {
        case .eventReminder:
            dismiss(animated: false, completion: nil)
            UIApplication.appDelegate.tabBarController.goCalendarTab(by: notification)
        case .suggestion:
            if let lookId = notification.lookId, let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell, let image = cell.lookImageView.image {
                let lookController: LookViewController = LookViewController.initFromNib()
                let lookModel = LookModelSuggestion(id: lookId, url: notification.url ?? "", aspectRation: notification.aspectRation ?? "1:1")
                let lookDetailViewModel = LookDetailViewModel(selectedLookModel: lookModel, looksModel: [lookModel], image: image)
                lookDetailViewModel.isLoadMore = false
                lookController.lookDetailViewModel = lookDetailViewModel
                let navigationViewController = UINavigationController(rootViewController: lookController)
                navigationViewController.modalPresentationStyle = .overFullScreen
                navigationViewController.modalTransitionStyle = .coverVertical
                navigationViewController.navigationBar.isHidden = true
                present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- RequestResponseProtocol
extension NotificationViewController: RequestResponseProtocol {
    func loadingMore() {
        viewModel.loadMoreNotification()
    }
    
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        showHideEmptyView(isHide: viewModel.notificationModels.count != 0)
        LoadingIndicator.hide(from: view)
        tableView.reloadData()
    }
}

//
//  AccountViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//
import UIKit

enum AccountTableViewType: Int {
    case total
    case statistic
    case most
    case less
    case last
}

class AccountViewController: BaseNavigationViewController {

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptonLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarHeightConstrait: NSLayoutConstraint!
    private let viewModel = AccountViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        configureUI()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: NotificationName.updateProfile), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
    
    @objc func updateProfile() {
        viewModel.updateProfile()
        if let imageData = viewModel.getImageData() {
            updateImage(image: UIImage(data: imageData))
        } else {
            updateImage(image: nil)
        }
        nameLabel.text = viewModel.getFullName()
        descriptonLabel.text = viewModel.getGenderAndDate()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            dismiss(animated: true, completion: nil)
        case .edit:
            let settingsEditVC = SettingsViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
            navigationController?.pushViewController(settingsEditVC, animated: true)
            EventLogger.logEvent("Settings action")
        default:
            break
        }
    }
    
    private func configureUI() {
        setNavigationView(type: .account, title: "Account".localize(), additionalTopMargin: 16)
        nameLabel.text = viewModel.getFullName()
        descriptonLabel.text = viewModel.getGenderAndDate()
        editButton.setMode(.background, color: SCColors.whiteColor)
        editButton.setTitle("Edit Account".localize(), for: .normal)
        if let imageData = viewModel.getImageData() {
            updateImage(image: UIImage(data: imageData))
        } else {
            updateImage(image: nil)
        }
        tableView.separatorStyle = .none
        tableView.register(cell: ColorStatisticTableViewCell.self)
        tableView.register(cell: TotalClothTableViewCell.self)
        tableView.register(cell: StatisticItemTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func languageChanged(notification:Notification)  {
        setNavigationView(type: .account, title: "Account".localize(), additionalTopMargin: 16)
        editButton.setTitle("Edit Account".localize(), for: .normal)
        descriptonLabel.text = viewModel.getGenderAndDate()
        tableView.reloadData()
    }
    
    private func updateImage(image: UIImage?) {
        avatarHeightConstrait.constant = image != nil ? 80 : 48
        view.layoutIfNeeded()
        avatarImageView.updateImage(image)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Button Action
extension AccountViewController {
    @IBAction func editAction(_ sender: Any) {
        let accountEditVC = AccountEditViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
        navigationController?.pushViewController(accountEditVC, animated: true)
        EventLogger.logEvent("Edit account action")
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountTableViewType.last.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = AccountTableViewType(rawValue: indexPath.row)!
        switch type {
        case .total:
            let cell: TotalClothTableViewCell = tableView.dequeueReusableCell(TotalClothTableViewCell.self)
            cell.configure(count: viewModel.clothesCount)
            cell.selectionStyle = .none
            return cell
        case .statistic:
            let cell: ColorStatisticTableViewCell = tableView.dequeueReusableCell(ColorStatisticTableViewCell.self)
            cell.configure(colorStatModels: viewModel.colorStatModels, maxCount: viewModel.maxColorCount)
            cell.selectionStyle = .none
            return cell
        case .most:
            let cell: StatisticItemTableViewCell = tableView.dequeueReusableCell(StatisticItemTableViewCell.self)
            cell.configure(title: "Most Worn", itemModels: viewModel.mostWornItems)
            cell.selectionStyle = .none
            return cell
        case .less:
            let cell: StatisticItemTableViewCell = tableView.dequeueReusableCell(StatisticItemTableViewCell.self)
            cell.configure(title: "Less Worn", itemModels: viewModel.lessWornItems)
            cell.selectionStyle = .none
            return cell
        case .last:
            let cell: StatisticItemTableViewCell = tableView.dequeueReusableCell(StatisticItemTableViewCell.self)
            cell.configure(title: "Last Worn", itemModels: viewModel.lastWearedItems)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = AccountTableViewType(rawValue: indexPath.row)!
        switch type {
        case .total:
            return 70
        case .statistic:
            return 175
        case .most:
            return 170
        case .less:
            return 170
        case .last:
            return 170
        }
    }
}

//MARK:- RequestResponseProtocol
extension AccountViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        tableView.reloadData()
    }
}




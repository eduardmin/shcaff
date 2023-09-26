//
//  SettingsViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SettingsTableSection: Int {
    case defaultSettings
    case conditions
}

enum SettingRows: Int {
    case language
    case temp
    case customerSupport
    static let titles: [SettingRows: String] = [.temp: "Temp. Unit", .customerSupport: "Customer Support", .language: "Language"]
}

enum ConditionRows: Int {
    case term
    case password
    case preferences
    static let titles: [ConditionRows: String] = [.term: "Terms & Conditions", .preferences: "Account Preferences", .password: "Password"]
}

class SettingsViewController: BaseNavigationViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    let settingsViewModel = SettingsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addObserver()
        settingsViewModel.completion = { [weak self] type in
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
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
    
    @objc func languageChanged(notification:Notification)  {
        setNavigationView(type: .defaultWithBack, title: "Settings".localize(), additionalTopMargin: 16)
        logoutButton.setTitle("Log Out".localize(), for: .normal)
        if let infoDict = Bundle.main.infoDictionary {
            let appShortVersion = infoDict["CFBundleShortVersionString"] as! String
            versionLabel.text = "Schaff".localize() + " " + "Version".localize() + " " + appShortVersion
        }
        tableView.reloadData()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        AlertPresenter.presentInfoAlert(on: self, type: .logout, confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.settingsViewModel.logout()
        })
    }
    
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .defaultWithBack, title: "Settings".localize(), additionalTopMargin: 16)
        tableView.register(cell: InfoTableViewCell.self)
        tableView.backgroundColor = SCColors.tableColor
        logoutButton.layer.cornerRadius = logoutButton.bounds.height / 2
        logoutButton.setTitle("Log Out".localize(), for: .normal)
        if let infoDict = Bundle.main.infoDictionary {
            let appShortVersion = infoDict["CFBundleShortVersionString"] as! String
            versionLabel.text = "Schaff".localize() + " " + "Version".localize() + " " + appShortVersion
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsTableSection.conditions.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SettingsTableSection.conditions.rawValue {
            return ConditionRows.preferences.rawValue + 1
        }
        
        return SettingRows.customerSupport.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InfoTableViewCell = tableView.dequeueReusableCell(InfoTableViewCell.self)
        var info: String = ""
        var isLastCell = false
        if indexPath.section == SettingsTableSection.defaultSettings.rawValue {
            if indexPath.row == SettingRows.customerSupport.rawValue {
                isLastCell = true
            }
            info = SettingRows.titles[SettingRows(rawValue: indexPath.row)!] ?? ""
        } else {
            if indexPath.row == ConditionRows.preferences.rawValue {
                isLastCell = true
            }
            info = ConditionRows.titles[ConditionRows(rawValue: indexPath.row)!] ?? ""
        }

        cell.configure(info: info.localize(), isFirstCell: indexPath.row == 0, isLastCell: isLastCell)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SettingsTableSection.defaultSettings.rawValue {
            switch indexPath.row {
            case SettingRows.temp.rawValue:
                let tempVC = TempUnitViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
                navigationController?.pushViewController(tempVC, animated: true)
                break
            case SettingRows.language.rawValue:
                let langVC = LanguageViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
                navigationController?.pushViewController(langVC, animated: true)
                break
            case SettingRows.customerSupport.rawValue:
                let termVC = CustomerSupportViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
                navigationController?.pushViewController(termVC, animated: true)
            default: break
            }
        } else {
            switch indexPath.row {
            case ConditionRows.preferences.rawValue:
                let prefVC = PreferenceViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
                navigationController?.pushViewController(prefVC, animated: true)
            case ConditionRows.password.rawValue:
                let passwordVC = ChangePasswordViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
                navigationController?.pushViewController(passwordVC, animated: true)
            case ConditionRows.term.rawValue:
//                let termVC = TermConditionViewController.initFromStoryboard(storyBoardName: StoryboardName.account)
//                navigationController?.pushViewController(termVC, animated: true)
                if let url = URL(string: Paths.termCondidionUrl) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            default:
                break
            }
        }
    }
}

//MARK:- RequestResponseProtocol
extension SettingsViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        UIApplication.setTabBarRoot()
    }
}


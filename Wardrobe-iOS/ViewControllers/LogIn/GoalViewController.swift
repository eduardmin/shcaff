//
//  GoalViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    let viewModel = GoalViewModel()
    var completion: ((GoalViewModel) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startGetAll()
        startRequest()
        viewModel.completion = { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .update(let success):
                strongSelf.handleUpdateResponse(success: success)
            case .save(let success):
                strongSelf.handleSaveResponse(success: success)
            }
        }
        configureUI()
    }
    
    private func configureUI() {
        continueButton.isEnabled = false
        continueButton.enableButton(enable: continueButton.isEnabled)
        titleLabel.attributedText = getNavigationTitle("What’s".localize(), "Your Goal?".localize())
        descriptionLabel.text = "Help us help you. We should know what is your goal here, to have better suggestions.".localize()
        if viewModel.type == .login {
            continueButton.setTitle("Continue".localize(), for: .normal)
            EventLogger.logEvent("Goal open")
        } else {
            continueButton.setTitle("Confirm".localize(), for: .normal)
        }
        continueButton.setMode(.background, color: SCColors.whiteColor)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.register(cell: GoalTableViewCell.self)
    }
}

//MARK:- Button Action
extension GoalViewController {
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if viewModel.type == .account {
            if let completion = completion {
                completion(viewModel)
                navigationController?.popViewController(animated: true)
            }
        } else {
            startRequest()
            viewModel.saveGoals()
        }
    }
    
    private func handleSaveResponse(success: Bool) {
        LoadingIndicator.hide(from: view)
        if success {
            if viewModel.type == .login {
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.goal)
                let styleViewController = StyleViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                navigationController?.pushViewController(styleViewController, animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            AlertPresenter.presentRequestErrorAlert(on: self)
        }
    }
    
    private func handleUpdateResponse(success: Bool) {
        if success {
            LoadingIndicator.hide(from: view)
            tableView.reloadData()
        } else {
            AlertPresenter.presentRequestErrorAlert(on: self)
        }
    }
    
    private func startRequest() {
        LoadingIndicator.show(on: view)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension GoalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countOfGoals()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GoalTableViewCell = tableView.dequeueReusableCell(GoalTableViewCell.self)
        let goalModel = viewModel.getGoal(index: indexPath.row)
        cell.configure(goalModel, isSelected: viewModel.tempSaveModelIds.contains(goalModel.id))
        cell.selectionStyle = .none
        if viewModel.tempSaveModelIds.contains(goalModel.id) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: GoalTableViewCell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
        cell.select()
        viewModel.select(index: indexPath.row)
        checkSelectedItems()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: GoalTableViewCell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
        cell.deselect()
        viewModel.deselect(index: indexPath.row)
        checkSelectedItems()
    }
    
    private func checkSelectedItems() {
        continueButton.isEnabled = tableView.indexPathsForSelectedRows?.count ?? 0 > 0
        continueButton.enableButton(enable: continueButton.isEnabled)
    }
}

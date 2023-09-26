//
//  SetEditViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/12/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SetEditSection : Int {
    case items
    case addItem
}

class SetEditViewController: BaseNavigationViewController {
    @IBOutlet weak var tableView: TableView!
    var viewModel : SetViewModel!
    
    //MARK:- Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.updateCompletion = { [weak self] type in
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
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .edit:
            viewModel.editSet()
        default:
            break
        }
    }

    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .editType, attibuteTitle:  getNavigationTitle("Edit".localize(), "Set".localize()), additionalTopMargin: 16, "Save".localize())
        rightMode = .passive
        view.backgroundColor = SCColors.tableColor
        tableView.backgroundColor = UIColor.clear
        tableView.register(cell: InfoTableViewCell.self)
        tableView.register(cell: SetItemTableViewCell.self)
        tableView.register(cell: AddSetTableViewCell.self)
    }

}

//MARK:- RequestResponseProtocol
extension SetEditViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateSets), object: nil, userInfo: nil)
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension SetEditViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SetEditSection.addItem.rawValue + 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SetEditSection.items.rawValue:
            return viewModel.getItems().count
        case SetEditSection.addItem.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SetEditSection.items.rawValue:
            return setItemTableViewCell(for: indexPath)
        case SetEditSection.addItem.rawValue:
            return addSetTableViewCell(for: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SetEditSection.items.rawValue:
            return 80
        case SetEditSection.addItem.rawValue:
            return 70
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SetEditSection.items.rawValue {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
            headerView.backgroundColor = SCColors.whiteColor
            let label = UILabel(frame: CGRect(x: 26, y: 0, width: headerView.frame.width - 26, height: headerView.frame.height))
            label.text = "Items".localize()
            label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            label.textColor = SCColors.titleColor
            headerView.addSubview(label)
            
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
            separatorView.backgroundColor = SCColors.textfieldBorderColor
            headerView.addSubview(separatorView)
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SetEditSection.items.rawValue {
            return 60
        }
        
        return 0
    }
}

//MARK:- Cell configuration
extension SetEditViewController: AddSetTableViewCellDelegate {
    private func setItemTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell : SetItemTableViewCell = tableView.dequeueReusableCell(SetItemTableViewCell.self)
        let itemModel = viewModel.getItems()[indexPath.row]
        cell.configure(item: itemModel)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    private func addSetTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell : AddSetTableViewCell = tableView.dequeueReusableCell(AddSetTableViewCell.self)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func addItemAction() {
        let clothesViewController = ClothesViewController()
        clothesViewController.type = .set
        clothesViewController.addItemIntoSetcompletion = { [weak self] itemModel in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.addItemModel(itemModel)
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
                strongSelf.rightMode = .active
                clothesViewController.dismiss(animated: true, completion: nil)
            }
        }
        let navigation = UINavigationController(rootViewController: clothesViewController)
        navigation.navigationBar.isHidden = true
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.present(navigation, animated: true, completion: nil)
    }
}

//MARK:- SetItemTableViewCellDelegate
extension SetEditViewController: SetItemTableViewCellDelegate {
    func deleteAction(cell: SetItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        rightMode = .active
        viewModel.removeItem(indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

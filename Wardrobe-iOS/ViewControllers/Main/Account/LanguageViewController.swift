//
//  LanguageViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/29/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class LanguageViewController: BaseNavigationViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    private var viewModel = LanguageViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    func configureUI() {
        setNavigationView(type: .editType, title: "Language".localize(), additionalTopMargin: 16, "".localize())
        confirmButton.setMode(.background, color: SCColors.whiteColor)
        confirmButton.setTitle("Confirm".localize(), for: .normal)
        tableView.backgroundColor = SCColors.tableColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(cell: ItemParamMoreTableViewCell.self)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        viewModel.confirm()
        setNavigationView(type: .editType, title: "Language".localize(), additionalTopMargin: 16, "".localize())
        confirmButton.setTitle("Confirm".localize(), for: .normal)
        navigationController?.popViewController(animated: true)
    }
}

//MARK:-  UITableViewDelegate, UITableViewDataSource
extension LanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemParamMoreTableViewCell = tableView.dequeueReusableCell(ItemParamMoreTableViewCell.self)
        let language = viewModel.languages[indexPath.row]
        cell.configureCell(language.name, isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == viewModel.languages.count - 1, selected: viewModel.getSelectedLanguage().key == language.key)
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
        viewModel.select(indexPath: indexPath)
        tableView.reloadData()
    }
}


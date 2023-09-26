//
//  TempUnitViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class TempUnitViewController: BaseNavigationViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comfirmButton: UIButton!
    private let viewModel = TempViewModel()

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
    }
    

    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        viewModel.confirm()
    }
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .editType, title: "Temp. Unit".localize(), additionalTopMargin: 16, "".localize())
        comfirmButton.setMode(.background, color: SCColors.whiteColor)
        comfirmButton.setTitle("Confirm".localize(), for: .normal)
        tableView.backgroundColor = SCColors.tableColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(cell: ItemParamMoreTableViewCell.self)
    }
}

//MARK:-  UITableViewDelegate, UITableViewDataSource
extension TempUnitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tempUnits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemParamMoreTableViewCell = tableView.dequeueReusableCell(ItemParamMoreTableViewCell.self)
        let title = viewModel.tempUnits[indexPath.row]
        cell.configureCell(title.0, isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == viewModel.tempUnits.count - 1, selected: title.1)
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
        viewModel.selectTemp(indexPath: indexPath)
        tableView.reloadData()
    }
}

//MARK:- RequestResponseProtocol
extension TempUnitViewController: RequestResponseProtocol {
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


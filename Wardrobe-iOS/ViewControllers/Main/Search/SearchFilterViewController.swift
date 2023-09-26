//
//  SearchFilterViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/23/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class SearchFilterViewController: BaseNavigationViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var comfirmButton: UIButton!
    var viewModel: SearchViewModel!
    private var temporaryFilterParameters = [ItemParameterModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        temporaryFilterParameters = viewModel.filterParameters
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .edit:
            temporaryFilterParameters.removeAll()
            tableView.reloadData()
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    private func configureUI() {
        setNavigationView(type: .editType, title: "Search Filters".localize(), additionalTopMargin: 16, "Clear".localize())
        comfirmButton.setMode(.background, color: SCColors.whiteColor)
        comfirmButton.setTitle("Confirm".localize(), for: .normal)
        tableView.backgroundColor = SCColors.tableColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.register(cell: ItemParamMoreTableViewCell.self)
    }
    
}

//MARK:- Button Action
extension SearchFilterViewController {
    @IBAction func comfirmAction(_ sender: Any) {
        viewModel.setFilterParam(params: temporaryFilterParameters)
        navigationController?.popViewController(animated: true)
    }
}

//MARK:-  UITableViewDelegate, UITableViewDataSource
extension SearchFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getSearchParameterCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemParamMoreTableViewCell = tableView.dequeueReusableCell(ItemParamMoreTableViewCell.self)
        let type = viewModel.getType(indexPath: indexPath)
        let selected = temporaryFilterParameters.contains(where: { $0.type == ItemParametersType.serverEquelTypes[type] })
        cell.configureCell(viewModel.getTitle(type: type), isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == viewModel.getSearchParameterCount() - 1, selected: selected)
        cell.selectionStyle = .none
        if selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ItemParamMoreTableViewCell
        cell?.select()
        let param = viewModel.getParam(indexPath: indexPath)
        temporaryFilterParameters.append(param)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ItemParamMoreTableViewCell
        cell?.deselect()
        let param = viewModel.getParam(indexPath: indexPath)
        if let index = temporaryFilterParameters.firstIndex(where: { $0.type == param.type }) {
            temporaryFilterParameters.remove(at: index)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

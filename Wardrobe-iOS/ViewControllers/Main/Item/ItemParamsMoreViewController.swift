//
//  ItemParamsMoreViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/23/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol ItemParamsMoreViewControllerDelegate: class {
    func update()
}

class ItemParamsMoreViewController: BaseNavigationViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: ItemParamsMoreViewControllerDelegate?
    var viewModel: ItemParameterViewModel!
    var secetionIndex: Int!
    var itemTitle: String!
    private var itemParameterModel: ItemParameterModel {
       return viewModel.paramterModels[secetionIndex]
    }
    private var selectDeselectItems = [(selected: Bool, indexPath: IndexPath)]()
    private var selectedParameterIds = [Int64]()
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedParameterIds = viewModel.selectedPatamerts(itemParameterModel.type) ?? [Int64]()
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .edit:
            if !selectDeselectItems.isEmpty {
                for (selected, indexPath) in selectDeselectItems {
                    if selected {
                        viewModel.selectParameter(secetionIndex, indexPath.row)
                    } else {
                        viewModel.deselectParameter(secetionIndex, indexPath.row)
                    }
                }
                
                delegate?.update()
            }
            navigationController?.popViewController(animated: true)
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    private func configureUI() {
        setNavigationView(type: .editType, title: itemTitle, additionalTopMargin: 16, "Done".localize())
        view.backgroundColor = SCColors.tableColor
        tableView.backgroundColor = UIColor.clear
        tableView.allowsMultipleSelection = itemParameterModel.muliplyTouch
        tableView.register(cell: ItemParamMoreTableViewCell.self)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension ItemParamsMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemParameterModel.parameterModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemParamMoreTableViewCell = tableView.dequeueReusableCell(ItemParamMoreTableViewCell.self)
        let parameter = itemParameterModel.parameterModels![indexPath.row]
        cell.configureCell(parameter, itemParameterModel.type, selected:  selectedParameterIds.contains(parameter.id), isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == (itemParameterModel.parameterModels?.count ?? 0) - 1)
        if selectedParameterIds.contains(parameter.id) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ItemParamMoreTableViewCell
        let selectedParam : (Bool, IndexPath) = (true, indexPath)
        selectDeselectItems.append(selectedParam)
        addSelectedId(itemParameterModel.parameterModels![indexPath.row])
        cell?.select()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ItemParamMoreTableViewCell
        let selectedParam : (Bool, IndexPath) = (false, indexPath)
        selectDeselectItems.append(selectedParam)
        removeSelectedId(itemParameterModel.parameterModels![indexPath.row])
        cell?.deselect()
    }
    
    private func addSelectedId(_ parameter: BaseParameterModel) {
        if itemParameterModel.muliplyTouch {
            selectedParameterIds.append(parameter.id)
        } else {
            selectedParameterIds.removeAll()
            selectedParameterIds.append(parameter.id)
        }
    }
    
    private func removeSelectedId(_ parameter: BaseParameterModel) {
        if itemParameterModel.muliplyTouch {
            if let index = selectedParameterIds.firstIndex(of: parameter.id) {
                selectedParameterIds.remove(at: index)
            }
        } else {
            selectedParameterIds.removeAll()
        }
    }
    
}

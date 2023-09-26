//
//  ItemParamsViewController.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 6/7/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ItemParamsType {
    case View
    case Edit
}

class ItemParamsViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var topViewHeightConstraint: NSLayoutConstraint!
    //TODO: remove later
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var backButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleNameLabel: UILabel!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var topGrayView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rightButtonWidthConstraint: NSLayoutConstraint!
    var viewModel: ItemParameterViewModel = ItemParameterViewModel()
    var itemModel: ItemModel?

    //MARK:- Public properties
    var type: ItemParamsType = .View
    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.itemModel = itemModel
        viewModel.itemCompletion = { [weak self] (type) in
            guard let strongSelf = self else { return }
            switch type {
            case .update(let index, let insert):
                if insert {
                    strongSelf.instertTableView(index: index ?? 0)
                } else {
                    if let index = index {
                        strongSelf.updateTableView(index: index)
                    } else {
                        strongSelf.tableView.reloadData()
                    }
                }
            case .checkRequiredEmpty(let empty):
                strongSelf.updateRightButton(empty)
            }
        }

        configureTableView()
        configureView()
        addObserver()
    }
    
    //MARK:- Public function
    func setItem(_ itemModel: ItemModel) {
        self.itemModel = itemModel
        viewModel.itemModel = itemModel
        tableView.reloadData()
    }
    
    
    //MARK:- Notification
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(
            keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK:- Actions
    @IBAction func backButtonAction(_ sender: UIButton?) {
       backAction(false)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        viewModel.filterCompletion?(viewModel.saveItemModel)
        navigationController?.popViewController(animated: true)
    }
    
    func backAction(_ popRoot: Bool) {
        if viewModel.type == .edit {
            view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } else if viewModel.type == .save {
            if popRoot {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else  {
            viewModel.clearItem()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        if type == .View {
            let editvc: ItemParamsViewController = ItemParamsViewController.initFromStoryboard()
            editvc.type = .Edit
            editvc.itemModel = itemModel
            let navigation = UINavigationController(rootViewController: editvc)
            navigation.modalPresentationStyle = .fullScreen
            navigation.navigationBar.isHidden = true
            present(navigation, animated: false, completion: nil)
        } else {
            if viewModel.type == .save || viewModel.type == .edit {
                viewModel.saveItem()
                EventLogger.logEvent("Item save action")
                NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateItems), object: nil, userInfo: nil)
                backAction(true)
            } else {
                viewModel.clearItem()
            }
        }
    }
    
    //MARK:- Keyboard Actions
    @objc private func keyboardWillShow(_ notification: Notification?) {
        //get the end position keyboard frame
        let keyInfo = notification?.userInfo
        var keyboardFrame: CGRect? = (keyInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
             keyboardFrame = tableView.convert(keyboardFrame ?? CGRect.zero, from: nil)
        var intersect: CGRect = CGRect.zero
            intersect = keyboardFrame?.intersection(tableView.bounds) ?? CGRect.zero
        if !intersect.isNull  {
            let duration = keyInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
            let curve = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]
            UIView.animate(withDuration: duration as! TimeInterval, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve as! UInt), animations: {
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: intersect.size.height , right: 0)
                    self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: intersect.size.height, right: 0)
            })
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            let keyInfo = notification.userInfo
            let duration = keyInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]
            //change the table insets to match - animated to the same duration of the keyboard appearance
            UIView.animate(withDuration: duration as! TimeInterval, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve as! UInt), animations: {
                    self.tableView.contentInset = .zero
                    self.tableView.scrollIndicatorInsets = .zero
            })
        }
    }
}

//MARK:- UITableViewDataSource
extension ItemParamsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .View:
            return viewModel.itemViewParameterModels.count
        case .Edit:
            return viewModel.paramterModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .View:
            return itemParamTableViewCell(for: indexPath)
        case .Edit:
            let itemParameterModel = viewModel.paramterModels[indexPath.row]

            switch itemParameterModel.type {
            case .brand:
                return itemEditInfoTableViewCell(for: indexPath)
            case .picture:
                return itemEditPictureInfoTableViewCell(for: indexPath)
            default:
                return itemEditParamTableViewCell(for: indexPath)
            }
        }
    }
}

//MARK:- UITableViewDelegate
extension ItemParamsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch type {
        case .View:
            return Constants.tableViewCellHeight
        case .Edit:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- Private functions
extension ItemParamsViewController {
    
    private func configureTableView() {
        hideKeyboardWhenTappedAround()
        tableView.dataSource = self
        tableView.delegate = self
        
        switch type {
        case .View:
            tableView.register(cell: ItemParamTableViewCell.self)
        case .Edit:
            tableView.register(cell: ItemEditParamTableViewCell.self)
            tableView.register(cell: ItemParameterTextFieldTableViewCell.self)
            tableView.register(cell: InfoPictureTableViewCell.self)
        }
    }
    
    private func updateTableView(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    private func instertTableView(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    private func configureView() {
        switch type {
        case .View:
            topViewHeightConstraint.constant = 80
            backButtonWidthConstraint.constant = 0
            titleNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
            topGrayView.isHidden = false
            topGrayView.layer.cornerRadius = 4
            rightButton.setTitle("Edit".localize(), for: .normal)
            if !(itemModel?.personal ?? false) {
                rightButton.isHidden = true
            }
            titleNameLabel.isHidden = true
            confirmButton.isHidden = true
        case .Edit:
            topViewHeightConstraint.constant = 100
            backButtonWidthConstraint.constant = 40
            titleNameLabel.font = UIFont.boldSystemFont(ofSize: 30)
            topGrayView.isHidden = true
            rightButton.setTitle("Save".localize(), for: .normal)
            confirmButton.setMode(.background, color: SCColors.whiteColor)
            confirmButton.setTitle("Confirm".localize(), for: .normal)
            confirmButton.isHidden = true
            if viewModel.type == .edit {
                rightButton.setSaveButtonMode(.active, widthConstraint: rightButtonWidthConstraint)
                titleNameLabel.text = "Edit Item".localize()
            } else if viewModel.type == .save {
                rightButton.setSaveButtonMode(.passive, widthConstraint: rightButtonWidthConstraint)
                titleNameLabel.text = "Add Item".localize()
            } else {
                confirmButton.isHidden = false
                view.bringSubviewToFront(confirmButton)
                titleNameLabel.text = "Filter".localize()
                rightButton.setTitle("Clear".localize(), for: .normal)
                rightButton.setTitleColor(SCColors.secondaryColor, for: .normal)
            }
        }
    }
    
    private func updateRightButton(_ empty: Bool) {
        if empty {
            rightButton.setSaveButtonMode(.passive, widthConstraint: rightButtonWidthConstraint)
        } else {
            rightButton.setSaveButtonMode(.active, widthConstraint: rightButtonWidthConstraint)
        }
    }

    private func itemParamTableViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemParamTableViewCell = tableView.dequeueReusableCell(ItemParamTableViewCell.self)
        let model = viewModel.itemViewParameterModels[indexPath.row]
        cell.set(name: cellTitle(model.type, false), model: model)
        cell.selectionStyle = .none
        return cell
    }
    
    private func itemEditParamTableViewCell(for indexPath: IndexPath) -> ItemEditParamTableViewCell {
        let itemParameterModel = viewModel.paramterModels[indexPath.row]
        let cell: ItemEditParamTableViewCell = tableView.dequeueReusableCell(ItemEditParamTableViewCell.self)
        cell.selectionStyle = .none
        cell.configure(itemParameterModel, cellTitle(itemParameterModel.type, itemParameterModel.requiredField), viewModel.selectedPatamerts(itemParameterModel.type), indexPath.row == 0)
        cell.delegate = self
        return cell
        
    }
    
    private func itemEditInfoTableViewCell(for indexPath: IndexPath) -> ItemParameterTextFieldTableViewCell {
        let itemParameterModel = viewModel.paramterModels[indexPath.row]
        let cell: ItemParameterTextFieldTableViewCell = tableView.dequeueReusableCell(ItemParameterTextFieldTableViewCell.self)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configure(cellTitle(itemParameterModel.type, itemParameterModel.requiredField), brandName: viewModel.getBrandText())
        return cell
    }
    
    private func itemEditPictureInfoTableViewCell(for indexPath: IndexPath) -> InfoPictureTableViewCell {
        let itemParameterModel = viewModel.paramterModels[indexPath.row]
        let cell: InfoPictureTableViewCell = tableView.dequeueReusableCell(InfoPictureTableViewCell.self)
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configure(info: cellTitle(itemParameterModel.type, false), image: itemParameterModel.image ?? UIImage(named: "downloadFail")!, type: viewModel.type)
        return cell
    }
    
    private func cellTitle(_ type: ItemParametersType, _ requiered: Bool) -> String {
        var requiredText = ""
        if requiered {
            requiredText = "*"
        }
        switch type {
        case .picture:
            return "Picture".localize() + requiredText
        case .clothingType:
            return "Category".localize() + requiredText
        case .type:
            return "Type".localize() + requiredText
        case .color:
            return "Color".localize() + requiredText
        case .print:
            return "Print".localize() + requiredText
        case .size:
            return "Size".localize() + requiredText
        case .brand:
            return "Brand".localize() + requiredText
        default:
            return ""
        }
    }
}

//MARK:- InfoPictureTableViewCellDelegate
extension ItemParamsViewController: InfoPictureTableViewCellDelegate {
    func changeImage() {
        let takePhotoViewController: TakePhotoViewController = TakePhotoViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        takePhotoViewController.type = .update
        takePhotoViewController.updateCompletion = { [weak self] imageData in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setImageData(imageData)
            strongSelf.viewModel.changeImage()
            strongSelf.updateTableView(index: 0)
        }
        takePhotoViewController.modalPresentationStyle = .fullScreen
        present(takePhotoViewController, animated: true, completion: nil)
    }
    
    func selectPicture(_ cell: InfoPictureTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let itemParameterModel = viewModel.paramterModels[indexPath.row]
        if let image = itemParameterModel.image {
            AlertPresenter.presentPictureAlert(on: self, image: image)
        }
    }
}

//MARK:- ItemEditParamTableViewCellDelegate
extension ItemParamsViewController: ItemEditParamTableViewCellDelegate {
    func seeAllAction(_ cell: ItemEditParamTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let itemParameterModel = viewModel.paramterModels[indexPath.row]

        let itemParamsMoreViewController: ItemParamsMoreViewController = ItemParamsMoreViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        itemParamsMoreViewController.delegate = self
        itemParamsMoreViewController.viewModel = viewModel
        itemParamsMoreViewController.secetionIndex = indexPath.row
        itemParamsMoreViewController.itemTitle = cellTitle(itemParameterModel.type, itemParameterModel.requiredField)
        navigationController?.pushViewController(itemParamsMoreViewController, animated: true)
    }
    
    func selectCell(_ cell: ItemEditParamTableViewCell, _ indexSelectedCell: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.selectParameter(indexPath.row, indexSelectedCell)
            let itemParameterModel = viewModel.paramterModels[indexPath.row]
            cell.updateSelectedItems(viewModel.selectedPatamerts(itemParameterModel.type))
        }
    }
    
    func deselectCell(_ cell: ItemEditParamTableViewCell, _ indexDeselectedCell: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.deselectParameter(indexPath.row, indexDeselectedCell)
            let itemParameterModel = viewModel.paramterModels[indexPath.row]
            cell.updateSelectedItems(viewModel.selectedPatamerts(itemParameterModel.type))
        }
    }
}

//MARK:- ItemParamsMoreViewControllerDelegate
extension ItemParamsViewController: ItemParamsMoreViewControllerDelegate {
    func update() {
        tableView.reloadData()
    }
}

//MARK:- ItemParameterTextFieldTableViewCellDelegate
extension ItemParamsViewController: ItemParameterTextFieldTableViewCellDelegate {
    func textEditFinish(_ text: String) {
        viewModel.addBrand(text)
    }
}


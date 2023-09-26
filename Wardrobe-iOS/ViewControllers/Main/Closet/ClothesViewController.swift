//
//  ClothesViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//

import UIKit

enum ClothType {
    case normal
    case set
}

class ClothesViewController: BaseNavigationViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(cell: ClothesTableViewCell.self)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.fixInView(view)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight, right: 0)
        return tableView
    }()
    var plusView: PlusView?
    var type: ClothType = .normal
    var addItemIntoSetcompletion: ((ItemModel) -> ())?
    var viewModel = ItemViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addObserver()
        viewModel.completion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plusView?.delegate = self
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateItems), name: NSNotification.Name(rawValue: NotificationName.updateItems), object: nil)
    }
    
    private func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        if type == .set {
            setNavigationView(type: .defaultWithCancel, attibuteTitle: getNavigationTitle("Choose".localize(), "The Item".localize()))
        }
    }
    
    @objc private func updateItems() {
        viewModel.updateItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension ClothesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ClothesTableViewCell.self) as ClothesTableViewCell
        let itemSectionModel = viewModel.sectionModels[indexPath.row]
        cell.configure(itemSectionModel, index: indexPath.row)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK:- ClothesTableViewCellDelegate
extension ClothesViewController: ClothesTableViewCellDelegate {
    func selectItem(_ cell: ClothesTableViewCell, selectedIndex: Int) {
        if let indexPath = tableView.indexPath(for: cell) {
            let sectionModel = viewModel.sectionModels[indexPath.row]
            if type == .normal {
                let itemViewController: ItemViewController = ItemViewController.initFromStoryboard()
                let itemModels = sectionModel.items.changeElementToFirst(element: selectedIndex)
                itemViewController.setItems(itemModels)
                itemViewController.modalPresentationStyle = .fullScreen
                present(itemViewController, animated: true, completion: nil)
            } else {
                let itemModel = sectionModel.items[selectedIndex]
                AlertPresenter.presentAddItemToSetAlert(on: self, image: itemModel.image, confirmButtonTitle: "Add".localize(), cancelButtonTitle: "Cancel".localize()) { (_) in
                    self.addItemIntoSetcompletion?(itemModel)
                }
            }
        }
    }
    
    func seeAllAction(_ cell: ClothesTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        let clothItemViewController = ClothItemViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe) as ClothItemViewController
        let model = viewModel.sectionModels[indexPath!.row]
        let viewModel = ItemAllViewModel(model: model)
        clothItemViewController.viewModel = viewModel
        clothItemViewController.addItemIntoSetcompletion = addItemIntoSetcompletion
        navigationController?.pushViewController(clothItemViewController, animated: true)
    }
    
    func delete(_ cell: ClothesTableViewCell, Index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let itemSectionModel = viewModel.sectionModels[indexPath.row]
        let model = itemSectionModel.items[Index]
        AlertPresenter.presentInfoAlert(on: self, type: .deleteItem(model.getItemColorAndTypeName()), confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.deleteItem(model: model)
        })
    }
    
    func edit(_ cell: ClothesTableViewCell, Index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let itemSectionModel = viewModel.sectionModels[indexPath.row]
        let model = itemSectionModel.items[Index]
        let itemViewController: ItemParamsViewController = ItemParamsViewController.initFromStoryboard()
        let navigation = UINavigationController(rootViewController: itemViewController)
        itemViewController.type = .Edit
        itemViewController.itemModel = model
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.isHidden = true
        navigationController?.present(navigation, animated: true)
    }
}

//MARK:- PlusViewDelegate
extension ClothesViewController: PlusViewDelegate {
    func takePhotoAction() {
        plusView?.changeState()
        let takePhotoViewController = TakePhotoViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        let navigation = UINavigationController(rootViewController: takePhotoViewController)
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.isHidden = true
        present(navigation, animated: true, completion: nil)
    }
    
    func basicAction() {
        plusView?.changeState()
        let  basicViewController: BasicViewController = BasicViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
        basicViewController.type = .wardrobe
        basicViewController.viewModel.setSavedItems(itemModels: viewModel.getBasicItems())
        let navigation = UINavigationController(rootViewController: basicViewController)
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.isHidden = true
        present(navigation, animated: true, completion: nil)
    }
}

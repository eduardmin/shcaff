//
//  ClothItemViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//

import UIKit

class ClothItemViewController: BaseNavigationViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let leftRightMargin: CGFloat = 16
    private let intentPanding: CGFloat = 15
    private let topMargin: CGFloat = 26
    private var itemWidth : CGFloat {
        let width = (view.bounds.width - 2 * leftRightMargin - intentPanding) / 2
        return CGFloat(width.rounded(.down))
    }
    var addItemIntoSetcompletion: ((ItemModel) -> ())?
    var viewModel: ItemAllViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationView(type: .filterType, title: viewModel.sectionModel.clothingTypeModel.name, additionalTopMargin: 16)
        collectionView.register(cell: ClosetItemCollectionViewCell.self)
        collectionView.updateInsets(vertical: topMargin, interItem: intentPanding, interRow: intentPanding)
        viewModel.updateCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBottomBarWhenPushed = false
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .filter:
            openFilter()
        default:
            break
        }
    }
    
    func openFilter() {
        let itemViewController: ItemParamsViewController = ItemParamsViewController.initFromStoryboard()
        itemViewController.type = .Edit
        itemViewController.viewModel.filterItem = viewModel.filterItemModel
        itemViewController.viewModel.filterCompletion = { [weak self] model in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setFilterItem(model)
        }
        navigationController?.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ClothItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ClosetItemCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ClosetItemCollectionViewCell.self, indexPath: indexPath) as ClosetItemCollectionViewCell
        let item = viewModel.getItem(with: indexPath.row)
        cell.configure(item.image)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let competion = addItemIntoSetcompletion {
            let itemModel = viewModel.getItem(with: indexPath.row)
            AlertPresenter.presentAddItemToSetAlert(on: self, image: itemModel.image, confirmButtonTitle: "Add".localize(), cancelButtonTitle: "cancel".localize()) { (_) in
                competion(itemModel)
            }

        } else {
            let itemViewController: ItemViewController = ItemViewController.initFromStoryboard()
            let itemModels = viewModel.getItems().changeElementToFirst(element: indexPath.row)
            itemViewController.setItems(itemModels)
            itemViewController.modalPresentationStyle = .fullScreen
            present(itemViewController, animated: true, completion: nil)
        }
    }
    
    func deleteAction(cell: ClosetItemCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let model = viewModel.getItem(with: indexPath.row)
        AlertPresenter.presentInfoAlert(on: self, type: .deleteItem(model.getItemColorAndTypeName()), confirmButtonCompletion:  { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.deleteItem(model: model, index: indexPath.row)
            NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateItems), object: nil, userInfo: nil)
        })
    }
    
    func editAction(cell: ClosetItemCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let model = viewModel.getItem(with: indexPath.row)
        let itemViewController: ItemParamsViewController = ItemParamsViewController.initFromStoryboard()
        let navigation = UINavigationController(rootViewController: itemViewController)
        itemViewController.type = .Edit
        itemViewController.itemModel = model
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.isHidden = true
        navigationController?.present(navigation, animated: true)
    }
}

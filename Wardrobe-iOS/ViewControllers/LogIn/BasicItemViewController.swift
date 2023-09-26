//
//  BasicItemViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/29/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol BasicItemViewControllerDelegate: class {
    func selectItem(withID id: Int64)
    func deselectItem(withID id: Int64)
    func selectedItems() -> [Int64]
}

class BasicItemViewController: UIViewController {
    private let rightLeftMargin: CGFloat = 16
    private let panding: CGFloat = 8
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SCColors.whiteColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.fixInView(view)
        collectionView.register(cell: BasicItemCollectionViewCell.self)
        collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        return collectionView
    }()
    weak var delegate: BasicItemViewControllerDelegate?
    var itemModels: [ItemModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.updateInsets(interItem: panding, interRow: panding)
    }
    deinit {
        print("")
    }
}

extension BasicItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BasicItemCollectionViewCell = collectionView.dequeueReusableCell(BasicItemCollectionViewCell.self, indexPath: indexPath)
        let itemModel = itemModels![indexPath.row]
        let selected =  delegate?.selectedItems().contains(itemModel.id ?? 0) ?? false
        cell.configure(itemModel, selected: selected)
        if selected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.bounds.width - 2 * rightLeftMargin - 3 * panding) / 3
        return CGSize(width: itemWidth, height: itemWidth + 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BasicItemCollectionViewCell
        cell?.selectCell()
        if let itemModel = itemModels?[indexPath.row], let id = itemModel.id {
            delegate?.selectItem(withID: id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BasicItemCollectionViewCell
        cell?.deselectCell()
        if let itemModel = itemModels?[indexPath.row], let id = itemModel.id {
            delegate?.deselectItem(withID: id)
        }
    }
}

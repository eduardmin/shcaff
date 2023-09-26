//
//  ClothesTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

protocol ClothesTableViewCellDelegate: class {
    func seeAllAction(_ cell: ClothesTableViewCell)
    func selectItem(_ cell: ClothesTableViewCell, selectedIndex: Int)
    func delete(_ cell: ClothesTableViewCell, Index: Int)
    func edit(_ cell: ClothesTableViewCell, Index: Int)
}

class ClothesTableViewCell: UITableViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ClothesTableViewCellDelegate?
    private let itemHeight: CGFloat = 136
    private var index: Int = 0
    var itemSectionModel :ItemSectionModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seeAllButton.setTitle("See all".localize(), for: .normal)
        collectionView.updateInsets(interItem: 13, interRow: 13)
        collectionView.register(cell: ClosetItemCollectionViewCell.self)
    }
    
    func configure(_ model: ItemSectionModel, index: Int) {
        self.itemSectionModel = model
        self.index = index
        typeLabel.text = model.clothingTypeModel.name
        collectionView.reloadData()
    }
    
}

//MARK:- Button Action
extension ClothesTableViewCell {
    @IBAction func seeAllAction(_ sender: Any) {
        delegate?.seeAllAction(self)
    }
}

extension ClothesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ClosetItemCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemSectionModel?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ClosetItemCollectionViewCell.self, indexPath: indexPath) as ClosetItemCollectionViewCell
        let item: ItemModel = itemSectionModel!.items[indexPath.row]
        cell.configure(item.image)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemHeight, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectItem(self, selectedIndex: indexPath.row)
    }
    
    func getSelectedCellFrame(indexPath: IndexPath) -> CGRect {
        let rectOfCell = collectionView.layoutAttributesForItem(at: indexPath)!.frame
        var rectOfCellInSuperview = collectionView.convert(rectOfCell, to: collectionView.superview)
        rectOfCellInSuperview.origin.y = rectOfCellInSuperview.minY + CGFloat(index) * frame.height
        rectOfCellInSuperview.origin.x = rectOfCellInSuperview.origin.x - collectionView.contentOffset.x
        return rectOfCellInSuperview
    }
    
    func deleteAction(cell: ClosetItemCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        delegate?.delete(self, Index: indexPath.row)
    }
    
    func editAction(cell: ClosetItemCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        delegate?.edit(self, Index: indexPath.row)
    }
}

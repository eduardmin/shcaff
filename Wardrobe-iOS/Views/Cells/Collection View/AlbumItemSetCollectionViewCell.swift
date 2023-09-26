//
//  AlbumItemSetCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/25/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class AlbumItemSetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    private let itemPadding : CGFloat = 10
    private let leftRightMargin: CGFloat = 16
    let layout = CenterViewFlowLayout()
    private var itemHeight : CGFloat {
        let item = (bounds.width - itemPadding - 2 * leftRightMargin) / 2
        return item.rounded(.down)
    }
    var itemModels: [ItemModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        collectionView.layer.cornerRadius = 20
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(cell: SetItemCollectionViewCell.self)
        collectionView.isUserInteractionEnabled = false
        collectionView.updateInsets(interItem:itemPadding, interRow: itemPadding)
    }
    
    func configure(_ itemModels: [ItemModel]) {
        self.itemModels = itemModels
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        collectionView.reloadData()
    }
}

extension AlbumItemSetCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
        let itemModel = itemModels?[indexPath.row]
        if let image = itemModel?.image {
            cell.configue(image: image, cornerRadius: itemHeight / 2)
        }
        return cell
    }
}


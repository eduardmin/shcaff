//
//  AlbumSetCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/22/20.
//

import UIKit

class AlbumSetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    private var itemPadding : CGFloat = 6
    private var leftRightMargin: CGFloat = 10
    private var itemHeight : CGFloat {
          let item = (bounds.width - 2 * leftRightMargin - itemPadding) / 2
          return  item.rounded(.down)
    }
    private let layout = CenterViewFlowLayout()

    var itemModels: [ItemModel]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(cell: SetItemCollectionViewCell.self)
    }
    
    func configure(_ itemModels: [ItemModel]) {
        if bounds.width > UIScreen.main.bounds.width / 2 {
            leftRightMargin = 23
            itemPadding = 16
        } else {
            leftRightMargin = 10
            itemPadding = 6
        }
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        collectionView.updateInsets(horizontal: 0, vertical: 0, interItem: itemPadding, interRow: itemPadding)
        self.itemModels = itemModels
        collectionView.reloadData()
    }
}

extension AlbumSetCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
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

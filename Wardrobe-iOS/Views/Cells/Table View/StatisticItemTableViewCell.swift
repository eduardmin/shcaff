//
//  StatisticItemTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class StatisticItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyDescLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    private var itemModels: [ItemModel?]?
    private let itemHeight: CGFloat = 100

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        collectionView.updateInsets(horizontal: 26, interItem: 20, interRow: 20)
        collectionView.register(cell: ClosetItemCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configure(title: String, itemModels: [ItemModel?]) {
        emptyTitleLabel.text = "No Data".localize()
        emptyDescLabel.text = "Log more daily outfits by clicking “Todays Choice” to see the stats.".localize()
        titleLabel.text = title.localize()
        self.itemModels = itemModels
        if itemModels.isEmpty {
            emptyTitleLabel.isHidden = false
            emptyDescLabel.isHidden = false
        } else {
            emptyTitleLabel.isHidden = true
            emptyDescLabel.isHidden = true
        }
        collectionView.reloadData()
    }
}

//MARK:-
extension StatisticItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ClosetItemCollectionViewCell.self, indexPath: indexPath) as ClosetItemCollectionViewCell
        if let item: ItemModel = itemModels![indexPath.row] {
            cell.configure(item.image)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemHeight, height: itemHeight)
    }
}

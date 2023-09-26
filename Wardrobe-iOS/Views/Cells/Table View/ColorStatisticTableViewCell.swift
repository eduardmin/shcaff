//
//  ColorStatisticTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/18/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ColorStatisticTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyDescLabel: UILabel!
    var colorStatModels: [ColorStatModel]?
    var maxCount: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        emptyTitleLabel.text = "No Data".localize()
        emptyDescLabel.text = "Log more clothes to your closet to see the stats.".localize()
        collectionView.register(cell: ColorStatisticCollectionViewCell.self)
        collectionView.updateInsets()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configure(colorStatModels: [ColorStatModel], maxCount: Int) {
        seperatorView.isHidden = colorStatModels.count == 0
        if colorStatModels.isEmpty {
            emptyTitleLabel.isHidden = false
            emptyDescLabel.isHidden = false
        } else {
            emptyTitleLabel.isHidden = true
            emptyDescLabel.isHidden = true
            self.maxCount = maxCount
            self.colorStatModels = colorStatModels
            collectionView.reloadData()
        }
    }
    
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension ColorStatisticTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorStatModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorStatisticCollectionViewCell = collectionView.dequeueReusableCell(ColorStatisticCollectionViewCell.self, indexPath: indexPath)
        let color = colorStatModels![indexPath.row]
        cell.configure(model: color, maxCount: maxCount)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 175)
    }
}

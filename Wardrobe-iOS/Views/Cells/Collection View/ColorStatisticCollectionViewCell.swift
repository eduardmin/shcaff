//
//  ColorStatisticCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/18/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ColorStatisticCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorStatisticView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var colorStatisticHeight: NSLayoutConstraint!
    private let maxHeight: CGFloat = 150
    private let minHeight: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        colorStatisticView.layer.cornerRadius = 5
        colorStatisticView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func configure(model: ColorStatModel, maxCount: Int) {
        let color = UIColor(hexString: model.colorCode ?? "")
        colorStatisticView.backgroundColor = color
        countLabel.textColor = color
        countLabel.text = "\(model.quantity)"
        let difference: CGFloat = CGFloat(maxCount) / CGFloat(model.quantity)
        var height = 150 / difference
        if height < minHeight {
            height = minHeight
        }
        colorStatisticHeight.constant = height
    }

}

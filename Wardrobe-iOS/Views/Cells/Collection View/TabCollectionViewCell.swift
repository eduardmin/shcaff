//
//  TabCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/23/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    override var isSelected: Bool {
        didSet {
            if isSelected {
                select()
            } else {
                deselect()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: String) {
        titleLabel.text = title
        if !isSelected {
            titleLabel.textColor = SCColors.mainGrayColor
        }
    }
    
    func select() {
        titleLabel.textColor = SCColors.titleColor
    }
    
    func deselect() {
        titleLabel.textColor = SCColors.mainGrayColor
    }
}

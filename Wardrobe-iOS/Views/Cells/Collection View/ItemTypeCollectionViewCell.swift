//
//  ItemTypeCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/8/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ItemTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    private var selectedColor: UIColor = SCColors.secondaryColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

//MARK:- Public Function
extension ItemTypeCollectionViewCell : CellSelectionProtocol {
    
    func configure(info : String, isSelected : Bool, isSearch: Bool = false) {
        if isSearch {
            titleLabelHeightConstraint.constant = 50
            bottomConstraint.constant = 5
            mainView.layer.cornerRadius = titleLabelHeightConstraint.constant / 2
            selectedColor = SCColors.secondaryColor
            addShadow(true, 1, 3)
        } else {
            mainView.layer.cornerRadius = 10
        }
        titleLabel.text = info
        if isSelected {
            select()
        } else {
            deselect()
        }
    }
    
    func select() {
        titleLabel.textColor = SCColors.whiteColor
        mainView.backgroundColor = selectedColor
    }

    func deselect() {
        titleLabel.textColor = SCColors.titleColor
        mainView.backgroundColor = SCColors.itemTypeColor
    }
}



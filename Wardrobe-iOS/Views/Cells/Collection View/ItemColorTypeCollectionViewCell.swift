//
//  ItemColorTypeCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/8/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ItemColorTypeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

//MARK:- Public Function
extension ItemColorTypeCollectionViewCell: CellSelectionProtocol {
    func configure(color: UIColor, isSelected: Bool, isWhite: Bool = false) {
        mainView.layer.cornerRadius = mainView.bounds.height / 2
        mainView.backgroundColor = color
        if isWhite {
            mainView.layer.borderColor = SCColors.mainGrayColor.cgColor
            mainView.layer.borderWidth = 0.3
            checkMark.image = UIImage(named: "checkMarkBlack")
        } else {
            checkMark.image = UIImage(named: "checkMark")
        }
        checkMark.isHidden = !isSelected
    }
    
    func configure(image: UIImage, isSelected: Bool) {
        mainView.backgroundColor = UIColor.clear
        imageView.image = image
        checkMark.isHidden = !isSelected
        checkMark.image = UIImage(named: "checkMarkBlack")

    }
    
    func select() {
        checkMark.isHidden = false
    }
    
    func deselect() {
        checkMark.isHidden = true
    }
}


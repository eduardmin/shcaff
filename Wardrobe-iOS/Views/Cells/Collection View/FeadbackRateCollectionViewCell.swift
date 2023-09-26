//
//  FeadbackRateCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/29/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

class FeadbackRateCollectionViewCell: UICollectionViewCell, CellSelectionProtocol {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        mainView.layer.cornerRadius = 13
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = SCColors.separatorColor.cgColor
    }
    
    func configure(text: String) {
        numberLabel.text = text
    }

    func select() {
        numberLabel.textColor = SCColors.whiteColor
        mainView.backgroundColor = SCColors.secondaryColor
        mainView.layer.borderColor = SCColors.secondaryColor.cgColor
    }

    func deselect() {
        numberLabel.textColor = SCColors.mainGrayColor
        mainView.backgroundColor = SCColors.whiteColor
        mainView.layer.borderColor = SCColors.separatorColor.cgColor
    }
}

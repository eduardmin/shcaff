//
//  ItemCategoryTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/2/20.
//

import UIKit

class ItemCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        mainView.layer.borderColor = SCColors.itemTypeColor.cgColor
        mainView.layer.borderWidth = 1
        mainView.layer.cornerRadius = 25
    }
    
    func configure(_ text: String, _ empty: Bool) {
        titleLabel.text = text
        if empty {
            mainView.layer.borderColor = SCColors.secondaryGray.cgColor
            mainView.backgroundColor = SCColors.secondaryGray
        } else {
            mainView.layer.borderColor = SCColors.itemTypeColor.cgColor
            mainView.backgroundColor = SCColors.whiteColor
        }
    }
}

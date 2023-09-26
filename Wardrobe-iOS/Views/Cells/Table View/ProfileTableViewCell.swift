//
//  ProfileTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/13/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
   private  func configureUI() {
        mainView.layer.cornerRadius = mainView.bounds.height / 2
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = SCColors.textfieldBorderColor.cgColor
    }
    
    func configure(_ title: String) {
        titleLabel.text = title.localize()
    }
    
    func select() {
        mainView.layer.borderColor = SCColors.secondaryColor.cgColor
        mainView.backgroundColor = SCColors.secondaryColor
        titleLabel.textColor = SCColors.whiteColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)

    }
    
    func deselect() {
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        mainView.backgroundColor = SCColors.whiteColor
        titleLabel.textColor = SCColors.titleColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
    }
}

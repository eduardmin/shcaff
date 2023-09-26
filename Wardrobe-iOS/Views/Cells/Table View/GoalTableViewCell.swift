//
//  GoalTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell {
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkMarkView: UIView!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        goalView.layer.cornerRadius = 15
        goalView.layer.borderWidth = 1
        goalView.layer.borderColor = SCColors.itemTypeColor.cgColor
        checkMarkView.layer.cornerRadius = checkMarkView.bounds.height / 2
        checkMarkView.layer.borderWidth = 1
        checkMarkView.layer.borderColor = SCColors.itemTypeColor.cgColor
        checkMarkImageView.isHidden = true
    }
    
    func configure(_ goal: GoalModel, isSelected: Bool) {
        nameLabel.text = goal.name
        if isSelected {
            select()
        } else {
            deselect()
        }
    }
    
    func select() {
        checkMarkImageView.isHidden = false
        goalView.backgroundColor = SCColors.secondaryColor
        nameLabel.textColor = SCColors.whiteColor
        goalView.layer.borderColor = SCColors.secondaryColor.cgColor
    }
    
    func deselect() {
        checkMarkImageView.isHidden = true
        goalView.backgroundColor = SCColors.whiteColor
        nameLabel.textColor = SCColors.titleColor
        goalView.layer.borderColor = SCColors.itemTypeColor.cgColor
    }
}

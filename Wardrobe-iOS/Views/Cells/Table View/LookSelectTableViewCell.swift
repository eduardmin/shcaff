//
//  LookSelectTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/31/20.
//

import UIKit

class LookSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelYConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        selectView.layer.cornerRadius = 15
        emptyLabel.text = "No Items Yet".localize()
    }
    
    func configure(_ title: String, _ empty: Bool) {
        self.titleLabel.text = title
        if empty {
            titleLabelYConstraint.constant = -10
            emptyLabel.isHidden = false
            selectView.backgroundColor = SCColors.emptyItemSecondColor
        } else {
            selectView.addShadow(true, 3, 10)
            emptyLabel.isHidden = true
            titleLabelYConstraint.constant = 0
            selectView.backgroundColor = SCColors.whiteColor
        }
    }
    
}

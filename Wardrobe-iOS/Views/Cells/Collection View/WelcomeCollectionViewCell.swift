//
//  WelcomeCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 3/25/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class WelcomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: NSAttributedString) {
        titleLabel.attributedText = title
    }

}

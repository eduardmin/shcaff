//
//  SearchTextTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/18/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class SearchTextTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ text: String) {
        titleLabel.text = text
    }
}

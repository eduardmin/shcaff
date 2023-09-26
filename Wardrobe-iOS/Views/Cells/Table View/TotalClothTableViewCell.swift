//
//  TotalClothTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class TotalClothTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.text = "Total Clothes".localize()
    }
    
    func configure(count: Int) {
        titleLabel.text = "Total Clothes".localize()
        countLabel.isHidden = count == 0
        countLabel.text = "\(count)"
    }
    
}

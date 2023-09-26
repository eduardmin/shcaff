//
//  SearchCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/16/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configueUI()
    }
    
    private func configueUI() {
        mainView.layer.cornerRadius = 15
        mainView.addShadow(true, 5, 10)
    }
    
    func configure(_ title: String, imageName: String) {
        titleLabel.text = title
        imageView.image = UIImage(named: imageName)
    }

}

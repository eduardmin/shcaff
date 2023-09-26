//
//  ItemCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 30
    }
    
    func configure(_ model : ItemModel) {
        imageView.image = model.image
    }

}

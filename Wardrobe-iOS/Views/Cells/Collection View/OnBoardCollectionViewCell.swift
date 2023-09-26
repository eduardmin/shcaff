//
//  OnBoardCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/13/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class OnBoardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(image: UIImage) {
        imageView.image = image
    }

}

//
//  SetItemCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/11/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class SetItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Public func
    func configue(image : UIImage, cornerRadius: CGFloat = 20) {
        imageView.image = image
        imageView.layer.cornerRadius = cornerRadius
    }
    
}

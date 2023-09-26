//
//  LookItemCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/30/20.
//

import UIKit

class LookItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        imageView.layer.cornerRadius = 20
    }
    
    func configure(_ image: UIImage) {
        imageView.image = image
    }
}

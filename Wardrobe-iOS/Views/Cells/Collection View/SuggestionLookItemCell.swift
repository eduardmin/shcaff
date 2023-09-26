//
//  SuggestionLookItemCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/23/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class SuggestionLookItemCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    private let grLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
    }

    func configure(image: UIImage) {
        imageView.image = image
    }
    
    func stopAnimating() {
        grLayer.removeFromSuperlayer()
    }
    
    func startAnimating(multipleHeight: CGFloat? = nil) {
        stopAnimating()
        addAnimGradientLayerTo(mainView, multipleHeight)
    }
    
    private func addAnimGradientLayerTo(_ view: UIView, _ multipleHeight: CGFloat? = nil) {
        view.clipsToBounds = true
        grLayer.colors = [SCColors.emptyItemFirstColor.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, SCColors.emptyItemFirstColor.cgColor]
        grLayer.frame = view.bounds
        grLayer.add(grLayer.sliding, forKey: "")
        view.layer.addSublayer(grLayer)
    }
}
